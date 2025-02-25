const std = @import("std");
const chess = @import("../chess.zig");
const perft = @import("../perft.zig");

pub const PerftBench = struct {
    depth: i8,
    fen: []const u8,

    pub fn init(
        fen: []const u8,
        depth: i8,
    ) PerftBench {
        return .{
            .depth = depth,
            .fen = fen,
        };
    }

    pub fn run(self: PerftBench, alloc: std.mem.Allocator) void {
        var board = chess.Board.fromFen(alloc, self.fen) catch {
            @panic("could not create bench board form fen");
        };
        if (board.state.current_side) {
            _ = perft.perft(&board, true, self.depth);
        } else {
            _ = perft.perft(&board, false, self.depth);
        }
    }
};
