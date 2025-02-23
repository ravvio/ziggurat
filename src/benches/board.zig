const std = @import("std");
const chess = @import("../chess.zig");

pub const ParseFenBench = struct {
    fen: []const u8,

    pub fn init(fen: []const u8) ParseFenBench {
        return .{ .fen = fen };
    }

    pub fn run(self: ParseFenBench, alloc: std.mem.Allocator) void {
        var a = chess.Board.fromFen(alloc, self.fen) catch {
            return;
        };
        defer a.deinit();
    }
};
