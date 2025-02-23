const std = @import("std");
const ArrayList = std.ArrayList;

const Magic = @import("magic.zig").Magic;

const chess = @import("../chess.zig");
const bitboard = chess.bitboard;
const Square = chess.Square;
const Direction = chess.constants.Direction;
const ranks = chess.constants.ranks;
const files = chess.constants.files;

pub fn rookMask(s: Square) u64 {
    const file = s.file();
    const rank = s.rank();
    const bb_rook_square = bitboard.SQUARES[s.x];
    const bb_edges = edgesWithoutPiece(file, rank);
    const bb_mask = bitboard.FILES[file] | bitboard.RANKS[rank];

    const r = bb_mask & ~bb_edges & ~bb_rook_square;
    return r;
}

pub fn bishopMask(s: Square) u64 {
    const file = s.file();
    const rank = s.rank();
    const bb_edges = edgesWithoutPiece(file, rank);

    var bb_rays = bbRay(bitboard.EMPTY, s, Direction.UpRight);
    bb_rays |= bbRay(bitboard.EMPTY, s, Direction.UpLeft);
    bb_rays |= bbRay(bitboard.EMPTY, s, Direction.DownRight);
    bb_rays |= bbRay(bitboard.EMPTY, s, Direction.DownLeft);

    return bb_rays & ~bb_edges;
}

pub fn rookAttackBoards(
    allocator: std.mem.Allocator,
    s: Square,
    blockers: *const ArrayList(u64),
) ArrayList(u64) {
    var attack_boards = ArrayList(u64).init(allocator);
    for (blockers.items) |b| {
        // zig fmt: off
        attack_boards.append(
            bbRay(b, s, Direction.Up)
            | bbRay(b, s, Direction.Right)
            | bbRay(b, s, Direction.Down)
            | bbRay(b, s, Direction.Left)
        ) catch |e| {
            std.debug.print("Error while appening to attack boards: {}", .{e});
        };
        // zig fmt: on
    }
    return attack_boards;
}

pub fn bishopAttackBoards(
    allocator: std.mem.Allocator,
    s: Square,
    blockers: *const ArrayList(u64),
) ArrayList(u64) {
    var attack_boards = ArrayList(u64).init(allocator);
    for (blockers.items) |b| {
        // zig fmt: off
        attack_boards.append(
            bbRay(b, s, Direction.UpLeft)
            | bbRay(b, s, Direction.UpRight)
            | bbRay(b, s, Direction.DownLeft)
            | bbRay(b, s, Direction.DownRight)
        ) catch { @panic("Could not appent to attack boards"); };
        // zig fmt: on
    }
    return attack_boards;
}

pub fn blockerBoards(allocator: std.mem.Allocator, mask: u64) ArrayList(u64) {
    var blocker_boards = ArrayList(u64).init(allocator);
    var n: u64 = bitboard.EMPTY;

    // Carry-Rippler
    // https://www.chessprogramming.org/Traversing_Subsets_of_a_Set
    while (true) {
        blocker_boards.append(n) catch |e| {
            std.debug.print("Error while appending to attack boards: {}", .{e});
        };
        n = (n -% mask) & mask;
        if (n == bitboard.EMPTY) {
            break;
        }
    }
    return blocker_boards;
}

fn edgesWithoutPiece(f: usize, r: usize) u64 {
    const nbb_file = ~bitboard.FILES[f];
    const nbb_rank = ~bitboard.RANKS[r];
    // zig fmt: off
    return (bitboard.FILE_A & nbb_file)
        | (bitboard.FILE_H & nbb_file)
        | (bitboard.RANK_1 & nbb_rank)
        | (bitboard.RANK_8 & nbb_rank);
    // zig fmt: on
}

fn bbRay(bb: u64, s: Square, dir: Direction) u64 {
    var file: usize = s.file();
    var rank: usize = s.rank();

    var bb_square: u64 = bitboard.SQUARES[s.x];
    var bb_ray: u64 = bitboard.EMPTY;

    while (true) {
        switch (dir) {
            Direction.Up => {
                if (rank == ranks.R8) break;
                bb_square >>= 8;
                bb_ray |= bb_square;
                rank -= 1;
            },
            Direction.Down => {
                if (rank == ranks.R1) break;
                bb_square <<= 8;
                bb_ray |= bb_square;
                rank += 1;
            },
            Direction.Right => {
                if (file == files.H) break;
                bb_square <<= 1;
                bb_ray |= bb_square;
                file += 1;
            },
            Direction.Left => {
                if (file == files.A) break;
                bb_square >>= 1;
                bb_ray |= bb_square;
                file -= 1;
            },
            Direction.UpRight => {
                if (rank == ranks.R8 or file == files.H) break;
                bb_square >>= 7;
                bb_ray |= bb_square;
                rank -= 1;
                file += 1;
            },
            Direction.UpLeft => {
                if (rank == ranks.R8 or file == files.A) break;
                bb_square >>= 9;
                bb_ray |= bb_square;
                rank -= 1;
                file -= 1;
            },
            Direction.DownRight => {
                if (rank == ranks.R1 or file == files.H) break;
                bb_square <<= 9;
                bb_ray |= bb_square;
                rank += 1;
                file += 1;
            },
            Direction.DownLeft => {
                if (rank == ranks.R1 or file == files.A) break;
                bb_square <<= 7;
                bb_ray |= bb_square;
                rank += 1;
                file -= 1;
            },
        }
        if ((bb_square & bb) > 0) {
            break;
        }
    }
    return bb_ray;
}
