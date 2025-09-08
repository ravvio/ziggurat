/// Move is stored in a 32 bit field
///
/// 32          | 24       | 23     | 22     | 21   | 18      | 15      |  9      |  3
/// -8          | -1       | -1     | -1     | -3   | -3      | -6      | -6      | -3
/// 00_000_000  | 0        | 0      | 0      | 000  | 000     | 000_000 | 000_000 | 000
/// SORT        | CASTLING | DOUBLE | ENPASS | PROM | CAPTURE | TO      | FROM    | PIECE
///
/// Piece codes (also used for captures and promotion)
/// King   000 0
/// Queen  001 1
/// Rook   010 2
/// Bishop 011 3
/// Knight 100 4
/// Pawn   101 5
/// Null   110 6
const std = @import("std");
const Square = @import("square.zig").Square;
const pieces = @import("constants.zig").pieces;

pub const ChessMove = struct {
    x: usize = 0,

    const bits = struct {
        pub const ONE: usize = 0b1;
        pub const THREE: usize = 0b111;
        pub const SIX: usize = 0b111111;
        pub const EIGHT: usize = 0b11111111;
        pub const no_sort_mask: usize = 0x00FF_FFFF;
    };

    pub const shift = struct {
        pub const PIECE: usize = 0;
        pub const FROM: usize = 3;
        pub const TO: usize = 9;
        pub const CAPTURE: usize = 15;
        pub const PROMOTION: usize = 18;
        pub const ENPASSANT: usize = 21;
        pub const DOUBLE_STEP: usize = 22;
        pub const CASTLING: usize = 23;
        pub const SORT: usize = 24;
    };

    pub fn format(
        this: @This(),
        writer: *std.io.Writer,
    ) std.io.Writer.Error!void {
        try writer.print("{f}{f}{s}", .{
            Square.new(this.from()),
            Square.new(this.to()),
            if (this.promotion() == pieces.NONE) "" else pieces.toString(this.promotion()),
        });
    }

    pub fn piece(m: ChessMove) usize {
        return (m.x >> shift.PIECE) & bits.THREE;
    }

    pub fn from(m: ChessMove) usize {
        return (m.x >> shift.FROM) & bits.SIX;
    }

    pub fn to(m: ChessMove) usize {
        return (m.x >> shift.TO) & bits.SIX;
    }

    pub fn capture(m: ChessMove) usize {
        return (m.x >> shift.CAPTURE) & bits.THREE;
    }

    pub fn is_capture(m: ChessMove) bool {
        return ((m.x >> shift.CAPTURE) & bits.THREE) != pieces.NONE;
    }

    pub fn promotion(m: ChessMove) usize {
        return (m.x >> shift.PROMOTION) & bits.THREE;
    }

    pub fn is_promotion(m: ChessMove) bool {
        return ((m.x >> shift.PROMOTION) & bits.THREE) != pieces.NONE;
    }

    pub fn enPassant(m: ChessMove) bool {
        return (m.x >> shift.ENPASSANT) & bits.ONE == 1;
    }

    pub fn doubleStep(m: ChessMove) bool {
        return (m.x >> shift.DOUBLE_STEP) & bits.ONE == 1;
    }

    pub fn castling(m: ChessMove) bool {
        return (m.x >> shift.CASTLING) & bits.ONE == 1;
    }

    pub fn getSortScore(m: ChessMove) usize {
        return m.x >> shift.SORT;
    }

    pub fn setSortScore(m: *ChessMove, v: u8) void {
        m.x |= (@as(usize, v) << shift.SORT);
    }

    pub fn removeSortScore(m: *ChessMove) void {
        m.x &= bits.no_sort_mask;
        std.debug.assert(m.getSortScore() == 0);
    }

    pub fn withoutSortScore(m: *const ChessMove) ChessMove {
        return ChessMove{ .x = m.x & bits.no_sort_mask };
    }
};
