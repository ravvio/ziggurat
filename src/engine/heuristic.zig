const chess = @import("../chess.zig");
const types = @import("types.zig");

pub const mate_score: types.Eval = 100_000;

pub const material: [6][2]types.Eval = .{
    .{ 0, 0 },
    .{ 1025, 936 },
    .{ 477, 512 },
    .{ 365, 297 },
    .{ 337, 281 },
    .{ 82, 94 },
};

pub fn evaluate(board: *chess.Board, comptime color: bool) types.Eval {
    const i = @intFromBool(color);
    const j = @intFromBool(!color);

    var res: types.Eval = 0;
    for (1..6) |piece| {
        const us = material[piece][0] * @popCount(board.boards[i][piece]);
        const op = material[piece][0] * @popCount(board.boards[j][piece]);
        res += us - op;
    }
    return res;
}
