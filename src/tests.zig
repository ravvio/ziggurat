const std = @import("std");
const testing = std.testing;

test "tests" {
    testing.refAllDecls(@This());
}
