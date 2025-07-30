const ChessError = @import("errors.zig").ChessError;

pub const MoveType = enum {
    All,
    Quiet,
    Capture,
    CheckDefence,
};

pub const Fen = struct {
    pub const STARTPOS = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    pub const KIWIPETE = "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -";
};

pub const Direction = enum {
    Up,
    Down,
    Left,
    Right,
    UpLeft,
    UpRight,
    DownLeft,
    DownRight,
};

pub const files = struct {
    pub const A: usize = 0;
    pub const B: usize = 1;
    pub const C: usize = 2;
    pub const D: usize = 3;
    pub const E: usize = 4;
    pub const F: usize = 5;
    pub const G: usize = 6;
    pub const H: usize = 7;
};

pub const ranks = struct {
    pub const R1: usize = 7;
    pub const R2: usize = 6;
    pub const R3: usize = 5;
    pub const R4: usize = 4;
    pub const R5: usize = 3;
    pub const R6: usize = 2;
    pub const R7: usize = 1;
    pub const R8: usize = 0;
};

pub const pieces = struct {
    pub const KING: usize = 0;
    pub const QUEEN: usize = 1;
    pub const ROOK: usize = 2;
    pub const BISHOP: usize = 3;
    pub const KNIGHT: usize = 4;
    pub const PAWN: usize = 5;
    pub const NONE: usize = 6;

    pub const PROMOTION_PIECES = [4]usize{ QUEEN, ROOK, BISHOP, KNIGHT };

    pub fn isPromotionPiece(p: usize) bool {
        return p == QUEEN or p == ROOK or p == BISHOP or p == KNIGHT;
    }

    pub fn from(s: u8) ChessError!usize {
        return switch (s) {
            'k' => 0,
            'q' => 1,
            'r' => 2,
            'b' => 3,
            'n' => 4,
            'p' => 5,
            else => ChessError.InvalidPieceString,
        };
    }

    pub fn toString(p: usize) *const [1:0]u8 {
        return switch (p) {
            0 => "k",
            1 => "q",
            2 => "r",
            3 => "b",
            4 => "n",
            5 => "p",
            6 => " ",
            else => @panic("Non existing piece"),
        };
    }
};

pub const Color = bool;
pub const Colors = struct {
    pub const white: Color = true;
    pub const black: Color = false;
};

pub const MAX_LEGAL_MOVES: usize = 218;
pub const MAX_PSEUDO_MOVES: usize = 512;
pub const MAX_GAME_MOVES: usize = 2048;
