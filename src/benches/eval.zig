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

    pub fn run(self: EvalBench, allocator: std.mem.Allocator) void {
        var board = chess.Board.fromFen(allocator, self.fen) catch {
            @panic("could not create bench board form fen");
        };
        defer board.deinit(allocator);
        var e = engine.Engine.init(allocator) catch {
            @panic("could not initialize engine");
        };
        e.quiet = true;
        defer e.deinit(allocator);

        engine.transposition.global_tt.clear();
        engine.pawn_hashtable.global_pt.clear();

        if (board.state.current_side) {
            e.search(allocator, &board, true, self.depth);
        } else {
            e.search(allocator, &board, false, self.depth);
        }
    }
};
