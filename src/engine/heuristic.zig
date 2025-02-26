const chess = @import("../chess.zig");
const types = @import("types.zig");

pub const mate_score: types.Score = 100_000;

pub fn scoreAsMate(score: types.Score) ?i64 {
    if (@abs(score) < 99_000) {
        return null;
    }
    return (@as(i64, @divTrunc((@as(i64, mate_score) - @abs(score)), 2))) //
    * @as(i64, if (score > 0) 1 else -1);
}

pub const material: [6][2]types.Score = .{
    .{ 0, 0 },
    .{ 1025, 936 },
    .{ 477, 512 },
    .{ 365, 297 },
    .{ 337, 281 },
    .{ 82, 94 },
};

pub fn evaluate(board: *chess.Board, comptime color: bool) types.Score {
    const i = @intFromBool(color);
    const j = @intFromBool(!color);

    var res: types.Score = 0;
    for (1..6) |piece| {
        const us = material[piece][0] * @popCount(board.boards[i][piece]);
        const op = material[piece][0] * @popCount(board.boards[j][piece]);
        res += us - op;
    }
    return res;
}
