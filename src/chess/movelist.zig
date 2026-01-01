const std = @import("std");
const assert = std.debug.assert;
const constants = @import("constants.zig");
const pieces = constants.pieces;
const ChessMove = @import("./chessmove.zig").ChessMove;

const max_score: u8 = 255;
const killer_score_1: u8 = 250;
const killer_score_2: u8 = 245;
const promotion_score: u8 = 100;
// Most Valuable Victim - Least Valuable Aggressor
// Table and helper values for generating move scores based on the
// value of a given caputure
// More: https://www.chessprogramming.org/MVV-LVA
const mvv_lva: [7][7]u8 = .{
    .{ 0, 0, 0, 0, 0, 0, 0 }, // victim K, attacker K, Q, R, B, N, P, None
    .{ 50, 51, 52, 53, 54, 55, 0 }, // victim Q, attacker K, Q, R, B, N, P, None
    .{ 40, 41, 42, 43, 44, 45, 0 }, // victim R, attacker K, Q, R, B, N, P, None
    .{ 30, 31, 32, 33, 34, 35, 0 }, // victim B, attacker K, Q, R, B, N, P, None
    .{ 20, 21, 22, 23, 24, 25, 0 }, // victim N, attacker K, Q, R, B, N, P, None
    .{ 10, 11, 12, 13, 14, 15, 0 }, // victim P, attacker K, Q, R, B, N, P, None
    .{ 1, 2, 3, 4, 5, 6, 0 }, // victim None, attacker K, Q, R, B, N, P, None
};

pub const Movelist = struct {
    list: [constants.MAX_PSEUDO_MOVES]ChessMove,
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
        assert(self.count < constants.MAX_PSEUDO_MOVES);
        self.list[self.count] = item;
        self.count += 1;
    }

    pub fn swap(self: *Movelist, a: usize, b: usize) void {
        assert(a < self.count);
        assert(b < self.count);
        std.mem.swap(ChessMove, &self.list[a], &self.list[b]);
    }

    pub fn scoreMoves(self: *Movelist, hashmove: u32) void {
        var i: usize = 0;
        while (i < self.count) : (i += 1) {
            var move = &self.list[i];

            // Order hash move first, then killers, then captures finally quiets
            if (@as(u32, @truncate(move.*.x)) == hashmove) {
                move.setSortScore(max_score);
            } else {
                var score = mvv_lva[move.capture()][move.piece()];
                if (move.is_promotion()) {
                    score += promotion_score;
                }
                move.setSortScore(score);
            }
        }
    }

    pub fn scoreMovesWithKillers(self: *Movelist, hashmove: u32, killer1: ChessMove, killer2: ChessMove) void {
        var i: usize = 0;
        while (i < self.count) : (i += 1) {
            var move = &self.list[i];
            // Order hash move first, then killers, then captures finally quiets
            if (@as(u32, @truncate(move.*.x)) == hashmove) {
                move.setSortScore(max_score);
            } else if (move.*.x == killer1.x) {
                move.setSortScore(killer_score_1);
            } else if (move.*.x == killer2.x) {
                move.setSortScore(killer_score_2);
            } else {
                var score = mvv_lva[move.capture()][move.piece()];
                if (move.is_promotion()) {
                    score += promotion_score;
                }
                move.setSortScore(score);
            }
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
                if (self.list[i].getSortScore() == 255) {}
                self.swap(i, self.count - 1);
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
