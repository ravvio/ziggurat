const std = @import("std");
const chess = @import("../chess.zig");
const engine = @import("../engine.zig");

pub const EvalBench = struct {
    depth: u8,
    fen: []const u8,

    pub fn init(
        fen: []const u8,
        depth: u8,
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
        var e = engine.Engine.init(alloc) catch {
            @panic("could not initialize engine");
        };
        e.quiet = true;
        defer e.deinit();

        engine.transposition.global_tt.clear();

        if (board.state.current_side) {
            e.search(&board, true, self.depth);
        } else {
            e.search(&board, false, self.depth);
        }
    }
};
