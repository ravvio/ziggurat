const movegen = @import("./movegen.zig");
const chess = @import("./chess.zig");
const pieces = chess.constants.pieces;

/// Checks if the king of the player to move is attacked.
/// If it is the position is illegal
pub fn isKingAttacked(
    color: bool,
    mg: *const movegen.MoveGenTables,
    board: *const chess.Board,
) bool {
    const occupied = board.occupied;
    const attacker = @intFromBool(!color);
    const sq = @ctz(board.boards[@intFromBool(color)][pieces.KING]);

    return (board.boards[attacker][pieces.QUEEN] & mg.queenAttacks(sq, occupied) != 0 or
        board.boards[attacker][pieces.ROOK] & mg.rookAttacks(sq, occupied) != 0 or
        board.boards[attacker][pieces.BISHOP] & mg.bishopAttacks(sq, occupied) != 0 or
        board.boards[attacker][pieces.KNIGHT] & mg.knightAttacks(sq) != 0 or
        board.boards[attacker][pieces.PAWN] & mg.pawnAttacks(color, sq) != 0);
}
