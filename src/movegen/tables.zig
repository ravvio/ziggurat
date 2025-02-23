const std = @import("std");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const chess = @import("../chess.zig");
const magic = @import("magic.zig");
const Magic = magic.Magic;
const init = @import("tables_init.zig");

/// Sizes of the attack tables for rooks and bishops
pub const ROOK_TABLE_SIZE: usize = 102_400;
pub const BISHOP_TABLE_SIZE: usize = 5_248;

/// The move generator, holds attack tables for every peices
/// and the magics
pub const MoveGenTables = struct {
    arena: std.heap.ArenaAllocator,
    king: [64]u64,
    knight: [64]u64,
    white_pawns: [64]u64,
    black_pawns: [64]u64,
    rook: []u64,
    bishop: []u64,
    rook_magics: [64]Magic,
    bishop_magics: [64]Magic,

    pub fn new() MoveGenTables {
        // TODO: try to switch to a FixedBufferAllocator
        // or provide allocator as argument
        // or make it in stack
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        const allocator = arena.allocator();
        var rook: []u64 = allocator.alloc(u64, ROOK_TABLE_SIZE) catch {
            @panic("Could not allocate rook tables");
        };
        const rook_magics = init.initMagics(&rook, chess.constants.pieces.ROOK);
        var bishop: []u64 = allocator.alloc(u64, BISHOP_TABLE_SIZE) catch {
            @panic("Could not allocate bishop tables");
        };
        const bishop_magics = init.initMagics(&bishop, chess.constants.pieces.BISHOP);

        return MoveGenTables{
            .arena = arena,
            .king = init.initKing(),
            .knight = init.initKnight(),
            .white_pawns = init.initWhitePawns(),
            .black_pawns = init.initBlackPawns(),
            .rook = rook,
            .bishop = bishop,
            .rook_magics = rook_magics,
            .bishop_magics = bishop_magics,
        };
    }

    pub fn deinit(mg: MoveGenTables) void {
        mg.arena.deinit();
    }

    pub fn kingAttacks(mg: MoveGenTables, sq: usize) u64 {
        return mg.king[sq];
    }

    pub fn rookAttacks(mg: MoveGenTables, sq: usize, occupied: u64) u64 {
        return mg.rook[mg.rook_magics[sq].getIndex(occupied)];
    }

    pub fn bishopAttacks(mg: MoveGenTables, sq: usize, occupied: u64) u64 {
        return mg.bishop[mg.bishop_magics[sq].getIndex(occupied)];
    }

    pub fn queenAttacks(mg: MoveGenTables, sq: usize, occupied: u64) u64 {
        return mg.rookAttacks(sq, occupied) | mg.bishopAttacks(sq, occupied);
    }

    pub fn knightAttacks(mg: MoveGenTables, sq: usize) u64 {
        return mg.knight[sq];
    }

    pub fn whitePawnAttacks(mg: MoveGenTables, sq: usize) u64 {
        return mg.white_pawns[sq];
    }

    pub fn blackPawnAttacks(mg: MoveGenTables, sq: usize) u64 {
        return mg.white_pawns[sq];
    }

    pub fn pawnAttacks(mg: MoveGenTables, color: bool, sq: usize) u64 {
        if (color) {
            return mg.white_pawns[sq];
        } else {
            return mg.black_pawns[sq];
        }
    }
};

test "initialize move generation tables" {
    const mv = MoveGenTables.new();
    try std.testing.expectEqual(ROOK_TABLE_SIZE, mv.rook.len);
    try std.testing.expectEqual(BISHOP_TABLE_SIZE, mv.bishop.len);
    defer mv.deinit();
}
