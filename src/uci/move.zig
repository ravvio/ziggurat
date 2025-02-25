const std = @import("std");
const chess = @import("../chess.zig");
const Board = chess.Board;
const ChessMove = chess.ChessMove;
const ChessError = chess.ChessError;
const Square = chess.Square;
const pieces = chess.constants.pieces;

pub fn parseMove(b: *Board, uci: []const u8) ChessError!ChessMove {
    if (uci.len != 4 and uci.len != 5) {
        return ChessError.InvalidMove;
    }

    const from = try Square.fromAlgebraic(uci[0..2]);
    const to = try Square.fromAlgebraic(uci[2..4]);
    const promotion = if (uci.len == 5) try pieces.from(uci[5]) else pieces.NONE;

    if (promotion != pieces.NONE and !pieces.isPromotionPiece(promotion)) {
        return ChessError.InvalidPromotionPiece;
    }

    var ml = chess.Movelist(ChessMove).new();

    // Deterine if the move is pseudo legal
    b.isKindAttacked(
        b.state.current_side,
        chess.constants.MoveType.All,
        b,
        &ml,
    );

    var i: usize = 0;
    while (i < ml.count) : (i += 1) {
        var current = ml.list[i];
        // If the move from, to and promotion are the same
        // then we have found a valid move
        if (current.from() == from.x and current.to() == to.x and current.promotion() == promotion) {
            return current;
        }
    }
    // We have found nothing, the move is not legal
    return ChessError.NonPseudolegalMove;
}
