const std = @import("std");

pub fn benchSubtractUsize(_: std.mem.Allocator) void {
    for (0..50) |i| {
        std.mem.doNotOptimizeAway(i);
        for (0..50) |j| {
            std.mem.doNotOptimizeAway(j);
            _ = @abs(@as(i64, @intCast(i)) - @as(i64, @intCast(j)));
        }
    }
}
