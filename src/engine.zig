const std = @import("std");
const engine = @import("./engine/engine.zig");
pub const Engine = engine.Engine;
pub const transposition = @import("./engine/transposition.zig");
pub const pawn_hashtable = @import("./engine/pawn_hashtable.zig");
pub const Uci = @import("./engine/uci.zig").Uci;

const tables = @import("./engine/heuristic_tables.zig");
const chess = @import("chess.zig");

test "pawn_structure_count" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        std.debug.assert(deinit_status == .ok);
    }
    const allocator = gpa.allocator();

    var board = try chess.Board.fromFen(allocator, "2b5/4Bpbp/p6r/p1Np4/2p2P1P/3P1P1p/1k6/1B3R1K w - - 0 13");
    defer board.deinit(allocator);

    const black_pawns = board.pawns(chess.constants.Colors.black);
    const white_pawns = board.pawns(chess.constants.Colors.white);

    var doubled_b: usize = 0;
    var doubled_w: usize = 0;

    var black_pawns_it = black_pawns;
    while (black_pawns_it != 0) {
        const sq = chess.bitboard.pop(&black_pawns_it);
        if (black_pawns & tables.double_pawn_masks[0][sq] != 0) {
            doubled_b += 1;
        }
    }

    var white_pawns_it = white_pawns;
    while (white_pawns_it != 0) {
        const sq = chess.bitboard.pop(&white_pawns_it);
        if (white_pawns & tables.double_pawn_masks[1][sq] != 0) {
            doubled_w += 1;
        }
    }

    try std.testing.expectEqual(1, doubled_w);
    try std.testing.expectEqual(2, doubled_b);
}
