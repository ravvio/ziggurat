const std = @import("std");
const assert = std.debug.assert;
const chess = @import("../chess.zig");
const Square = chess.Square;
const bitboard = chess.bitboard;
const pieces = chess.constants.pieces;
const magic = @import("magic.zig");
const Magic = magic.Magic;
const tables = @import("tables.zig");
const masks = @import("masks.zig");

// zig fmt: off
pub fn initKing() [64]u64 {
    var king = std.mem.zeroes([64]u64);
    for (0..64) |sq| {
        const bbs = bitboard.SQUARES[sq];
        king[sq] = (bbs & bitboard.N_FILE_A & bitboard.N_RANK_1) << 7
            | (bbs & bitboard.N_RANK_1) << 8
            | (bbs & bitboard.N_FILE_H & bitboard.N_RANK_1) << 9
            | (bbs & bitboard.N_FILE_H) << 1
            | (bbs & bitboard.N_FILE_H & bitboard.N_RANK_8) >> 7
            | (bbs & bitboard.N_RANK_8) >> 8
            | (bbs & bitboard.N_FILE_A & bitboard.N_RANK_8) >> 9
            | (bbs & bitboard.N_FILE_A) >> 1;

    }
    return king;
}

pub fn initKnight() [64]u64 {
    var knight = std.mem.zeroes([64]u64);
    for (0..64) |sq| {
        const bbs = bitboard.SQUARES[sq];
        knight[sq] =
            (bbs & bitboard.N_RANK_1 & bitboard.N_RANK_2 & bitboard.N_FILE_A) << 15
            | (bbs & bitboard.N_RANK_1 & bitboard.N_RANK_2 & bitboard.N_FILE_H) << 17
            | (bbs & bitboard.N_FILE_A & bitboard.N_FILE_B & bitboard.N_RANK_1) << 6
            | (bbs & bitboard.N_FILE_G & bitboard.N_FILE_H & bitboard.N_RANK_1) << 10
            | (bbs & bitboard.N_RANK_8 & bitboard.N_RANK_7 & bitboard.N_FILE_A) >> 17
            | (bbs & bitboard.N_RANK_8 & bitboard.N_RANK_7 & bitboard.N_FILE_H) >> 15
            | (bbs & bitboard.N_FILE_A & bitboard.N_FILE_B & bitboard.N_RANK_8) >> 10
            | (bbs & bitboard.N_FILE_G & bitboard.N_FILE_H & bitboard.N_RANK_8) >> 6;
    }
    return knight;
}

pub fn initWhitePawns() [64]u64 {
    var white_pawns = std.mem.zeroes([64]u64);
    for (0..64) |sq| {
        const bbs = bitboard.SQUARES[sq];
        white_pawns[sq] =
            (bbs & bitboard.N_FILE_A) >> 9
            | (bbs & bitboard.N_FILE_H) >> 7;
    }
    return white_pawns;
}

pub fn initBlackPawns() [64]u64 {
    var black_pawns = std.mem.zeroes([64]u64);
    for (0..64) |sq| {
        const bbs = bitboard.SQUARES[sq];
        black_pawns[sq] =
            (bbs & bitboard.N_FILE_A) << 7
            | (bbs & bitboard.N_FILE_H) << 9;
    }
    return black_pawns;
}

// zig fmt: on

// pub fn initMagics(table: *[]u64, piece: usize) [64]Magic {
//     assert(piece == pieces.ROOK or piece == pieces.BISHOP);
//     const is_rook: bool = piece == pieces.ROOK;
//
//     var magics = std.mem.zeroes([64]Magic);
//     var offset: usize = 0;
//
//     var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
//     defer arena.deinit();
//     const allocator = arena.allocator();
//
//     for (Square.ALL_SQUARES) |sq| {
//         const mask = if (is_rook) masks.rookMask(sq) else masks.bishopMask(sq);
//         const bits: u64 = @popCount(mask);
//         const permutations: u64 = std.math.pow(u64, 2, bits);
//         const end = offset + permutations - 1;
//
//         const blocker_boards = masks.blockerBoards(allocator, mask);
//         const attack_boards = if (is_rook) masks.rookAttackBoards(allocator, sq, &blocker_boards) else masks.bishopAttackBoards(allocator, sq, &blocker_boards);
//
//         var new_magic = Magic{
//             .mask = mask,
//             .shift = @truncate(64 - bits),
//             .offset = offset,
//             .nr = if (is_rook) magic.ROOK_MAGIC_NRS[sq.x] else magic.BISHOP_MAGIC_NRS[sq.x],
//         };
//
//         for (0..permutations) |i| {
//             const index = new_magic.getIndex(blocker_boards.items[i]);
//             assert(table.*[index] != 0);
//             assert(index >= offset);
//             assert(index <= end);
//             table.*[index] = attack_boards.items[i];
//         }
//
//         magics[sq.x] = new_magic;
//         offset += permutations;
//     }
//
//     assert(offset == (if (is_rook) tables.ROOK_TABLE_SIZE else tables.BISHOP_TABLE_SIZE));
//     return magics;
// }
