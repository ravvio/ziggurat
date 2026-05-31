const std = @import("std");
const types = @import("types.zig");
const chess = @import("../chess.zig");

// TODO try to pack
pub const PawnStructure = struct {
    /// Hash of the pawn structure, we only use the lower half of the
    /// pawn zobrist key to save space
    verification: u32 = 0,
    score: types.Score = 0,
};

pub const PT = struct {
    megabytes: usize,
    size: usize,
    data: []PawnStructure,

    pub fn init(allocator: std.mem.Allocator, megabytes: usize) !PT {
        const structure_size = @sizeOf(PawnStructure);
        const size = @divTrunc(megabytes * 1024 * 1024, structure_size);

        const tt = PT{ .megabytes = megabytes, .size = size, .data = try allocator.alloc(PawnStructure, size) };
        for (0..tt.data.len) |i| {
            tt.data[i] = PawnStructure{
                .verification = 0,
                .score = 0,
            };
        }
        return tt;
    }

    pub fn deinit(self: *PT, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn clear(self: *PT) void {
        for (0..self.data.len) |i| {
            self.data[i] = PawnStructure{
                .verification = 0,
                .score = 0,
            };
        }
    }

    pub fn index(self: *PT, pawn_key: u64) usize {
        // Use only the upper half of the pawn key for this, so the lower
        // half can be used to calculate a verification.
        return @truncate((pawn_key >> 32) % self.size);
    }

    pub fn put(
        self: *PT,
        pawn_key: u64,
        score: types.Score,
    ) void {
        self.data[self.index(pawn_key)] = .{
            .verification = @truncate(pawn_key),
            .score = score,
        };
    }

    pub fn probe(self: *PT, pawn_key: u64) ?PawnStructure {
        const res = self.data[self.index(pawn_key)];
        if (res.verification != 0 and res.verification == @as(u32, @truncate(pawn_key))) {
            return res;
        }
        return null;
    }
};

pub var global_pt: PT = undefined;

pub fn initGlobalPawnTable(
    allocator: std.mem.Allocator,
    megabytes: usize,
) !void {
    global_pt = try PT.init(allocator, megabytes);
}
