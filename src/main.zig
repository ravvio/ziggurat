const std = @import("std");
const chess = @import("chess.zig");
const uci = @import("uci.zig");

const perft = @import("perft.zig");

pub fn main() !void {
    chess.tables.initAll();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try chess.Board.fromFen(alloc, chess.constants.Fen.STARTPOS);
    defer board.deinit();

    // var move = try uci.parseMove(&board, "g2g3");
    // board.makeMove(move);
    // move = try uci.parseMove(&board, "d7d5");
    // board.makeMove(move);
    // move = try uci.parseMove(&board, "f1h3");
    // board.makeMove(move);
    // move = try uci.parseMove(&board, "e8d7");
    // board.makeMove(move);

    if (board.state.current_side) {
        _ = perft.perftDivide(&board, true, 5);
    } else {
        _ = perft.perftDivide(&board, true, 5);
    }
}
