const tables = @import("./movegen.zig").tables;
const chess = @import("./chess.zig");
const pieces = chess.constants.pieces;

/// Checks if the king of the player to move is attacked.
/// If it is the position is illegal
pub fn isKingAttacked(
    color: bool,
    board: *const chess.Board,
) bool {
    const occupied = board.colors[0] | board.colors[1];
    const attacker = @intFromBool(!color);
    const sq = @ctz(board.boards[@intFromBool(color)][pieces.KING]);

    return (board.boards[attacker][pieces.QUEEN] & tables.queenAttacks(sq, occupied) != 0 or
        board.boards[attacker][pieces.ROOK] & tables.rookAttacks(sq, occupied) != 0 or
        board.boards[attacker][pieces.BISHOP] & tables.bishopAttacks(sq, occupied) != 0 or
        board.boards[attacker][pieces.KNIGHT] & tables.knightAttacks(sq) != 0 or
        board.boards[attacker][pieces.PAWN] & tables.pawnAttacks(color, sq) != 0);
}
