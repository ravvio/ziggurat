const std = @import("std");
const testing = std.testing;

const engine = @import("./engine/engine.zig");
const perft = @import("./perft.zig");

comptime {
    testing.refAllDecls(@This());
}
