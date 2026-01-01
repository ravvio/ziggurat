pub const Uci = @import("./engine/uci.zig").Uci;
pub const transposition = @import("./engine/transposition.zig");
pub const pawn_hashtable = @import("./engine/pawn_hashtable.zig");

const engine = @import("./engine/engine.zig");
pub const Engine = engine.Engine;

pub const ziggurat = @import("root.zig");

const std = @import("std");
const chess = @import("chess.zig");

fn testMate(
    allocator: std.mem.Allocator,
    fen: []const u8,
    correct: []const u8,
    depth: u8,
) !void {
    var e = Engine.init(allocator) catch unreachable;
    e.quiet = true;
    defer e.deinit(allocator);
    var board = try chess.Board.fromFen(allocator, fen);
    defer board.deinit(allocator);

    const expected = try board.parseMove(correct);
    e.search(allocator, &board, true, depth * 2);
    e.best_move.removeSortScore();

    std.testing.expectEqual(expected, e.best_move) catch |err| {
        std.debug.print("expected: {f}, found: {f}\n", .{ expected, e.best_move });
        return err;
    };
}

test "mates in 1" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.debug.assert(false);
    }
    const allocator = gpa.allocator();
    try transposition.initGlobalTranspositionTable(allocator, 64);
    try pawn_hashtable.initGlobalPawnTable(allocator, 4);
    ziggurat.initAll();
    defer transposition.global_tt.deinit(allocator);
    defer pawn_hashtable.global_pt.deinit(allocator);
    try testMate(allocator, "1rb5/4r3/3p1npb/3kp1P1/1P3P1P/5nR1/2Q1BK2/bN4NR w - - 3 61", "c2c4", 1);
    try testMate(allocator, "rn1q2n1/b3k1pr/pp1pB1Qp/2p1p1P1/2P1PP2/5R1P/P2P4/RNB1K3 w - - 1 24", "g6f7", 1);
    try testMate(allocator, "8/3r3k/NP1p4/p2QP1P1/1BB3Pp/1R4n1/6K1/5R2 w - - 5 82", "d5g8", 1);
    try testMate(allocator, "1nr1r3/n4Q2/P1kp2N1/2p3B1/1pp3P1/6P1/1R2P2R/K5N1 w - - 3 43", "f7b7", 1);
}

test "mates in 2" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.debug.assert(false);
    }
    const allocator = gpa.allocator();
    try transposition.initGlobalTranspositionTable(allocator, 64);
    try pawn_hashtable.initGlobalPawnTable(allocator, 4);
    defer transposition.global_tt.deinit(allocator);
    defer pawn_hashtable.global_pt.deinit(allocator);
    ziggurat.initAll();
    try testMate(allocator, "r2qk2r/pb4pp/1n2Pb2/2B2Q2/p1p5/2P5/2B2PPP/RN2R1K1 w - - 1 0", "f5g6", 2);
}

test "mates in 3" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.debug.assert(false);
    }
    const allocator = gpa.allocator();
    try transposition.initGlobalTranspositionTable(allocator, 64);
    try pawn_hashtable.initGlobalPawnTable(allocator, 4);
    defer transposition.global_tt.deinit(allocator);
    defer pawn_hashtable.global_pt.deinit(allocator);
    ziggurat.initAll();
    try testMate(allocator, "8/8/8/8/1p1N4/1Bk1K3/3N4/b7 w - - 1 0", "d4e6", 3);
    try testMate(allocator, "5K1k/6R1/8/3b2P1/5p2/p6p/q7/8 w - - 1 0", "g5g6", 3);
    try testMate(allocator, "1Q6/3r4/q1k1bP1p/1pBp1p2/3P4/8/1P4PP/5RK1 w - - 1 0", "f1c1", 3);
    try testMate(allocator, "1Q6/p3qp1p/B3p3/3k2rP/3p2P1/8/1P4K1/2R5 w - - 1 0", "a6c4", 3);
}

test "mate in 5" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) std.debug.assert(false);
    }
    const allocator = gpa.allocator();
    try transposition.initGlobalTranspositionTable(allocator, 64);
    try pawn_hashtable.initGlobalPawnTable(allocator, 4);
    defer transposition.global_tt.deinit(allocator);
    defer pawn_hashtable.global_pt.deinit(allocator);
    ziggurat.initAll();
    try testMate(allocator, "8/8/7k/8/5NR1/3K4/8/8 w - - 5 55", "d3e4", 8);
}
