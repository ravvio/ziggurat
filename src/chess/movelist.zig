const std = @import("std");
const assert = std.debug.assert;
const common = @import("constants.zig");
const ChessMove = @import("./chessmove.zig").ChessMove;

// Most Valuable Victim - Least Valuable Aggressor
// Table and helper values for generating move scores based on the
// value of a given caputure
// More: https://www.chessprogramming.org/MVV-LVA
const max_score: u8 = 255;
const mvv_lva_offset: u8 = 100;
const mvv_lva: [7][7]u8 = .{
    .{ 0, 0, 0, 0, 0, 0, 0 }, // victim K, attacker K, Q, R, B, N, P, None
    .{ 50, 51, 52, 53, 54, 55, 0 }, // victim Q, attacker K, Q, R, B, N, P, None
    .{ 40, 41, 42, 43, 44, 45, 0 }, // victim R, attacker K, Q, R, B, N, P, None
    .{ 30, 31, 32, 33, 34, 35, 0 }, // victim B, attacker K, Q, R, B, N, P, None
    .{ 20, 21, 22, 23, 24, 25, 0 }, // victim K, attacker K, Q, R, B, N, P, None
    .{ 10, 11, 12, 13, 14, 15, 0 }, // victim P, attacker K, Q, R, B, N, P, None
    .{ 0, 0, 0, 0, 0, 0, 0 }, // victim None, attacker K, Q, R, B, N, P, None
};

pub const Movelist = struct {
    list: [common.MAX_PSEUDO_MOVES]ChessMove,
    count: usize,

    pub fn new() Movelist {
        return .{
            .list = undefined,
            .count = 0,
        };
    }

    pub fn pop(self: *Movelist) ?ChessMove {
        if (self.count == 0) {
            return null;
        }
        self.count -= 1;
        return self.list[self.count];
    }

    pub fn add(self: *Movelist, item: ChessMove) void {
        assert(self.count < common.MAX_PSEUDO_MOVES);
        self.list[self.count] = item;
        self.count += 1;
    }

    pub fn swap(self: *Movelist, a: usize, b: usize) void {
        assert(a < self.count);
        assert(b < self.count);
        std.mem.swap(ChessMove, &self.list[a], &self.list[b]);
    }

    pub fn scoreMoves(self: *Movelist) void {
        var i: usize = 0;
        while (i < self.count) : (i += 1) {
            var move = &self.list[i];
            const score = mvv_lva[move.capture()][move.piece()];
            move.setSortScore(score);
        }
    }

    /// Find the most valuable moves between those that remain, move it
    /// to the end and pop it
    pub fn pick(self: *Movelist) ?ChessMove {
        if (self.count == 0) {
            return null;
        }
        for (0..self.count - 1) |i| {
            if (self.list[i].getSortScore() > self.list[self.count - 1].getSortScore()) {
                self.swap(i, self.count - 1);
                break;
            }
        }
        self.count -= 1;
        return self.list[self.count];
    }
};

test "swap" {
    var ml = Movelist.new();
    ml.add(ChessMove{ .x = 10 });
    ml.add(ChessMove{ .x = 20 });
    ml.swap(0, 1);
    try std.testing.expectEqual(20, ml.list[0].x);
    try std.testing.expectEqual(10, ml.list[1].x);
}
