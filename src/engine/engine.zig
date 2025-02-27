const std = @import("std");
const chess = @import("../chess.zig");
const types = @import("types.zig");
const heuristic = @import("heuristic.zig");
const transposition = @import("transposition.zig");

const NodeType = enum {
    Root,
    Other,
};

const max_game_ply = 1024;
const max_ply: u8 = 128;

/// The Engine is the component responsible for finding the best move
pub const Engine = struct {
    /// Should the engine not emit uci info
    quiet: bool = false,
    /// Maximum time in milliseconds
    max_time: u64 = 1_000 * std.time.ms_per_s,
    /// Ideal time the engine should think for in milliseconds
    search_time: u64 = 100 * std.time.ms_per_s,

    /// Is the engine searching
    searching: bool = false,
    /// If the engine should stop as soon as possible
    stop: bool = false,

    /// Timer from the start of the search
    search_timer: std.time.Timer = undefined,
    /// Number of nodes searched
    nodes: usize = 0,
    /// Maximum depth reached
    depth: u8 = 0,
    /// Currenty ply
    ply: u8 = 0,
    /// The current best move found by the engine
    best_move: chess.ChessMove = chess.ChessMove{},
    /// The previous current best move found by the engine
    prev_best_move: chess.ChessMove = chess.ChessMove{},
    /// The current eval of the engine
    score: types.Score = 0,

    /// History of hashes in the search
    hash_history: std.ArrayList(u64),

    pub fn init(allocator: std.mem.Allocator) !Engine {
        const hash_history = std.ArrayList(u64).initCapacity(allocator, max_game_ply) catch unreachable;
        return .{
            .hash_history = hash_history,
        };
    }

    pub fn reset(self: *Engine) void {
        self.hash_history.clearAndFree();
        self.nodes = 0;
        self.best_move = chess.ChessMove{};
    }

    pub fn deinit(self: *Engine) void {
        self.hash_history.deinit();
    }

    fn shouldStop(self: *Engine) bool {
        const current_time = self.search_timer.read() / std.time.ns_per_ms;
        return self.stop or current_time > @min(self.max_time, self.search_time);
    }

    /// Iterative deepening for finding the best move.
    /// The basic idea is to start with a depth of 1ply and then
    /// repeat the search increasing the depth each time. This sounds
    /// counterintuitive but if we use information from the previous
    /// search in move ordering we can be almost sure that we will
    /// look at the best move first and so prune a lot of nodes.
    /// https://www.chessprogramming.org/Iterative_Deepening
    pub fn search(
        self: *Engine,
        board: *chess.Board,
        comptime color: bool,
        max_depth: ?u8,
    ) void {
        var bufout = std.io.bufferedWriter(std.io.getStdOut().writer());
        var out = bufout.writer();

        self.reset();

        // Load history from board
        for (board.history.items) |state| {
            self.hash_history.append(state.zobrist_key) catch unreachable;
        }

        self.stop = false;
        self.searching = true;

        // Start a timer for reporting time taken
        self.search_timer = std.time.Timer.start() catch unreachable;

        const max: u8 = if (max_depth) |max| @max(max, 1) else max_ply - 2;
        var tdepth: u8 = 1;
        deepening: while (tdepth <= max) : (tdepth += 1) {
            self.ply = 0;

            const alpha = -heuristic.mate_score - 1;
            const beta = heuristic.mate_score + 1;
            var score = self.score;

            while (true) {
                self.depth = @max(self.depth, tdepth);

                score = self.negamax(
                    board,
                    color,
                    NodeType.Root,
                    tdepth,
                    alpha,
                    beta,
                );

                if (self.stop) {
                    break :deepening;
                } else {
                    self.score = score;
                    self.prev_best_move = self.best_move;
                }

                // TODO: here change alpha and beta when we do
                // stuff like aspiration windows
                break;
            }

            // Print info about the search
            if (!self.quiet) {
                out.print("info depth {} nodes {} time {} ", .{
                    tdepth,
                    self.nodes,
                    self.search_timer.read() / std.time.ns_per_ms,
                }) catch unreachable;

                if (heuristic.scoreAsMate(self.score)) |matein| {
                    out.print("score mate {}", .{matein}) catch unreachable;
                } else {
                    out.print("score cp {}", .{self.score}) catch unreachable;
                }
                out.writeByte('\n') catch unreachable;
                bufout.flush() catch unreachable;
            }

            if (self.shouldStop()) {
                break :deepening;
            }
        }

        if (!self.quiet) {
            out.print("bestmove {}\n", .{
                self.prev_best_move,
            }) catch unreachable;
            bufout.flush() catch unreachable;
        }

        self.searching = false;
        return;
    }

    /// Implementation of the negamax alghorithm for searching the best move.
    /// Negamax is an implementation of minimax that uses a single routine
    /// for both players. Considering that `color` is a comptime parameter
    /// when compiled this is actually 2 routines.
    /// More: https://www.chessprogramming.org/Negamax
    pub fn negamax(
        self: *Engine,
        board: *chess.Board,
        comptime color: bool,
        comptime node_type: NodeType,
        depth_: u8,
        alpha_: types.Score,
        beta_: types.Score,
    ) types.Score {
        // === STEP 1 - Preparation
        // - Check if we should stop
        // This is done every few nodes
        if (node_type != NodeType.Root and self.nodes & 2047 == 0 and self.shouldStop()) {
            self.stop = true;
            return 0;
        }

        // Depth 0 reached, proceed to quiescence
        if (depth_ == 0) {
            return self.quiescence(
                board,
                color,
                alpha_,
                beta_,
            );
        }

        const zobrist_key = board.state.zobrist_key;

        // - Add node
        // After this point we can consider this serched node
        self.nodes += 1;

        // - Check if the position is a draw
        if (node_type != NodeType.Root and self.isDraw(board)) {
            return 0;
        }

        // Convert into variables
        const depth = depth_;
        var alpha = alpha_;
        var beta = beta_;

        // === STEP 2 - Transposition
        // Save this move to use in move ordering
        var hashmove: u32 = 0;
        if (transposition.global_tt.probe(zobrist_key)) |res| {
            var score = res.score;
            // Adjust mate score
            // TODO do this only for exact?
            if (score > heuristic.max_score) {
                score -= self.ply;
            } else if (score < -heuristic.max_score) {
                score += self.ply;
            }

            hashmove = res.move;
            // Set bestmove if we are in root
            if (node_type == NodeType.Root) {
                self.best_move = chess.ChessMove{ .x = @as(usize, hashmove) };
            }

            // Use transposition score only if not root and depth is greater or equal to
            // the current
            if (node_type != NodeType.Root and res.depth >= depth_) {
                // Based on flag return score or set alpha/beta
                switch (res.flag) {
                    transposition.TranspositionFlag.Exact => {
                        return score;
                    },
                    transposition.TranspositionFlag.Alpha => {
                        alpha = @max(alpha, score);
                    },
                    transposition.TranspositionFlag.Beta => {
                        beta = @min(beta, score);
                    },
                    else => {},
                }
                // Fail hard
                if (alpha >= beta) {
                    return score;
                }
            }
        }

        // === STEP 3 - Search

        // Start with the worst possible evaluation
        var best_move = chess.ChessMove{};
        var best_score = -heuristic.mate_score + self.ply;

        // - Generate moves
        var movelist = chess.Movelist.new();
        board.generatePseudolegalMoves(chess.constants.MoveType.All, color, &movelist);

        // - Score moves
        movelist.scoreMoves(hashmove);

        var movesfound: usize = 0;

        // Iterate all moves
        while (movelist.pick()) |move| {
            // Make the move
            board.makeMove(move, color);
            // Undo if kind is attacked i.e. illegal move was made
            if (board.isKingAttacked(color)) {
                board.unmakeMove(color);
                continue;
            }

            movesfound += 1;

            // Increment ply, add to history, ecc..
            self.ply += 1;
            self.hash_history.append(zobrist_key) catch unreachable;

            // Evaluate the leaf
            const leaf_eval = -negamax(
                self,
                board,
                !color,
                NodeType.Other,
                depth - 1,
                -beta,
                -alpha,
            );

            // Undo stuff
            self.ply -= 1;
            _ = self.hash_history.pop();

            // Unmake move
            board.unmakeMove(color);

            // - Alpha Beta Pruning
            // We have found a better move
            if (leaf_eval > best_score) {
                best_score = leaf_eval;

                best_move = move;
                // If this is a root node, set best move
                if (node_type == NodeType.Root) {
                    self.best_move = move;
                }

                // If the eval surpasses alpha we have a new cutoff
                if (best_score > alpha) {
                    // If alpha surpasses beta we do not need to search
                    // other moves. This move will definitely be rejected
                    // by our opponent, even if we find a better one
                    // it does not matter
                    if (best_score >= beta) {
                        return beta;
                    }
                    alpha = best_score;
                }
            }
        }

        // - Stalemate or Checkmate
        // No move was found, if we are in check this is a checkmate
        // otherwhise is a stalemate
        if (movesfound == 0) {
            if (board.isKingAttacked(color)) {
                return best_score;
            } else {
                return 0;
            }
        }

        // Set transposition
        const flag = if (best_score >= beta) transposition.TranspositionFlag.Alpha else if (alpha != alpha_) transposition.TranspositionFlag.Exact else transposition.TranspositionFlag.Beta;
        transposition.global_tt.put(
            zobrist_key,
            depth,
            best_move,
            best_score,
            flag,
        );

        return best_score;
    }

    /// Execute a quiescence search
    /// This is useful to avoid the horizon effect where we end our search
    /// in a position that seems winning but is actually losing due to some
    /// tactic, like a capture or a check
    /// The objective is to make sure that we go to heuristic evalutation
    /// only if the position is quiet
    /// More: https://www.chessprogramming.org/Quiescence_Search
    fn quiescence(
        self: *Engine,
        board: *chess.Board,
        comptime color: bool,
        alpha_: types.Score,
        beta_: types.Score,
    ) types.Score {
        // === STEP 1 - Preparation
        // - Check if we should stop
        // This is done every few nodes
        if (self.nodes & 2047 == 0 and self.shouldStop()) {
            self.stop = true;
            return 0;
        }

        self.nodes += 1;

        // === STEP 2 - Preliminary checks and pruning

        // Make sure we do not go over the move limit
        if (self.ply >= max_ply) {
            return heuristic.evaluate(board, color);
        }

        // TODO: here we can evaluate if the position is a draw in material

        var alpha = alpha_;
        const beta = beta_;

        // Start with the worst possible evaluation
        // do this when we check if we are in check
        // var best_score = -heuristic.mate_score + self.ply;

        // - Standing Pat Pruning
        // Do a static evaluation this is used as a lower bound for the
        // evaluation This is usually ok becouse some move is usually better
        // than no move (unless we are in zugzwang)
        // When we implement better check evaluation only do this if we are
        // not in check
        var best_score = heuristic.evaluate(board, color);
        // If the score is already greater than the higher bound we fail hard
        if (best_score >= beta) {
            return beta;
        }
        if (best_score > alpha) {
            alpha = best_score;
        }

        // === STEP 3 - Transposition
        // Save this move to use in move ordering
        const zobrist_key = board.state.zobrist_key;
        var hashmove: u32 = 0;
        if (transposition.global_tt.probe(zobrist_key)) |res| {
            hashmove = res.move;
            var score = res.score;
            // Adjust mate score
            // TODO do this only for exact?
            if (score > heuristic.max_score) {
                score -= self.ply;
            } else if (score < -heuristic.max_score) {
                score += self.ply;
            }

            // Based on flag return score or set alpha/beta
            switch (res.flag) {
                transposition.TranspositionFlag.Exact => {
                    return score;
                },
                transposition.TranspositionFlag.Alpha => {
                    if (score >= beta) {
                        return score;
                    }
                },
                transposition.TranspositionFlag.Beta => {
                    if (score <= alpha) {
                        return score;
                    }
                },
                else => {},
            }
            // Fail hard
            if (alpha >= beta) {
                return score;
            }
        }

        // === STEP 4 - Search

        // - Generate moves
        // for now only captures
        var movelist = chess.Movelist.new();
        board.generatePseudolegalMoves(chess.constants.MoveType.Capture, color, &movelist);
        // TODO: try to generate checks and check defeces

        // - Score moves
        movelist.scoreMoves(hashmove);

        var movesfound: usize = 0;

        // Iterate all moves
        while (movelist.pick()) |move| {
            // Make the move
            board.makeMove(move, color);
            // Undo if kind is attacked i.e. illegal move was made
            if (board.isKingAttacked(color)) {
                board.unmakeMove(color);
                continue;
            }

            movesfound += 1;

            // Increment ply
            // Do not add to history because we do not care for it in quiescence
            self.ply += 1;

            // Evaluate the leaf
            const leaf_eval = -self.quiescence(
                board,
                !color,
                -beta,
                -alpha,
            );

            // Undo stuff
            self.ply -= 1;

            // Unmake move
            board.unmakeMove(color);

            // - Alpha Beta Pruning
            // We have found a better move
            if (leaf_eval > best_score) {
                best_score = leaf_eval;

                // If the eval surpasses alpha we have a new cutoff
                if (best_score > alpha) {
                    // If alpha surpasses beta we do not need to search
                    // other moves. This move will definitely be rejected
                    // by our opponent, even if we find a better one
                    // it does not matter
                    if (best_score >= beta) {
                        return beta;
                    }
                    alpha = best_score;
                }
            }
        }

        // - Stalemate or Checkmate
        // No move was found, if we are in check this is a checkmate
        // otherwhise is a stalemate
        if (movesfound == 0) {
            if (board.isKingAttacked(color)) {
                return -heuristic.mate_score + self.ply;
            } else {
                return 0;
            }
        }

        return best_score;
    }

    /// Check if the position is a draw
    fn isDraw(self: *Engine, board: *chess.Board) bool {
        // Check for 50 moves
        if (board.state.halfmove_clock >= 50) {
            return true;
        }

        // TODO: check material

        // Check for threefold repetition, for the engine even repeating
        // the move one time is considered a draw position
        // Impossible to have a 3 fold repetition before 6 ply
        if (self.hash_history.items.len >= 6) {
            var rep: bool = false;
            // Start from the top, is easier that we will find a repetition there
            var i: usize = self.hash_history.items.len - 3;
            // We need only to check until the last pawn move
            var limit: usize = 3;
            if (i > board.state.halfmove_clock + 1) {
                limit = @max(i - board.state.halfmove_clock - 1, 3);
            }
            // Count down by 2 given that the position must be of the right color
            while (i >= limit) : (i -= 2) {
                if (self.hash_history.items[i] == board.state.zobrist_key) {
                    if (!rep) {
                        rep = true;
                        continue;
                    } else {
                        return true;
                    }
                }
            }
        }

        return false;
    }
};
