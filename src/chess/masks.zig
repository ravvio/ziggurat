const Square = @import("square.zig").Square;
const bitboard = @import("bitboard.zig");
const constants = @import("constants.zig");
const Direction = constants.Direction;
const ranks = constants.ranks;
const files = constants.files;

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

pub fn bbRay(bb: u64, s: Square, dir: Direction) u64 {
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
