const std = @import("std");
const chess = @import("../chess.zig");
const constants = chess.constants;
const Colors = constants.Colors;
const types = @import("types.zig");
const tables = @import("heuristic_tables.zig");
const pawn_hashtable = @import("pawn_hashtable.zig");

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

const mobility_piece_factors: [6]f64 = [6]f64{
    -0.2, // King
    1.0, // Queen
    1.0, // Rook
    1.2, // Bishop
    1.1, // Knight
    0.2, // Pawn
};

const mobility_scores: [6][29]types.Score = blk: {
    @setEvalBranchQuota(1_000);
    var res = std.mem.zeroes([6][29]types.Score);
    for (0..29) |i| {
        const log = 0.8 * std.math.log(
            f64,
            std.math.e,
            @as(f64, @floatFromInt(1 + i)),
        );
        for (0..6) |p| {
            res[p][i] = @intFromFloat(log * mobility_piece_factors[p]);
        }
    }
    break :blk res;
};

const gamephase_increments: [6]types.Score = .{ 0, 4, 2, 1, 1, 0 };

pub fn evaluate(board: *chess.Board, comptime color: bool) types.Score {
    const sign = if (color) 1 else -1;
    var gamephase: types.Score = 0;
    var res: @Vector(2, types.Score) = .{ 0, 0 };

    var white_targets = std.mem.zeroes([6]u64);
    var black_targets = std.mem.zeroes([6]u64);

    var pieces_bb: u64 = 0;

    const occupied = board.colors[0] | board.colors[1];

    var mobility_score: types.Score = 0;

    inline for (0..6) |piece| {
        // Black
        pieces_bb = board.bitboard(Colors.black, piece);
        while (pieces_bb != 0) {
            const sq = chess.bitboard.pop(&pieces_bb);
            res -= tables.piece_value[Colors.ublack][piece][sq];
            gamephase += gamephase_increments[piece];

            const attacks = chess.tables.pieceAttacks(color, piece, sq, occupied);
            mobility_score -= mobility_scores[piece][@popCount(attacks)];
            black_targets[piece] |= attacks;
        }
        // White
        pieces_bb = board.bitboard(Colors.white, piece);
        while (pieces_bb != 0) {
            const sq = chess.bitboard.pop(&pieces_bb);
            res += tables.piece_value[Colors.uwhite][piece][sq];
            gamephase += gamephase_increments[piece];

            const attacks = chess.tables.pieceAttacks(color, piece, sq, occupied);
            mobility_score -= mobility_scores[piece][@popCount(attacks)];
            white_targets[piece] |= attacks;
        }
    }

    const middlegame_phase = if (gamephase > 24) 24 else gamephase;
    const endgame_phase = 24 - middlegame_phase;

    const mg, const eg = res;
    var final = @divTrunc((middlegame_phase * mg) + (endgame_phase * eg), 24);

    final += mobility_score;
    final += computeKingSafety(board, &white_targets, &black_targets);
    // final += computePawnStructure(board);
    return sign * final;
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
    attack_counters += tables.vec_mul_2 * @popCount(@Vector(2, u64){ black_targets[1], white_targets[1] } & zones);
    attack_counters += tables.vec_mul_3 * @popCount(@Vector(2, u64){ black_targets[2], white_targets[2] } & zones);
    // Rook
    attack_counters += tables.vec_mul_4 * @popCount(@Vector(2, u64){ black_targets[3], white_targets[3] } & zones);
    // Queen
    attack_counters += @popCount(@Vector(2, u64){ black_targets[4], white_targets[4] } & zones);

    var bc, var wc = attack_counters;

    if (wc > 99) {
        wc = 99;
    }
    if (bc > 99) {
        bc = 99;
    }

    return tables.safety[wc] - tables.safety[bc];
}

pub fn computePawnStructure(board: *const chess.Board) types.Score {
    // Check hashtable
    if (pawn_hashtable.global_pt.probe(board.state.pawn_structure_key)) |s| {
        return s.score;
    }

    const black_pawns = board.pawns(Colors.black);
    const white_pawns = board.pawns(Colors.white);

    var score: types.Score = 0;
    var passed_b: usize = 0;
    var passed_w: usize = 0;

    var black_pawns_it = black_pawns;
    while (black_pawns_it != 0) {
        const sq = chess.bitboard.pop(&black_pawns_it);

        if (black_pawns & tables.double_pawn_masks[0][sq] == 0) {
            score -= tables.double_pawn_value;
            continue;
        }
        if (white_pawns & tables.passed_pawn_masks[0][sq] == 0 and black_pawns & tables.double_pawn_masks[1][sq] == 0) {
            passed_b += 1;
        }
    }

    var white_pawns_it = white_pawns;
    while (white_pawns_it != 0) {
        const sq = chess.bitboard.pop(&white_pawns_it);
        if (white_pawns & tables.double_pawn_masks[1][sq] == 0) {
            score += tables.double_pawn_value;
            continue;
        }
        if (black_pawns & tables.passed_pawn_masks[1][sq] == 0 and white_pawns & tables.double_pawn_masks[0][sq] == 0) {
            passed_w += 1;
        }
    }

    score += tables.passed_pawn_values[passed_w] - tables.passed_pawn_values[passed_b];

    // Store score
    pawn_hashtable.global_pt.put(board.state.pawn_structure_key, score);

    return score;
}
