const std = @import("std");
const chess = @import("./chess.zig");

pub fn perft(
    board: *chess.Board,
    comptime color: bool,
    depth: u8,
) u64 {
    if (depth == 0) {
        return 1;
    }

    var ml = chess.Movelist.new();
    var total: u64 = 0;

    board.generatePseudolegalMoves(
        chess.constants.MoveType.All,
        color,
        &ml,
    );

    var i: usize = 0;
    while (i < ml.count) : (i += 1) {
        board.makeMove(ml.list[i], color);
        if (board.isKingAttacked(color)) {
            board.unmakeMove(color);
            continue;
        }
        total += perft(board, !color, depth - 1);
        board.unmakeMove(color);
    }

    return total;
}

// TODO change to stdout
pub fn perftDivide(
    board: *chess.Board,
    comptime color: bool,
    depth: u8,
) u64 {
    if (depth == 0) {
        return 1;
    }

    var ml = chess.Movelist.new();
    var total: u64 = 0;

    board.generatePseudolegalMoves(
        chess.constants.MoveType.All,
        color,
        &ml,
    );

    var i: usize = 0;
    std.debug.print("{}\n", .{ml.count});
    while (i < ml.count) : (i += 1) {
        const move = ml.list[i];
        board.makeMove(move, color);
        if (board.isKingAttacked(color)) {
            board.unmakeMove(color);
            continue;
        }
        const leaves = perft(board, !color, depth - 1);
        std.debug.print("{}: {}\n", .{ move, leaves });
        total += leaves;
        board.unmakeMove(color);
    }

    std.debug.print("Total: {}\n", .{total});
    return total;
}

test "perft startpos" {
    chess.tables.initAll();

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try chess.Board.fromFen(alloc, chess.constants.Fen.STARTPOS);
    defer board.deinit();

    var res = perft(&board, true, 1);
    try std.testing.expectEqual(20, res);
    res = perft(&board, true, 2);
    try std.testing.expectEqual(400, res);
    res = perft(&board, true, 3);
    try std.testing.expectEqual(8_902, res);
    res = perft(&board, true, 4);
    try std.testing.expectEqual(197_281, res);
    // res = perft(&board, 5);
    // try std.testing.expectEqual(4_865_609, res);
    // res = perft(&board, 6);
    // try std.testing.expectEqual(119_060_324, res);
}

test "perft kiwipete" {
    chess.tables.initAll();

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try chess.Board.fromFen(alloc, chess.constants.Fen.KIWIPETE);
    defer board.deinit();

    var res = perft(&board, true, 1);
    try std.testing.expectEqual(48, res);
    res = perft(&board, true, 2);
    try std.testing.expectEqual(2_039, res);
    res = perft(&board, true, 3);
    try std.testing.expectEqual(97_862, res);
    res = perft(&board, true, 4);
    try std.testing.expectEqual(4_085_603, res);
    // res = perft(&board, 5);
    // try std.testing.expectEqual(193_690_690, res);
}

test "broken position" {
    chess.tables.initAll();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try chess.Board.fromFen(alloc, "rnbq1bnr/ppppp3/5k2/6p1/6p1/1P2P2P/P1PP4/RNBQKBNR w - - 0 9");
    defer board.deinit();

    var res = perft(&board, true, 2);
    try std.testing.expectEqual(750, res);
    res = perft(&board, true, 4);
    try std.testing.expectEqual(589_188, res);
    // res = perft(&board, true, 6);
    // try std.testing.expectEqual(490_634_943, res);
}
