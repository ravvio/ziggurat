const std = @import("std");

const SEED: u64 = 0x31_18_9e_a9_c1_97_0a_ef;

pub const ZobristValues = struct {
    pieces: [2][6][64]u64,
    castling: [16]u64,
    color: u64,
    en_passant: [64]u64,

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
