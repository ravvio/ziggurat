const std = @import("std");
const chess = @import("../chess.zig");
const movegen = @import("../movegen.zig");
const perft = @import("../perft.zig");

pub const PerftBench = struct {
    depth: i8,
    mg: *const movegen.MoveGenTables,
    fen: []const u8,

    pub fn init(
        mg: *const movegen.MoveGenTables,
        fen: []const u8,
        depth: i8,
    ) PerftBench {
        return .{
            .depth = depth,
            .mg = mg,
            .fen = fen,
        };
    }

    pub fn run(self: PerftBench, alloc: std.mem.Allocator) void {
        var board = chess.Board.fromFen(alloc, self.fen) catch {
            @panic("could not create bench board form fen");
        };
        _ = perft.perft(self.mg, &board, self.depth);
    }
};
