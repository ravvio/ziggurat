const std = @import("std");

const SEED: u64 = 4081030931237;

pub const ZobristValues = struct {
    pieces: [2][6][64]u64,
    castling: [16]u64,
    color: u64,
    en_passant: [65]u64,

    pub fn new() ZobristValues {
        var rand = std.rand.DefaultPrng.init(SEED);
        var z: ZobristValues = undefined;

        for (&z.pieces) |*side| {
            for (side) |*pieces| {
                for (pieces) |*sq| {
                    sq.* = rand.next();
                }
            }
        }

        for (&z.castling) |*perm| {
            perm.* = rand.next();
        }

        z.color = rand.next();

        for (&z.en_passant) |*sq| {
            sq.* = rand.next();
        }

        return z;
    }
};
