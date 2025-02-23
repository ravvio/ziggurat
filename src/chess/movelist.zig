const std = @import("std");
const assert = std.debug.assert;
const common = @import("constants.zig");

pub fn Movelist(comptime T: type) type {
    return struct {
        list: [common.MAX_PSEUDO_MOVES]T,
        count: usize,

        pub fn new() Movelist(T) {
            return .{
                .list = undefined,
                .count = 0,
            };
        }

        pub fn add(m: *Movelist(T), item: T) void {
            assert(m.count < common.MAX_PSEUDO_MOVES);
            m.list[m.count] = item;
            m.count += 1;
        }

        pub fn swap(m: *Movelist(T), a: usize, b: usize) void {
            assert(a < m.count);
            assert(b < m.count);
            std.mem.swap(usize, &m.list[a], &m.list[b]);
        }
    };
}

test "swap" {
    var ml = Movelist(u64).new();
    ml.add(10);
    ml.add(20);
    ml.swap(0, 1);
    try std.testing.expectEqual(20, ml.list[0]);
    try std.testing.expectEqual(10, ml.list[1]);
}
