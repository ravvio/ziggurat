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

const high_bytes: u64 = 0xFF_FF_FF_FF_00_00_00_00;

pub const PT = struct {
    megabytes: usize,
    size: usize,
    used: usize = 0,
    data: std.array_list.Managed(PawnStructure),

    pub fn init(allocator: std.mem.Allocator, megabytes: usize) !PT {
        const structure_size = @sizeOf(PawnStructure);
        const size = @divTrunc(megabytes * 1024 * 1024, structure_size);

        var tt = PT{
            .megabytes = megabytes,
            .size = size,
            .data = std.array_list.Managed(PawnStructure).init(allocator),
        };
        try tt.data.ensureTotalCapacity(size);
        tt.data.expandToCapacity();
        return tt;
    }

    pub fn deinit(self: *PT) void {
        self.data.deinit();
    }

    pub fn clear(self: *PT) void {
        self.used = 0;
        self.data.clearAndFree();
        self.data.ensureTotalCapacity(self.size) catch unreachable;
        self.data.expandToCapacity();
    }

    /// Reports the occupancy of the table in permillis
    pub fn occupancy(self: *PT) usize {
        if (self.size > 0) {
            return @divTrunc(1000 * self.used, self.size);
        } else {
            return 0;
        }
    }

    pub fn index(self: *PT, pawn_key: u64) usize {
        // Use only the upper half of the pawn key for this, so the lower
        // half can be used to calculate a verification.
        return @truncate((pawn_key >> 32) % self.size);
    }

    pub fn put(
        self: *PT,
        zobrist_key: u64,
        score: types.Score,
    ) void {
        self.data.items[self.index(zobrist_key)] = .{
            .verification = @truncate(zobrist_key),
            .score = score,
        };
        self.used += 1;
    }

    pub fn probe(self: *PT, zobrist_key: u64) ?PawnStructure {
        const res = self.data.items[self.index(zobrist_key)];
        if (res.verification != 0) {
            const ok = @as(u32, @truncate(zobrist_key)) == @as(u32, @truncate(zobrist_key));
            if (ok) {
                return res;
            }
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
