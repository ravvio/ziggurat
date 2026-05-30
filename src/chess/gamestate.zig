const std = @import("std");
const ArrayList = std.ArrayList;
const Square = @import("square.zig").Square;
const pieces = @import("constants.zig").pieces;
const ChessMove = @import("chessmove.zig").ChessMove;
const constants = @import("constants.zig");

fn initCastling() [64]CastlingRights {
    var all: [64]CastlingRights = @splat(CastlingRights.ALL);
    all[Square.A1.x].x ^= CastlingRights.WQ.x;
    all[Square.E1.x].x ^= CastlingRights.WK.x | CastlingRights.WQ.x;
    all[Square.H1.x].x ^= CastlingRights.WK.x;
    all[Square.A8.x].x ^= CastlingRights.BQ.x;
    all[Square.E8.x].x ^= CastlingRights.BK.x | CastlingRights.BQ.x;
    all[Square.H8.x].x ^= CastlingRights.BK.x;
    return all;
}

pub const CastlingRights = struct {
    x: u4,

    pub const SQUARES: [64]CastlingRights = initCastling();

    pub const ZERO = CastlingRights{ .x = 0 };
    pub const WK = CastlingRights{ .x = 1 }; // 0001
    pub const WQ = CastlingRights{ .x = 2 }; // 0010
    pub const BK = CastlingRights{ .x = 4 }; // 0100
    pub const BQ = CastlingRights{ .x = 8 }; // 1000
    pub const ALL = CastlingRights{ .x = 15 }; // 1111

    pub fn format(
        c: CastlingRights,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        w: anytype,
    ) !void {
        try w.print("{s}{s}{s}{s}", .{
            if (c.x & CastlingRights.WK.x > 0) "K" else "",
            if (c.x & CastlingRights.WQ.x > 0) "Q" else "",
            if (c.x & CastlingRights.BK.x > 0) "k" else "",
            if (c.x & CastlingRights.BQ.x > 0) "q" else "",
        });
    }
};

pub const GameState = struct {
    next_move: ChessMove = ChessMove{ .x = 0 },
    zobrist_key: u64 = 0,
    pawn_structure_key: u64 = 0,

    current_side: constants.Color = constants.Colors.white,

    move_number: usize = 1,
    halfmove_clock: usize = 0,

    en_passant: ?Square = null,
    castling: CastlingRights = CastlingRights.ZERO,

    pub fn format(
        s: GameState,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        w: anytype,
    ) !void {
        const ep = if (s.en_passant) |e| e.to_algebraic() else "-";

        try w.print("zk: {x} ac: {b} cperm: {any} ep: {any} hmc: {d} fmc: {d} next:{any}{any}{s}", .{
            s.zobrist_key,
            s.current_side,
            s.castling,
            ep,
            s.halfmove_clock,
            s.move_number,
            Square.new(s.next_move.from()),
            Square.new(s.next_move.to()),
            pieces.toString(s.next_move.promotion()),
        });
    }
};
