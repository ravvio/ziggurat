const tables = @import("chess.zig").tables;
pub const engine = @import("engine.zig");
pub const chess = @import("chess.zig");

pub fn initAll() void {
    tables.initAll();
}
