const std = @import("std");
const chess = @import("../chess.zig");
const engine = @import("../engine.zig");

pub const EvalBench = struct {
    depth: i8,
    fen: []const u8,

    pub fn init(
        fen: []const u8,
        depth: i8,
    ) EvalBench {
        return .{
            .depth = depth,
            .fen = fen,
        };
    }

    pub fn run(self: EvalBench, alloc: std.mem.Allocator) void {
        var board = chess.Board.fromFen(alloc, self.fen) catch {
            @panic("could not create bench board form fen");
        };
        defer board.deinit();
        var e = engine.Engine.init(alloc);
        defer e.deinit();

        if (board.state.current_side) {
            e.search(&board, true, self.depth);
        } else {
            e.search(&board, false, self.depth);
        }
    }
};
