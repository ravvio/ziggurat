const std = @import("std");
const tables = @import("heuristic_tables.zig");
const types = @import("types.zig");

pub var passed_pawn_value: types.Score = 20;
pub var passed_pawn_value_increment: types.Score = 2;

pub fn updatePassedPawnValue() void {
    var val = passed_pawn_value;
    for (0..8) |i| {
        tables.passed_pawns_values[i] = val;
        val += passed_pawn_value_increment;
    }
}

pub const Tunable = struct {
    name: []const u8,
    def: i32,
    min: i32,
    max: i32,
};

pub const tunable_params = [_]Tunable{
    Tunable{ .name = "PassedPawnValue", .def = 20, .min = 1, .max = 100 },
    Tunable{ .name = "PassedPawnValueIncrement", .def = 2, .min = 1, .max = 50 },
};
