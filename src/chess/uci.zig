const std = @import("std");
const Board = @import("board.zig").Board;
const ChessMove = @import("chessmove.zig").ChessMove;
const ChessError = @import("errors.zig").ChessError;
const Square = @import("square.zig").Square;
const pieces = @import("constants.zig").pieces;

pub fn moveFromUci(
    b: *Board,
    uci: *const []u8
) ChessError!ChessMove {
   if (uci.len != 4 and uci.len != 5) {
       return ChessError.InvalidMove;
   }

   const from = try Square.fromAlgebraic(&uci[0..2]);
   const to = try Square.fromAlgebraic(&uci[2..4]);
   const promotion = if (uci.len == 5) pieces.from(uci[5]) else pieces.NONE;

   if (promotion != pieces.NONE and !pieces.isPromotionPiece(promotion)) {
       return ChessError.InvalidPromotionPiece;
   }

   // Deterine if the move is pseudo legal

}
