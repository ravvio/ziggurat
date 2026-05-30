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

    pub const A1 = Square.new(56);
    pub const B1 = Square.new(57);
    pub const C1 = Square.new(58);
    pub const D1 = Square.new(59);
    pub const E1 = Square.new(60);
    pub const F1 = Square.new(61);
    pub const G1 = Square.new(62);
    pub const H1 = Square.new(63);

    pub const A2 = Square.new(48);
    pub const B2 = Square.new(49);
    pub const C2 = Square.new(50);
    pub const D2 = Square.new(51);
    pub const E2 = Square.new(52);
    pub const F2 = Square.new(53);
    pub const G2 = Square.new(54);
    pub const H2 = Square.new(55);

    pub const A3 = Square.new(40);
    pub const B3 = Square.new(41);
    pub const C3 = Square.new(42);
    pub const D3 = Square.new(43);
    pub const E3 = Square.new(44);
    pub const F3 = Square.new(45);
    pub const G3 = Square.new(46);
    pub const H3 = Square.new(47);

    pub const A4 = Square.new(32);
    pub const B4 = Square.new(33);
    pub const C4 = Square.new(34);
    pub const D4 = Square.new(35);
    pub const E4 = Square.new(36);
    pub const F4 = Square.new(37);
    pub const G4 = Square.new(38);
    pub const H4 = Square.new(39);

    pub const A5 = Square.new(24);
    pub const B5 = Square.new(25);
    pub const C5 = Square.new(26);
    pub const D5 = Square.new(27);
    pub const E5 = Square.new(28);
    pub const F5 = Square.new(29);
    pub const G5 = Square.new(30);
    pub const H5 = Square.new(31);

    pub const A6 = Square.new(16);
    pub const B6 = Square.new(17);
    pub const C6 = Square.new(18);
    pub const D6 = Square.new(19);
    pub const E6 = Square.new(20);
    pub const F6 = Square.new(21);
    pub const G6 = Square.new(22);
    pub const H6 = Square.new(23);

    pub const A7 = Square.new(8);
    pub const B7 = Square.new(9);
    pub const C7 = Square.new(10);
    pub const D7 = Square.new(11);
    pub const E7 = Square.new(12);
    pub const F7 = Square.new(13);
    pub const G7 = Square.new(14);
    pub const H7 = Square.new(15);

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
        this: @This(),
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{c}{c}", .{
            fileToAlgebraic(@truncate(this.file())),
            rankToAlgebraic(@truncate(this.rank())),
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

    _ = try std.fmt.bufPrint(&buf, "{f}", .{Square.A1});
    try std.testing.expectEqualStrings("a1", &buf);

    _ = try std.fmt.bufPrint(&buf, "{f}", .{Square.G8});
    try std.testing.expectEqualStrings("g8", &buf);
}
