const std = @import("std");
const chess = @import("../chess.zig");
const types = @import("types.zig");
const tables = @import("heuristic_tables.zig");

const pieces = chess.constants.pieces;

pub const mate_score: types.Score = 100_000;
pub const max_score: types.Score = 99_000;
pub const max_mate: u32 = 256;

pub fn scoreAsMate(score: types.Score) ?i64 {
    if (@abs(score) < max_score) {
        return null;
    }
    return (@as(i64, @divTrunc((@as(i64, mate_score) - @abs(score)), 2))) //
    * @as(i64, if (score > 0) 1 else -1);
}

const gamephase_increments: [6]types.Score = .{ 0, 4, 2, 1, 1, 0 };

pub fn evaluate(board: *chess.Board, comptime color: bool) types.Score {
    const sign = if (color) 1 else -1;
    var gamephase: types.Score = 0;

    var res: @Vector(2, types.Score) = .{ 0, 0 };

    var passed_pawns_b: usize = 0;
    var passed_pawns_w: usize = 0;

    var white_targets = std.mem.zeroes([6]u64);
    var black_targets = std.mem.zeroes([6]u64);

    inline for (0..6) |piece| {
        // Black
        var it = chess.bitboard.BitboardIterator.new(board.boards[0][piece]);
        while (it.next()) |sq| {
            res -= tables.piece_value[0][piece][sq];
            gamephase += gamephase_increments[piece];
            black_targets[piece] |= chess.tables.pieceAttacks(color, piece, sq, board.occupied);

            // Pawn structure
            if (piece == pieces.PAWN) {
                // Is passed pawn
                const passed = (tables.passed_pawn_zones[0][sq] & board.boards[1][pieces.PAWN]) == 0;
                if (passed) {
                    passed_pawns_b += 1;
                }
            }

        }
        // White
        it = chess.bitboard.BitboardIterator.new(board.boards[1][piece]);
        while (it.next()) |sq| {
            res += tables.piece_value[1][piece][sq];
            gamephase += gamephase_increments[piece];
            white_targets[piece] |= chess.tables.pieceAttacks(color, piece, sq, board.occupied);

            // Pawn structure
            if (piece == pieces.PAWN) {
                // Is passed pawn
                const passed = (tables.passed_pawn_zones[1][sq] & board.boards[0][pieces.PAWN]) == 0;
                if (passed) {
                    passed_pawns_w += 1;
                }
            }
        }
    }

    const middlegame_phase = if (gamephase > 24) 24 else gamephase;
    const endgame_phase = 24 - middlegame_phase;
    const mg, const eg = res;

    // Pawn structure
    // More important in the end game
    const pawn_structure =
        (1 + eg) * (tables.passed_pawns_values[passed_pawns_w] - tables.passed_pawns_values[passed_pawns_b]);

    const psq_and_ps = @divTrunc( (middlegame_phase * mg) + (endgame_phase * eg) + pawn_structure, 24);

    const king_safety = computeKingSafety(board, &white_targets, &black_targets);

    return sign * (psq_and_ps + king_safety);
}

pub fn computeKingSafety(
    board: *const chess.Board,
    white_targets: *const [6]u64,
    black_targets: *const [6]u64,
) types.Score {
    // How strong is the attack of each side
    var attack_counters = @Vector(2, u64){ 0, 0 };

    const zones = @Vector(2, u64){
        // White
        tables.king_zones[1][@ctz(board.boards[1][chess.constants.pieces.KING])],
        // Black
        tables.king_zones[0][@ctz(board.boards[0][chess.constants.pieces.KING])],
    };

    // Knight and bishop
    attack_counters += tables.vec_mul_2 * @popCount(
        @Vector(2, u64){ black_targets[1], white_targets[1] } & zones
    );
    attack_counters += tables.vec_mul_3 * @popCount(
        @Vector(2, u64){ black_targets[2], white_targets[2] } & zones
    );
    // Rook
    attack_counters += tables.vec_mul_4 * @popCount(
        @Vector(2, u64){ black_targets[3], white_targets[3] } & zones
    );
    // Queen
    attack_counters += @popCount(
        @Vector(2, u64){ black_targets[4], white_targets[4] } & zones
    );

    var bc, var wc = attack_counters;

    if (wc > 99) {
        wc = 99;
    }
    if (bc > 99) {
        bc = 99;
    }

    return tables.safety[wc] - tables.safety[bc];
}
