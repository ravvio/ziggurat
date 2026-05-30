const std = @import("std");
const chess = @import("../chess.zig");
const perft = @import("../perft.zig");

pub const PerftBench = struct {
    depth: u8,
    fen: []const u8,

    pub fn init(
        fen: []const u8,
        depth: u8,
    ) PerftBench {
        return .{
            .depth = depth,
            .fen = fen,
        };
    }

    pub fn run(self: *PerftBench, allocator: std.mem.Allocator) void {
        var board = chess.Board.fromFen(allocator, self.fen) catch {
            @panic("could not create bench board form fen");
        };
        defer board.deinit(allocator);
        if (board.state.current_side) {
            _ = perft.perft(allocator, &board, true, self.depth);
        } else {
            _ = perft.perft(allocator, &board, false, self.depth);
        }
    }
};
