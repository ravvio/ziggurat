pub const Engine = @import("./engine/engine.zig").Engine;
pub const Uci = @import("./engine/uci.zig").Uci;

const std = @import("std");
const chess = @import("chess.zig");

fn test_mate(
    fen: []const u8,
    correct: []const u8,
    depth: u8,
) !void {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var e = Engine.init(alloc);
    e.quiet = true;
    defer e.deinit();
    var board = try chess.Board.fromFen(alloc, fen);
    defer board.deinit();

    const expected = try board.parseMove(correct);
    e.search(&board, true, depth * 2);

    std.testing.expectEqual(expected, e.best_move) catch |err| {
        std.debug.print("expected: {}, jound: {}\n", .{ expected, e.best_move });
        return err;
    };
}

test "mates in 1" {
    chess.tables.initAll();
    try test_mate("1rb5/4r3/3p1npb/3kp1P1/1P3P1P/5nR1/2Q1BK2/bN4NR w - - 3 61", "c2c4", 1);
    try test_mate("rn1q2n1/b3k1pr/pp1pB1Qp/2p1p1P1/2P1PP2/5R1P/P2P4/RNB1K3 w - - 1 24", "g6f7", 1);
    try test_mate("8/3r3k/NP1p4/p2QP1P1/1BB3Pp/1R4n1/6K1/5R2 w - - 5 82", "d5g8", 1);
    try test_mate("1nr1r3/n4Q2/P1kp2N1/2p3B1/1pp3P1/6P1/1R2P2R/K5N1 w - - 3 43", "f7b7", 1);
}

test "mates in 2" {
    chess.tables.initAll();
    try test_mate("r2qk2r/pb4pp/1n2Pb2/2B2Q2/p1p5/2P5/2B2PPP/RN2R1K1 w - - 1 0", "f5g6", 2);
}
