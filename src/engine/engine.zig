const std = @import("std");
const chess = @import("../chess.zig");
const types = @import("types.zig");
const heuristic = @import("heuristic.zig");

const NodeType = enum {
    Root,
    Other,
};

const max_ply: u8 = 128;

/// The Engine is the component responsible for finding the best move
pub const Engine = struct {
    /// Allocator provided to the engine
    allocator: std.mem.Allocator,
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

    pub fn init(allocator: std.mem.Allocator) Engine {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(_: *Engine) void {
        // TODO
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

        self.stop = false;
        self.searching = true;
        self.nodes = 0;
        self.best_move = chess.ChessMove{};

        // Start a timer for reporting time taken
        self.search_timer = std.time.Timer.start() catch unreachable;

        const max: u8 = if (max_depth) |max| max else max_ply - 2;
        var tdepth: u8 = 1;
        deepening: while (tdepth <= max) : (tdepth += 1) {
            self.ply = 1;

            const alpha = -heuristic.mate_score;
            const beta = heuristic.mate_score;
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
        // 1.1 - Check if we should stop
        // This is done every few nodes
        if (self.nodes & 2047 == 0 and self.shouldStop()) {
            self.stop = true;
            return 0;
        }

        // 1.2 - Add node
        // After this point we can consider this serched node
        self.nodes += 1;

        // We make use of alpha beta pruning for not searching moves that
        // would surely be discarded by our opponent.
        const depth = depth_;
        var alpha = alpha_;
        const beta = beta_;

        // Depth 0 reached, proceed to static evaluation
        if (depth == 0) {
            return heuristic.evaluate(board, color);
        }

        // Start with the worst possible evaluation
        var best_eval = -heuristic.mate_score + self.ply;

        // Generate moves
        var movelist = chess.Movelist(chess.ChessMove).new();
        board.generatePseudolegalMoves(chess.constants.MoveType.All, color, &movelist);

        // - Stalemate or Checkmate
        // No move was found, if we are in check this is a checkmate
        // otherwhise is a stalemate
        if (movelist.count == 0) {
            if (board.isKingAttacked(color)) {
                return best_eval;
            } else {
                return 0;
            }
        }

        // Iterate all moves
        while (movelist.pop()) |move| {
            // Make the move
            board.makeMove(move, color);
            // Undo if kind is attacked i.e. illegal move was made
            if (board.isKingAttacked(color)) {
                board.unmakeMove(color);
                continue;
            }
            // Evaluate the leaf
            self.ply += 1;
            const leaf_eval = -negamax(
                self,
                board,
                !color,
                NodeType.Other,
                depth - 1,
                -beta,
                -alpha,
            );
            self.ply -= 1;

            // Unmake move
            board.unmakeMove(color);

            // === Alpha Beta Pruning ===
            // We have found a better move
            if (leaf_eval > best_eval) {
                best_eval = leaf_eval;

                // If this is a root node, set best move
                // TODO: if i am not mistaken we can remove
                // the next if in this case (i.e. use an else if)
                if (node_type == NodeType.Root) {
                    self.best_move = move;
                }

                // If the eval surpasses alpha we have a new cutoff
                if (best_eval > alpha) {
                    alpha = best_eval;
                    // If alpha surpasses beta we do not need to search
                    // other moves. This move will definitely be rejected
                    // by our opponent, even if we find a better one
                    // it does not matter
                    if (alpha > beta) {
                        break;
                    }
                }
            }
        }

        return best_eval;
    }
};
