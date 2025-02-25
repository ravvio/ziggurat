const std = @import("std");
const chess = @import("../chess.zig");
const types = @import("types.zig");
const heuristic = @import("heuristic.zig");

const NodeType = enum {
    Root,
    Other,
};

/// The Engine is the component responsible for finding the best move
pub const Engine = struct {
    /// Allocator provided to the engine
    allocator: std.mem.Allocator,
    /// The current best move found by the engine
    best_move: chess.ChessMove,
    /// The current eval of the engine
    eval: types.Eval,

    pub fn init(allocator: std.mem.Allocator) Engine {
        return .{
            .best_move = undefined,
            .eval = 0,
            .allocator = allocator,
        };
    }

    pub fn deinit(_: *Engine) void {
        // TODO
    }

    pub fn search(
        self: *Engine,
        board: *chess.Board,
        comptime color: bool,
        depth: i8,
    ) void {
        _ = self.negamax(
            board,
            color,
            NodeType.Root,
            depth,
            -heuristic.mate_score,
            heuristic.mate_score,
        );
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
        depth_: i8,
        alpha_: types.Eval,
        beta_: types.Eval,
    ) types.Eval {
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
        var best_eval = -heuristic.mate_score;

        // Generate moves
        var movelist = chess.Movelist(chess.ChessMove).new();
        board.generatePseudolegalMoves(chess.constants.MoveType.All, color, &movelist);

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
            const leaf_eval = -negamax(
                self,
                board,
                !color,
                NodeType.Other,
                depth - 1,
                -beta,
                -alpha,
            );

            // Unmake move
            board.unmakeMove(color);

            // If is better then continue the search
            if (leaf_eval > best_eval) {
                best_eval = leaf_eval;
                // If is better then alpha then we have a new beta cutoff for our opponent
                if (best_eval > alpha) {
                    alpha = best_eval;
                    // Set best move and best eval if we are at root
                    if (node_type == NodeType.Root) {
                        self.eval = best_eval;
                        self.best_move = move;
                    }
                }
            }
            // Fail-soft, we have surpassed the cutoff set by our opponent,
            // we will never get to play this move
            if (leaf_eval >= beta) {
                break;
            }
        }

        return best_eval;
    }
};
