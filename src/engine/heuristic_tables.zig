const std = @import("std");
const types = @import("types.zig");
const chess = @import("../chess.zig");
const bitboard = chess.bitboard;

/// Material value in the middlegame
const mg_material: [6]types.Score = .{ 0, 1025, 477, 365, 337, 82 };
/// Material value in the endgame
const eg_material: [6]types.Score = .{ 0, 936, 512, 297, 281, 94 };

// PeSTO Tables
// More: https://www.chessprogramming.org/PeSTO%27s_Evaluation_Function

/// Piece-Square value in the middlegame
const mg_pst: [6][64]types.Score = .{
    // KING
    .{
        -65, 23,  16,  -15, -56, -34, 2,   13,
        29,  -1,  -20, -7,  -8,  -4,  -38, -29,
        -17, -20, -12, -27, -30, -25, -14, -36,
        -49, -1,  -27, -39, -46, -44, -33, -51,
        -9,  24,  2,   -16, -20, 6,   22,  -22,
        -14, -14, -22, -46, -44, -30, -15, -27,
        1,   7,   -8,  -64, -43, -16, 9,   8,
        -15, 36,  12,  -54, 8,   -28, 24,  14,
    },
    // QUEEN
    .{
        -28, 0,   29,  12,  59,  44,  43,  45,
        -24, -39, -5,  1,   -16, 57,  28,  54,
        -27, -27, -16, -16, -1,  17,  -2,  1,
        -9,  -26, -9,  -10, -2,  -4,  3,   -3,
        -13, -17, 7,   8,   29,  56,  47,  57,
        -14, 2,   -11, -2,  -5,  2,   14,  5,
        -35, -8,  11,  2,   8,   15,  -3,  1,
        -1,  -18, -9,  10,  -15, -25, -31, -50,
    },
    // ROOK
    .{
        32,  42,  32,  51,  63, 9,  31,  43,
        27,  32,  58,  62,  80, 67, 26,  44,
        -24, -11, 7,   26,  24, 35, -8,  -20,
        -36, -26, -12, -1,  9,  -7, 6,   -23,
        -5,  19,  26,  36,  17, 45, 61,  16,
        -45, -25, -16, -17, 3,  0,  -5,  -33,
        -44, -16, -20, -9,  -1, 11, -6,  -71,
        -19, -13, 1,   17,  16, 7,  -37, -26,
    },
    // BISHOP
    .{
        -29, 4,  -82, -37, -25, -42, 7,   -8,
        -26, 16, -18, -13, 30,  59,  18,  -47,
        -4,  5,  19,  50,  37,  37,  7,   -2,
        -6,  13, 13,  26,  34,  12,  10,  4,
        -16, 37, 43,  40,  35,  50,  37,  -2,
        0,   15, 15,  15,  14,  27,  18,  10,
        4,   15, 16,  0,   7,   21,  33,  1,
        -33, -3, -14, -21, -13, -12, -39, -21,
    },
    // KNIGHT
    .{
        -58, -38, -13, -28, -31, -27, -63, -99,
        -25, -8,  -25, -2,  -9,  -25, -24, -52,
        -17, 3,   22,  22,  22,  11,  8,   -18,
        -18, -6,  16,  25,  16,  17,  4,   -18,
        -24, -20, 10,  9,   -1,  -9,  -19, -41,
        -23, -3,  -1,  15,  10,  -3,  -20, -22,
        -42, -20, -10, -5,  -2,  -20, -23, -44,
        -29, -51, -23, -15, -22, -18, -50, -64,
    },
    // PAWN
    .{
        0,   0,   0,   0,   0,   0,   0,  0,
        98,  134, 61,  95,  68,  126, 34, -11,
        -14, 13,  6,   21,  23,  12,  17, -23,
        -27, -2,  -5,  12,  17,  6,   10, -25,
        -6,  7,   26,  31,  65,  56,  25, -20,
        -26, -4,  -4,  -10, 3,   3,   33, -12,
        -35, -1,  -20, -23, -15, 24,  38, -22,
        0,   0,   0,   0,   0,   0,   0,  0,
    },
};

const eg_pst: [6][64]types.Score = .{
    .{ // KING
        -74, -35, -18, -18, -11, 15,  4,   -17,
        -12, 17,  14,  17,  17,  38,  23,  11,
        -8,  22,  24,  27,  26,  33,  26,  3,
        -18, -4,  21,  24,  27,  23,  9,   -11,
        10,  17,  23,  15,  20,  45,  44,  13,
        -19, -3,  11,  21,  23,  16,  7,   -9,
        -27, -11, 4,   13,  14,  4,   -5,  -17,
        -53, -34, -21, -11, -28, -14, -24, -43,
    },
    .{ // QUEEN
        -9,  22,  22,  27,  27,  19,  10,  20,
        -17, 20,  32,  41,  58,  25,  30,  0,
        3,   22,  24,  45,  57,  40,  57,  36,
        -18, 28,  19,  47,  31,  34,  39,  23,
        -20, 6,   9,   49,  47,  35,  19,  9,
        -16, -27, 15,  6,   9,   17,  10,  5,
        -22, -23, -30, -16, -16, -23, -36, -32,
        -33, -28, -22, -43, -5,  -32, -20, -41,
    },
    .{ // ROOK
        13, 10, 18, 15, 12, 12,  8,   5,
        11, 13, 13, 11, -3, 3,   8,   3,
        4,  3,  13, 1,  2,  1,   -1,  2,
        3,  5,  8,  4,  -5, -6,  -8,  -11,
        7,  7,  7,  5,  4,  -3,  -5,  -3,
        -4, 0,  -5, -1, -7, -12, -8,  -16,
        -6, -6, 0,  2,  -9, -9,  -11, -3,
        -9, 2,  3,  -1, -5, -13, 4,   -20,
    },
    .{ // BISHOP
        -14, -21, -11, -8,  -7, -9,  -17, -24,
        -8,  -4,  7,   -12, -3, -13, -4,  -14,
        -3,  9,   12,  9,   14, 10,  3,   2,
        -6,  3,   13,  19,  7,  10,  -3,  -9,
        2,   -8,  0,   -1,  -2, 6,   0,   4,
        -12, -3,  8,   10,  13, 3,   -7,  -15,
        -14, -18, -7,  -1,  4,  -9,  -15, -27,
        -23, -9,  -23, -5,  -9, -16, -5,  -17,
    },
    .{ // KNIGHT
        -58, -38, -13, -28, -31, -27, -63, -99,
        -25, -8,  -25, -2,  -9,  -25, -24, -52,
        -17, 3,   22,  22,  22,  11,  8,   -18,
        -18, -6,  16,  25,  16,  17,  4,   -18,
        -24, -20, 10,  9,   -1,  -9,  -19, -41,
        -23, -3,  -1,  15,  10,  -3,  -20, -22,
        -42, -20, -10, -5,  -2,  -20, -23, -44,
        -29, -51, -23, -15, -22, -18, -50, -64,
    },
    .{ // PAWN
        0,   0,   0,   0,   0,   0,   0,   0,
        178, 173, 158, 134, 147, 132, 165, 187,
        94,  100, 85,  67,  56,  53,  82,  84,
        32,  24,  13,  5,   -2,  4,   17,  17,
        13,  9,   -3,  -7,  -7,  -8,  3,   -1,
        4,   7,   -6,  1,   0,   -5,  -1,  -8,
        13,  8,   8,   10,  13,  0,   2,   -7,
        0,   0,   0,   0,   0,   0,   0,   0,
    },
};

pub const mirror: [64]types.Score = .{
    56, 57, 58, 59, 60, 61, 62, 63,
    48, 49, 50, 51, 52, 53, 54, 55,
    40, 41, 42, 43, 44, 45, 46, 47,
    32, 33, 34, 35, 36, 37, 38, 39,
    24, 25, 26, 27, 28, 29, 30, 31,
    16, 17, 18, 19, 20, 21, 22, 23,
    8,  9,  10, 11, 12, 13, 14, 15,
    0,  1,  2,  3,  4,  5,  6,  7,
};

/// Vecotrized piece value table
pub const piece_value: [2][6][64]@Vector(2, types.Score) = compute: {
    var res: [2][6][64]@Vector(2, types.Score) = undefined;
    for (0..6) |piece| {
        for (0..64) |sq| {
            const w = sq;
            const b = mirror[sq];

            res[0][piece][sq] = .{
                mg_material[piece] + mg_pst[piece][b],
                eg_material[piece] + eg_pst[piece][b],
            };
            res[1][piece][sq] = .{
                mg_material[piece] + mg_pst[piece][w],
                eg_material[piece] + eg_pst[piece][w],
            };
        }
    }
    break :compute res;
};

/// Table from stockfish: https://www.chessprogramming.org/King_Safety
pub const safety: [100]types.Score = .{
    0,   0,   1,   2,   3,   5,   7,   9,   12,  15,
    18,  22,  26,  30,  35,  39,  44,  50,  56,  62,
    68,  75,  82,  85,  89,  97,  105, 113, 122, 131,
    140, 150, 169, 180, 191, 202, 213, 225, 237, 248,
    260, 272, 283, 295, 307, 319, 330, 342, 354, 366,
    377, 389, 401, 412, 424, 436, 448, 459, 471, 483,
    494, 500, 500, 500, 500, 500, 500, 500, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 500, 500,
};

pub const protected_pawn_scores: [64]types.Score = .{
    0, 0, 0,  0,  0,   0, 0, 0,
    8, 8, 12, 14, 14, 12, 8, 8,
    8, 8, 12, 14, 14, 12, 8, 8,
    8, 8, 12, 14, 14, 12, 8, 8,
    8, 8, 12, 14, 14, 12, 8, 8,
    8, 8, 12, 14, 14, 12, 8, 8,
    8, 8, 12, 14, 14, 12, 8, 8,
    0, 0,  0,  0,  0,  0, 0, 0,
};

pub const double_pawn_score: types.Score = -8;
pub const isolated_pawn_score: types.Score = -6;

pub const vec_mul_2 = @Vector(2, u64){ 2, 2 };
pub const vec_mul_3 = @Vector(2, u64){ 3, 3 };
pub const vec_mul_4 = @Vector(2, u64){ 4, 4 };
pub const vec_mul_5 = @Vector(2, u64){ 5, 5 };

pub const king_zones: [2][64]u64 = blk: {
    @setEvalBranchQuota(10_000);
    break :blk initKingZones();
};

pub const pawn_files: [8]u64 = .{
    bitboard.FILE_A | bitboard.FILE_B,
    bitboard.FILE_A | bitboard.FILE_B | bitboard.FILE_C,
    bitboard.FILE_B | bitboard.FILE_C | bitboard.FILE_D,
    bitboard.FILE_C | bitboard.FILE_D | bitboard.FILE_E,
    bitboard.FILE_D | bitboard.FILE_E | bitboard.FILE_F,
    bitboard.FILE_E | bitboard.FILE_F | bitboard.FILE_G,
    bitboard.FILE_F | bitboard.FILE_G | bitboard.FILE_H,
    bitboard.FILE_G | bitboard.FILE_H,
};

pub const double_pawn_masks: [2][64]u64 = blk: {
    var res: [2][64]u64 = undefined;

    for (chess.Square.ALL_SQUARES) |sq| {
        const file = sq.file();
        const rank = sq.rank();

        var rank_mask_b = 0;
        var rank_mask_w = 0;

        for (0..8) |r| {
            if (r > rank) {
                rank_mask_w |= bitboard.RANKS[r];
            } else if (r < rank) {
                rank_mask_b |= bitboard.RANKS[r];
            }
        }

        res[0][sq.x] = bitboard.FILES[file] & rank_mask_b;
        res[1][sq.x] = bitboard.FILES[file] & rank_mask_w;
    }

    break :blk res;
};

pub const isolated_pawn_masks: [64]u64 = blk: {
    var res: [64]u64 = undefined;

    for (chess.Square.ALL_SQUARES) |sq| {
        const file = sq.file();
        if (file != 0) {
            res[sq.x] |= bitboard.FILES[file - 1];
        }
        if (file != 7) {
            res[sq.x] |= bitboard.FILES[file + 1];
        }
    }

    break :blk res;
};

fn goNord(orgin: chess.Square, n: usize) u64 {
    var sq = orgin;
    var res = chess.bitboard.SQUARES[sq.x];
    for (0..n) |_| {
        if (sq.rank() == 0) {
            break;
        }
        sq = chess.Square.nord(sq);
        res |= chess.bitboard.SQUARES[sq.x];
    }
    return res;
}

fn goSouth(origin: chess.Square, n: usize) u64 {
    var sq = origin;
    var res = chess.bitboard.SQUARES[sq.x];
    for (0..n) |_| {
        if (sq.rank() == 7) {
            break;
        }
        sq = chess.Square.sud(sq);
        res |= chess.bitboard.SQUARES[sq.x];
    }
    return res;
}

pub fn initKingZones() [2][64]u64 {
    var res = std.mem.zeroes([2][64]u64);

    for (0..64) |sq| {
        const origin = chess.Square.ALL_SQUARES[sq];
        const zone = chess.tables.kingAttacks(sq);

        var w_zone = zone | goNord(origin, 3);
        var b_zone = zone | goSouth(origin, 3);
        if (origin.file() != 0) {
            w_zone |= goNord(chess.Square.west(origin), 3);
            b_zone |= goSouth(chess.Square.west(origin), 3);
        }
        if (origin.file() != 7) {
            w_zone |= goNord(chess.Square.east(origin), 3);
            b_zone |= goSouth(chess.Square.east(origin), 3);
        }
        res[0][sq] = b_zone;
        res[1][sq] = w_zone;
    }
    return res;
}
