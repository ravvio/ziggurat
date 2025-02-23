const chess = @import("../chess.zig");
const std = @import("std");

pub const SwapBench = struct {
    size: usize,
    ml: chess.Movelist(u64),

    pub fn init(size: usize) SwapBench {
        var ml = chess.Movelist(u64).new();
        for (0..size) |i| {
            ml.add(i);
        }
        return .{
            .size = size,
            .ml = ml,
        };
    }

    pub fn run(self: SwapBench, _: std.mem.Allocator) void {
        var ml = self.ml;
        for (0..self.size) |i| {
            std.mem.doNotOptimizeAway(i);
            for (0..self.size) |j| {
                std.mem.doNotOptimizeAway(j);
                ml.swap(i, j);
            }
        }
    }
};
