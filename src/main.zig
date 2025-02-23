const std = @import("std");
const chess = @import("chess.zig");
const movegen = @import("movegen.zig");
const uci = @import("uci.zig");

const perft = @import("perft.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try chess.Board.fromFen(alloc, chess.constants.Fen.KIWIPETE);
    defer board.deinit();

    var mg = movegen.MoveGenTables.new();
    defer mg.deinit();

    // var move = try uci.parseMove(&mg, &board, "e1g1");
    // board.makeMove(move);
    // move = try uci.parseMove(&mg, &board, "h3g2");
    // board.makeMove(move);
    // move = try uci.parseMove(&mg, &board, "h2h3");
    // board.makeMove(move);

    _ = perft.perftDivide(&mg, &board, 5);
}
