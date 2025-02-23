const std = @import("std");
const movegen = @import("./movegen.zig");
const chess = @import("./chess.zig");
const legal = @import("./legality.zig");

pub fn perft(
    mg: *const movegen.MoveGenTables,
    board: *chess.Board,
    depth: i8,
) u64 {
    if (depth == 0) {
        return 1;
    }

    const color = board.state.current_side;

    var ml = chess.Movelist(chess.ChessMove).new();
    var total: u64 = 0;

    movegen.generation.genMovesPseudolegal(
        mg,
        color,
        movegen.MoveType.All,
        board,
        &ml,
    );

    var i: usize = 0;
    while (i < ml.count) : (i += 1) {
        const move = ml.list[i];
        board.makeMove(move);
        if (legal.isKingAttacked(color, mg, board)) {
            board.unmakeMove();
            continue;
        }
        const leaves = perft(mg, board, depth - 1);
        total += leaves;
        board.unmakeMove();
    }

    return total;
}

pub fn perftDivide(
    mg: *movegen.MoveGenTables,
    board: *chess.Board,
    depth: i8,
) u64 {
    if (depth == 0) {
        return 1;
    }

    const color = board.state.current_side;
    var ml = chess.Movelist(chess.ChessMove).new();
    var total: u64 = 0;

    movegen.generation.genMovesPseudolegal(
        mg,
        color,
        movegen.MoveType.All,
        board,
        &ml,
    );

    var i: usize = 0;
    while (i < ml.count) : (i += 1) {
        const move = ml.list[i];
        board.makeMove(move);
        if (legal.isKingAttacked(color, mg, board)) {
            board.unmakeMove();
            continue;
        }
        const leaves = perft(mg, board, depth - 1);
        total += leaves;
        board.unmakeMove();
        std.debug.print("{} - {}\n", .{ move, leaves });
    }

    std.debug.print("Total {}\n", .{total});
    return total;
}

test "perft startpos" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try chess.Board.fromFen(alloc, chess.constants.Fen.STARTPOS);
    defer board.deinit();

    var mg = movegen.MoveGenTables.new();
    defer mg.deinit();

    var res = perft(&mg, &board, 1);
    try std.testing.expectEqual(20, res);
    res = perft(&mg, &board, 2);
    try std.testing.expectEqual(400, res);
    res = perft(&mg, &board, 3);
    try std.testing.expectEqual(8_902, res);
    res = perft(&mg, &board, 4);
    try std.testing.expectEqual(197_281, res);
    // res = perft(&mg, &board, 5);
    // try std.testing.expectEqual(4_865_609, res);
    // res = perft(&mg, &board, 6);
    // try std.testing.expectEqual(119_060_324, res);
}

test "perft kiwipete" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try chess.Board.fromFen(alloc, chess.constants.Fen.KIWIPETE);
    defer board.deinit();

    var mg = movegen.MoveGenTables.new();
    defer mg.deinit();

    var res = perft(&mg, &board, 1);
    try std.testing.expectEqual(48, res);
    res = perft(&mg, &board, 2);
    try std.testing.expectEqual(2_039, res);
    res = perft(&mg, &board, 3);
    try std.testing.expectEqual(97_862, res);
    res = perft(&mg, &board, 4);
    try std.testing.expectEqual(4_085_603, res);
    // res = perft(&mg, &board, 5);
    // try std.testing.expectEqual(193_690_690, res);
}
