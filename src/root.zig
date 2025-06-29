const tables = @import("chess.zig").tables;
const engine = @import("engine.zig");

pub fn initAll() void {
    tables.initAll();
    engine.initLmr();
}
