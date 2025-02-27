const std = @import("std");
const types = @import("types.zig");
const chess = @import("../chess.zig");

pub const TranspositionFlag = enum(u2) {
    None,
    Exact,
    Alpha,
    Beta,
};

// TODO try to pack
pub const Transposition = struct {
    /// Hash of the transposition, we only use the lower half of the
    /// zobrist key to save space
    verification: u32 = 0,
    depth: u8 = 0,
    move: u32 = 0,
    score: types.Score = 0,
    flag: TranspositionFlag = TranspositionFlag.None,
};

const bucket_size: u8 = 4;
const Bucket = struct {
    content: [bucket_size]Transposition = std.mem.zeroes([bucket_size]Transposition),

    pub fn store(self: *Bucket, item: Transposition, used: *usize) void {
        // Find the item in the bucket that has the lowest depth
        // and substitute it
        var index: usize = 0;
        var lowest_depth = self.content[0].depth;
        for (1..bucket_size) |i| {
            if (self.content[i].depth < lowest_depth) {
                index = i;
                lowest_depth = item.depth;
            }
        }
        const low = &self.content[index];
        // Verification is 0 so the entry is still unused
        if (low.verification == 0) {
            used.* += 1;
        }
        low.* = item;
    }

    pub fn find(self: *const Bucket, verification: u32) ?Transposition {
        for (self.content) |item| {
            if (item.verification == verification) {
                return item;
            } else if (item.verification == 0) {
                return null;
            }
        }
        return null;
    }
};

const high_bytes: u64 = 0xFF_FF_FF_FF_00_00_00_00;

pub const TT = struct {
    megabytes: usize,
    size: usize,
    used: usize = 0,
    data: std.ArrayList(Bucket),

    pub fn init(allocator: std.mem.Allocator, megabytes: usize) !TT {
        const bucket_bytes = @sizeOf(Transposition) * bucket_size;
        const size = @divTrunc(megabytes * 1024 * 1024, bucket_bytes);

        var tt = TT{
            .megabytes = megabytes,
            .size = size,
            .data = std.ArrayList(Bucket).init(allocator),
        };
        try tt.data.ensureTotalCapacity(size);
        tt.data.expandToCapacity();
        return tt;
    }

    pub fn deinit(self: *TT) void {
        self.data.deinit();
    }

    pub fn clear(self: *TT) void {
        self.data.clearAndFree();
        self.data.ensureTotalCapacity(self.size) catch unreachable;
        self.data.expandToCapacity();
    }

    pub fn index(self: *TT, zobrist_key: u64) usize {
        // Use only the upper half of the Zobrist key for this, so the lower
        // half can be used to calculate a verification.
        return @truncate((zobrist_key >> 32) % self.size);
    }

    pub fn put(
        self: *TT,
        zobrist_key: u64,
        depth: u8,
        move: chess.ChessMove,
        score: types.Score,
        flag: TranspositionFlag,
    ) void {
        self.data.items[self.index(zobrist_key)].store(
            Transposition{
                .depth = depth,
                .verification = @truncate(zobrist_key),
                .move = @truncate(move.x),
                .score = score,
                .flag = flag,
            },
            &self.used,
        );
    }

    pub fn probe(self: *TT, zobrist_key: u64) ?Transposition {
        const res = self.data.items[self.index(zobrist_key)].find(@truncate(zobrist_key));
        if (res == null or res.?.flag == TranspositionFlag.None) {
            return null;
        }
        return res;
    }
};

pub var global_tt: TT = undefined;

pub fn initGlobalTranspositionTable(
    allocator: std.mem.Allocator,
    megabytes: usize,
) !void {
    global_tt = try TT.init(allocator, megabytes);
}
