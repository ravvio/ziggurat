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
    move: u32 = 0,
    score: types.Score = 0,
    depth: u8 = 0,
    flag: TranspositionFlag = TranspositionFlag.None,
};

const bucket_size: u8 = 4;
const Bucket = struct {
    content: [bucket_size]Transposition = std.mem.zeroes([bucket_size]Transposition),

    pub fn store(self: *Bucket, item: Transposition, used: *usize) void {
        // Find the item in the bucket that has the highest depth
        // or an unused one
        var index: usize = 0;
        var high_depth: u8 = 0;
        var unused: bool = false;
        for (0..bucket_size) |i| {
            if (self.content[index].verification == 0) {
                index = i;
                unused = true;
                break;
            }
            if (self.content[i].depth > high_depth) {
                index = i;
                high_depth = item.depth;
            }
        }
        const high = &self.content[index];
        // Verification is 0 so the entry is still unused
        if (high.verification == 0) {
            used.* += 1;
        }
        high.* = item;
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

pub const TT = struct {
    megabytes: usize,
    size: usize,
    used: usize = 0,
    data: []Bucket,

    pub fn init(allocator: std.mem.Allocator, megabytes: usize) !TT {
        const bucket_bytes = @sizeOf(Transposition) * bucket_size;
        const size = @divTrunc(megabytes * 1024 * 1024, bucket_bytes);

        var tt = TT{
            .megabytes = megabytes,
            .size = size,
            .data = try allocator.alloc(Bucket, size),
        };
        for (0..tt.data.len) |i| {
            tt.data[i] = Bucket{};
        }
        return tt;
    }

    pub fn deinit(self: *TT, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn clear(self: *TT) void {
        self.used = 0;
        for (0..self.data.len) |i| {
            self.data[i] = Bucket{};
        }
    }

    /// Reports the occupancy of the table in permillis
    pub fn occupancy(self: *TT) usize {
        if (self.size > 0) {
            return @divTrunc(1000 * self.used, bucket_size * self.size);
        } else {
            return 0;
        }
    }

    pub inline fn index(self: *TT, zobrist_key: u64) usize {
        // Use only the upper half of the Zobrist key for this, so the lower
        // half can be used to calculate a verification.
        return @truncate((zobrist_key >> 32) % self.size);
    }

    pub fn prefetch(self: *TT, zobrist_key: u64) void {
        @prefetch(
            &self.data[self.index(zobrist_key)],
            .{
                .rw = .read,
                .locality = 1,
                .cache = .data,
            },
        );
    }

    pub fn put(
        self: *TT,
        zobrist_key: u64,
        depth: u8,
        move_: chess.ChessMove,
        score: types.Score,
        flag: TranspositionFlag,
    ) void {
        var move = move_;
        move.removeSortScore();
        self.data[self.index(zobrist_key)].store(
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

    pub inline fn probe(self: *TT, zobrist_key: u64) ?Transposition {
        const res = self.data[self.index(zobrist_key)].find(@truncate(zobrist_key));
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
