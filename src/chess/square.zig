const std = @import("std");
const assert = std.debug.assert;
const ChessError = @import("errors.zig").ChessError;

pub const Square = struct {
    x: usize,

    pub fn new(x: usize) Square {
        return .{ .x = x };
    }

    pub const EMPTY = Square.new(0);

    pub const ALL_SQUARES = [64]Square{
        Square.new(0),
        Square.new(1),
        Square.new(2),
        Square.new(3),
        Square.new(4),
        Square.new(5),
        Square.new(6),
        Square.new(7),
        Square.new(8),
        Square.new(9),
        Square.new(10),
        Square.new(11),
        Square.new(12),
        Square.new(13),
        Square.new(14),
        Square.new(15),
        Square.new(16),
        Square.new(17),
        Square.new(18),
        Square.new(19),
        Square.new(20),
        Square.new(21),
        Square.new(22),
        Square.new(23),
        Square.new(24),
        Square.new(25),
        Square.new(26),
        Square.new(27),
        Square.new(28),
        Square.new(29),
        Square.new(30),
        Square.new(31),
        Square.new(32),
        Square.new(33),
        Square.new(34),
        Square.new(35),
        Square.new(36),
        Square.new(37),
        Square.new(38),
        Square.new(39),
        Square.new(40),
        Square.new(41),
        Square.new(42),
        Square.new(43),
        Square.new(44),
        Square.new(45),
        Square.new(46),
        Square.new(47),
        Square.new(48),
        Square.new(49),
        Square.new(50),
        Square.new(51),
        Square.new(52),
        Square.new(53),
        Square.new(54),
        Square.new(55),
        Square.new(56),
        Square.new(57),
        Square.new(58),
        Square.new(59),
        Square.new(60),
        Square.new(61),
        Square.new(62),
        Square.new(63),
    };

    // White side squares that are important for castling
    pub const A1 = Square.new(56);
    pub const B1 = Square.new(57);
    pub const C1 = Square.new(58);
    pub const D1 = Square.new(59);
    pub const E1 = Square.new(60);
    pub const F1 = Square.new(61);
    pub const G1 = Square.new(62);
    pub const H1 = Square.new(63);

    // Black side squares that are important for castling
    pub const A8 = Square.new(0);
    pub const B8 = Square.new(1);
    pub const C8 = Square.new(2);
    pub const D8 = Square.new(3);
    pub const E8 = Square.new(4);
    pub const F8 = Square.new(5);
    pub const G8 = Square.new(6);
    pub const H8 = Square.new(7);

    pub fn rank_bits(s: Square) u8 {
        const v: u8 = @intCast(s.x);
        return (v >> 3) & 0b111;
    }

    pub fn file_bits(s: Square) u8 {
        const v: u8 = @intCast(s.x);
        return v & 0b111;
    }

    pub fn rank(s: Square) usize {
        return s.x / 8;
    }

    pub fn file(s: Square) usize {
        return s.x % 8;
    }

    pub fn fromFileAndRank(f: usize, r: usize) Square {
        return Square.new(f + r * 8);
    }

    pub fn nord(s: Square) Square {
        assert(s.rank() != 0);
        return Square.new(s.x - 8);
    }

    pub fn sud(s: Square) Square {
        assert(s.rank() != 7);
        return Square.new(s.x + 8);
    }

    pub fn west(s: Square) Square {
        assert(s.file() != 0);
        return Square.new(s.x - 1);
    }

    pub fn east(s: Square) Square {
        assert(s.file() != 7);
        return Square.new(s.x + 1);
    }

    pub fn nordWest(s: Square) Square {
        assert(s.rank() != 0);
        assert(s.file() != 0);
        return Square.new(s.x - 9);
    }

    pub fn nordEst(s: Square) Square {
        assert(s.rank() != 0);
        assert(s.file() != 7);
        return Square.new(s.x - 7);
    }

    pub fn sudWest(s: Square) Square {
        assert(s.rank() != 7);
        assert(s.file() != 0);
        return Square.new(s.x + 7);
    }

    pub fn sudEst(s: Square) Square {
        assert(s.rank() != 7);
        assert(s.file() != 7);
        return Square.new(s.x + 9);
    }

    pub fn fileFromAlgebraic(n: u8) !u8 {
        if (n < 97 or n > 104) {
            return ChessError.InvalidAlgebraicSquare;
        }
        return n - 97;
    }

    pub fn fileToAlgebraic(f: u8) u8 {
        assert(f <= 0b111);
        return f + 97;
    }

    pub fn rankFromAlgebraic(n: u8) !u8 {
        if (n < 49 or n > 56) {
            return ChessError.InvalidAlgebraicSquare;
        }
        return 56 - n;
    }

    pub fn rankToAlgebraic(r: u8) u8 {
        assert(r <= 0b111);
        return 56 - r;
    }

    pub fn fromAlgebraic(alg: *const [2]u8) !Square {
        const f = try Square.fileFromAlgebraic(alg[0]);
        const r = try Square.rankFromAlgebraic(alg[1]);
        return Square.fromFileAndRank(f, r);
    }

    pub fn format(
        s: Square,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        w: anytype,
    ) !void {
        try w.print("{c}{c}", .{
            fileToAlgebraic(@truncate(s.file())),
            rankToAlgebraic(@truncate(s.rank())),
        });
    }
};

test "square_position" {
    const s1 = Square.A1;
    try std.testing.expectEqual(7, s1.rank());
    try std.testing.expectEqual(0, s1.file());
    try std.testing.expectEqual(Square.fromFileAndRank(0, 7).x, s1.x);

    const s2 = Square.H8;
    try std.testing.expectEqual(0, s2.rank());
    try std.testing.expectEqual(7, s2.file());
    try std.testing.expectEqual(Square.fromFileAndRank(7, 0).x, s2.x);
}

test "movement" {
    const s1 = Square.B1;
    try std.testing.expectEqual(Square.fromFileAndRank(1, 6).x, s1.nord().x);
    try std.testing.expectEqual(Square.fromFileAndRank(2, 7).x, s1.east().x);
    try std.testing.expectEqual(Square.fromFileAndRank(2, 6).x, s1.nordEst().x);
    try std.testing.expectEqual(Square.fromFileAndRank(0, 6).x, s1.nordWest().x);

    const s2 = Square.G8;
    try std.testing.expectEqual(Square.fromFileAndRank(6, 1).x, s2.sud().x);
    try std.testing.expectEqual(Square.fromFileAndRank(5, 0).x, s2.west().x);
    try std.testing.expectEqual(Square.fromFileAndRank(5, 1).x, s2.sudWest().x);
    try std.testing.expectEqual(Square.fromFileAndRank(7, 1).x, s2.sudEst().x);
}

test "from algebraic" {
    const a1 = "a1";
    const sA1 = try Square.fromAlgebraic(a1);
    try std.testing.expectEqual(Square.A1.x, sA1.x);

    const h8 = "h8";
    const sH8 = try Square.fromAlgebraic(h8);
    try std.testing.expectEqual(Square.H8.x, sH8.x);
}

test "format square" {
    var buf: [2:0]u8 = undefined;

    _ = try std.fmt.bufPrint(&buf, "{any}", .{Square.A1});
    try std.testing.expectEqualStrings("a1", &buf);

    _ = try std.fmt.bufPrint(&buf, "{any}", .{Square.G8});
    try std.testing.expectEqualStrings("g8", &buf);
}
