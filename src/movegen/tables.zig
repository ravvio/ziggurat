const std = @import("std");
const masks = @import("masks.zig");
const assert = std.debug.assert;
const ArrayList = std.ArrayList;
const chess = @import("../chess.zig");
const magic = @import("magic.zig");
const Magic = magic.Magic;
const init = @import("tables_init.zig");

/// Sizes of the attack tables for rooks and bishops
const white_pawns = init.initWhitePawns();
const black_pawns = init.initBlackPawns();
const king = init.initKing();
const knight = init.initKnight();

var rook_masks: [64]u64 = std.mem.zeroes([64]u64);
var rook_shifts: [64]u6 = std.mem.zeroes([64]u6);
var rook: [64][4096]u64 = std.mem.zeroes([64][4096]u64);

var bishop_masks: [64]u64 = std.mem.zeroes([64]u64);
var bishop_shifts: [64]u6 = std.mem.zeroes([64]u6);
var bishop: [64][512]u64 = std.mem.zeroes([64][512]u64);

pub fn initRookMagics() void {
    for (chess.Square.ALL_SQUARES) |sq| {
        const mask = masks.rookMask(sq);
        const bits: u64 = @popCount(mask);

        rook_masks[sq.x] = mask;
        rook_shifts[sq.x] = @truncate(64 - bits);

        // Carry-Rippler
        // https://www.chessprogramming.org/Traversing_Subsets_of_a_Set
        var subset: u64 = 0;
        var index: u64 = 0;
        while (true) {
            // The subset is the blockers board
            index = subset;
            index = index *% magic.ROOK_MAGIC_NRS[sq.x];
            index = index >> rook_shifts[sq.x];

            rook[sq.x][index] = masks.bbRay(subset, sq, chess.constants.Direction.Up) //
            | masks.bbRay(subset, sq, chess.constants.Direction.Right) //
            | masks.bbRay(subset, sq, chess.constants.Direction.Down) //
            | masks.bbRay(subset, sq, chess.constants.Direction.Left);

            subset = (subset -% mask) & mask;
            if (subset == 0) {
                break;
            }
        }
    }
}

pub fn initBishopMagics() void {
    for (chess.Square.ALL_SQUARES) |sq| {
        const mask = masks.bishopMask(sq);
        const bits: u64 = @popCount(mask);

        bishop_masks[sq.x] = mask;
        bishop_shifts[sq.x] = @truncate(64 - bits);

        // Carry-Rippler
        // https://www.chessprogramming.org/Traversing_Subsets_of_a_Set
        var subset: u64 = 0;
        var index: u64 = 0;
        while (true) {
            // The subset is the blockers board
            index = subset;
            index = index *% magic.BISHOP_MAGIC_NRS[sq.x];
            index = index >> bishop_shifts[sq.x];

            bishop[sq.x][index] = masks.bbRay(subset, sq, chess.constants.Direction.UpLeft) //
            | masks.bbRay(subset, sq, chess.constants.Direction.UpRight) //
            | masks.bbRay(subset, sq, chess.constants.Direction.DownLeft) //
            | masks.bbRay(subset, sq, chess.constants.Direction.DownRight);

            subset = (subset -% mask) & mask;
            if (subset == 0) {
                break;
            }
        }
    }
}

pub fn initAll() void {
    initRookMagics();
    initBishopMagics();
}

pub fn kingAttacks(sq: usize) u64 {
    return king[sq];
}

pub fn rookAttacks(sq: usize, occupied: u64) u64 {
    return rook[sq][
        ((occupied & rook_masks[sq]) *% magic.ROOK_MAGIC_NRS[sq]) >> rook_shifts[sq]
    ];
}

pub fn bishopAttacks(sq: usize, occupied: u64) u64 {
    return bishop[sq][
        ((occupied & bishop_masks[sq]) *% magic.BISHOP_MAGIC_NRS[sq]) >> bishop_shifts[sq]
    ];
}

pub fn queenAttacks(sq: usize, occupied: u64) u64 {
    return rookAttacks(sq, occupied) | bishopAttacks(sq, occupied);
}

pub fn knightAttacks(sq: usize) u64 {
    return knight[sq];
}

pub fn whitePawnAttacks(sq: usize) u64 {
    return white_pawns[sq];
}

pub fn blackPawnAttacks(sq: usize) u64 {
    return black_pawns[sq];
}

pub fn pawnAttacks(color: bool, sq: usize) u64 {
    if (color) {
        return white_pawns[sq];
    } else {
        return black_pawns[sq];
    }
}
