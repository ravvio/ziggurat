const chess = @import("../chess.zig");
const types = @import("types.zig");
const tables = @import("heuristic_tables.zig");

pub const mate_score: types.Score = 100_000;
pub const max_score: types.Score = 99_000;

pub fn scoreAsMate(score: types.Score) ?i64 {
    if (@abs(score) < max_score) {
        return null;
    }
    return (@as(i64, @divTrunc((@as(i64, mate_score) - @abs(score)), 2) + 1)) //
    * @as(i64, if (score > 0) 1 else -1);
}

const gamephase_increments: [6]types.Score = .{ 0, 4, 2, 1, 1, 0 };

pub fn evaluate(board: *chess.Board, comptime color: bool) types.Score {
    const sign = if (color) 1 else -1;

    var gamephase: types.Score = 0;

    var mg_b: types.Score = 0;
    var mg_w: types.Score = 0;

    var eg_b: types.Score = 0;
    var eg_w: types.Score = 0;

    for (0..6) |piece| {
        // black
        var it = chess.bitboard.BitboardIterator.new(board.boards[0][piece]);
        while (it.next()) |sq| {
            mg_b += tables.mg_piece_value[0][piece][sq];
            eg_b += tables.eg_piece_value[0][piece][sq];
            gamephase += gamephase_increments[piece];
        }
        // white
        it = chess.bitboard.BitboardIterator.new(board.boards[1][piece]);
        while (it.next()) |sq| {
            mg_w += tables.mg_piece_value[1][piece][sq];
            eg_w += tables.eg_piece_value[1][piece][sq];
            gamephase += gamephase_increments[piece];
        }
    }

    const middlegame_phase = if (gamephase > 24) 24 else gamephase;
    const endgame_phase = 24 - middlegame_phase;

    return sign * (middlegame_phase * (mg_w - mg_b) + endgame_phase * (eg_w - eg_b));
}
