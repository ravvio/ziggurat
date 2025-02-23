const std = @import("std");
const ArrayList = std.ArrayList;

const bb = @import("./bitboard.zig");
const GameState = @import("./gamestate.zig").GameState;
const CastlingRights = @import("./gamestate.zig").CastlingRights;
const ZobristValues = @import("./zobrist.zig").ZobristValues;
const ChessMove = @import("./chessmove.zig").ChessMove;
const Square = @import("./square.zig").Square;
const constants = @import("./constants.zig");

const BoardError = error{InvalidFen};

pub const Board = struct {
    boards: [2][6]u64,

    white: u64,
    black: u64,

    occupied: u64,
    checkers: u64,
    pinned: u64,

    pieces: [64]usize,

    state: GameState,
    history: ArrayList(GameState),

    zobrist_values: ZobristValues,

    pub fn fromFen(
        alloc: std.mem.Allocator,
        fen: []const u8,
    ) !Board {
        var it = std.mem.split(u8, fen, " ");
        var splits = std.ArrayList([]const u8).init(alloc);
        while (it.next()) |split| {
            try splits.append(split);
        }

        if (splits.items.len < 4 or splits.items.len > 6) {
            return BoardError.InvalidFen;
        }

        // Part 1 - Pieces
        var boards = std.mem.zeroes([2][6]u64);
        var pieces: [64]u64 = [_]u64{constants.pieces.NONE} ** 64;
        var index: usize = 0;
        for (splits.items[0]) |c| {
            switch (c) {
                'k' => {
                    boards[0][0] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.KING;
                },
                'q' => {
                    boards[0][1] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.QUEEN;
                },
                'r' => {
                    boards[0][2] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.ROOK;
                },
                'b' => {
                    boards[0][3] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.BISHOP;
                },
                'n' => {
                    boards[0][4] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.KNIGHT;
                },
                'p' => {
                    boards[0][5] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.PAWN;
                },
                'K' => {
                    boards[1][0] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.KING;
                },
                'Q' => {
                    boards[1][1] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.QUEEN;
                },
                'R' => {
                    boards[1][2] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.ROOK;
                },
                'B' => {
                    boards[1][3] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.BISHOP;
                },
                'N' => {
                    boards[1][4] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.KNIGHT;
                },
                'P' => {
                    boards[1][5] ^= bb.SQUARES[index];
                    pieces[index] = constants.pieces.PAWN;
                },
                '1', '2', '3', '4', '5', '6', '7', '8' => {
                    const x = try std.fmt.parseInt(usize, &[1]u8{c}, 10);
                    index += x - 1;
                },
                '/' => {},
                else => {
                    return BoardError.InvalidFen;
                },
            }

            if (c != '/') {
                index += 1;
            }
        }

        if (index != 64) {
            return BoardError.InvalidFen;
        }

        // Part 2 - Color to play
        var current_side: bool = undefined;
        const side = splits.items[1];
        if (side.len != 1) {
            return BoardError.InvalidFen;
        }
        switch (splits.items[1][0]) {
            'w' => current_side = true,
            'b' => current_side = false,
            else => {
                return BoardError.InvalidFen;
            },
        }

        // Part 3 - Castling
        var castling_rights = CastlingRights.ZERO;
        const castling = splits.items[2];
        if (castling.len > 4) {
            return BoardError.InvalidFen;
        }
        for (castling) |c| {
            switch (c) {
                'k' => castling_rights.x |= CastlingRights.BK.x,
                'q' => castling_rights.x |= CastlingRights.BQ.x,
                'K' => castling_rights.x |= CastlingRights.WK.x,
                'Q' => castling_rights.x |= CastlingRights.WQ.x,
                '-' => {},
                else => return BoardError.InvalidFen,
            }
        }

        // Part 4 - En Passant
        var en_passant: ?Square = null;
        const enpassant = splits.items[3];
        if (!std.mem.eql(u8, enpassant, "-")) {
            if (enpassant.len != 2) {
                return BoardError.InvalidFen;
            }
            en_passant = try Square.fromAlgebraic(enpassant[0..2]);
        }

        // Part 5 - Halfmove clock
        var halfmove_clock: usize = 0;
        if (splits.items.len > 4) {
            const halfmove = splits.items[4];
            halfmove_clock = try std.fmt.parseInt(usize, halfmove, 10);
        }

        // Part 6 - Move number
        var move_number: usize = 1;
        if (splits.items.len > 5) {
            const movenum = splits.items[5];
            move_number = try std.fmt.parseInt(usize, movenum, 10);
        }

        // Derive others
        var black: u64 = 0;
        for (boards[0]) |b| {
            black |= b;
        }
        var white: u64 = 0;
        for (boards[1]) |b| {
            white |= b;
        }

        // TODO - checkers and pinned

        var b = Board{
            .boards = boards,
            .white = white,
            .black = black,
            .occupied = white | black,
            .checkers = 0,
            .pinned = 0,
            .pieces = pieces,
            .zobrist_values = ZobristValues.new(),
            .history = ArrayList(GameState).init(alloc),
            .state = GameState{
                .current_side = current_side,
                .move_number = move_number,
                .halfmove_clock = halfmove_clock,
                .en_passant = en_passant,
                .castling = castling_rights,
                .next_move = ChessMove{ .x = 0 },
                .zobrist_key = 0,
            },
        };
        b.regenerateZobrist();

        return b;
    }

    pub fn deinit(
        b: *Board,
    ) void {
        b.history.deinit();
    }

    pub fn regenerateZobrist(
        b: *Board,
    ) void {
        var z: u64 = 0;
        // Pieces
        var iterator_w = bb.BitboardIterator{ .u = b.white };
        while (iterator_w.next()) |sq| {
            const piece = b.pieces[sq];
            z ^= b.zobrist_values.pieces[0][piece][sq];
        }
        var iterator_b = bb.BitboardIterator{ .u = b.black };
        while (iterator_b.next()) |sq| {
            const piece = b.pieces[sq];
            z ^= b.zobrist_values.pieces[1][piece][sq];
        }
        // Castling
        z ^= b.zobrist_values.castling[b.state.castling.x];
        // Side
        if (b.state.current_side) {
            z ^= b.zobrist_values.color;
        }
        // En passant
        if (b.state.en_passant) |*s| {
            z ^= b.zobrist_values.en_passant[s.*.x];
        } else {
            z ^= b.zobrist_values.en_passant[64];
        }

        b.state.zobrist_key = z;
    }

    // Makes a move on the board.
    // This method does not checks the legality
    pub fn makeMove(
        b: *Board,
        move: ChessMove,
    ) void {
        // Store unmake info
        var state = b.state;
        state.next_move = move;
        b.history.append(state) catch {
            @panic("Tried to append to history but failed");
        };

        // Shorthands
        const color = b.state.current_side;
        const capture = move.capture();
        const piece = move.piece();
        const from = move.from();
        const to = move.to();

        // Capture
        if (capture != constants.pieces.NONE) {
            b.removePiece(!color, capture, to);
            // Remove castling rights if rook was captured
            if (b.state.castling.x > 0 and capture == constants.pieces.ROOK) {
                b.updateCastlingRights(b.state.castling.x & CastlingRights.SQUARES[to].x);
            }
        }

        if (piece != constants.pieces.PAWN) { // Not pawn
            b.movePiece(color, piece, from, to);

            if (b.state.en_passant != null) {
                b.removeEnPassant();
            }
            b.state.halfmove_clock += 1;

            // If the king is castling, also move the rook
            if (move.castling()) {
                switch (to) {
                    Square.G1.x => b.movePiece(color, constants.pieces.ROOK, Square.H1.x, Square.F1.x),
                    Square.C1.x => b.movePiece(color, constants.pieces.ROOK, Square.A1.x, Square.D1.x),
                    Square.G8.x => b.movePiece(color, constants.pieces.ROOK, Square.H8.x, Square.F8.x),
                    Square.C8.x => b.movePiece(color, constants.pieces.ROOK, Square.A8.x, Square.D8.x),
                    else => {
                        bb.debugPrint(bb.SQUARES[to]);
                        @panic("Invalid castling square");
                    },
                }
            }
            // Remove castling rights if is a king or rook move
            if (b.state.castling.x > 0 and (piece == constants.pieces.KING or piece == constants.pieces.ROOK)) {
                b.updateCastlingRights(b.state.castling.x & CastlingRights.SQUARES[from].x);
            }
        } else { // Pawn
            const promotion = move.promotion();
            if (promotion == constants.pieces.NONE) {
                b.movePiece(color, piece, from, to);
            } else {
                b.removePiece(color, piece, from);
                b.addPiece(color, promotion, to);
            }
            // Reset half move clock
            b.state.halfmove_clock = 0;

            if (move.enPassant()) {
                // The move was an en passant, remove opponent pawn
                b.removePiece(!color, constants.pieces.PAWN, to ^ 8);
                b.removeEnPassant();
            } else if (move.doubleStep()) {
                b.setEnPassant(to ^ 8);
            } else if (b.state.en_passant != null) {
                b.removeEnPassant();
            }
        }

        // Swap side
        b.swapSide();
        b.occupied = b.white | b.black;

        // Add move number and check if the move is legal
        if (color) {
            b.state.move_number += 1;
        }
    }

    pub fn unmakeMove(b: *Board) void {
        b.state = b.history.pop();

        // Shorthands
        const color = b.state.current_side;
        const move = b.state.next_move;
        const piece = move.piece();
        const from = move.from();
        const to = move.to();
        const promotion = move.promotion();
        const capture = move.capture();

        if (promotion == constants.pieces.NONE) {
            b.undoMovePiece(color, piece, from, to);
        } else {
            b.undoAddPiece(color, promotion, to);
            b.undoRemovePiece(color, constants.pieces.PAWN, from);
        }

        if (move.enPassant()) {
            // If it was an enpassant, put the opponent pawn back
            std.debug.assert(piece == constants.pieces.PAWN);
            b.undoRemovePiece(!color, constants.pieces.PAWN, to ^ 8);
        } else if (capture != constants.pieces.NONE) {
            // If a piece was captured put it back
            b.undoRemovePiece(!color, capture, to);
        } else if (move.castling()) {
            // The king's move was already undone, undo the rook move
            switch (to) {
                Square.G1.x => b.undoMovePiece(color, constants.pieces.ROOK, Square.H1.x, Square.F1.x),
                Square.C1.x => b.undoMovePiece(color, constants.pieces.ROOK, Square.A1.x, Square.D1.x),
                Square.G8.x => b.undoMovePiece(color, constants.pieces.ROOK, Square.H8.x, Square.F8.x),
                Square.C8.x => b.undoMovePiece(color, constants.pieces.ROOK, Square.A8.x, Square.D8.x),
                else => {
                    bb.debugPrint(bb.SQUARES[to]);
                    @panic("Invlid castling square");
                },
            }
        }

        b.occupied = b.white | b.black;
    }

    pub fn swapSide(b: *Board) void {
        b.state.zobrist_key ^= b.zobrist_values.color;
        b.state.current_side = !b.state.current_side;
    }

    pub fn removeEnPassant(b: *Board) void {
        b.state.zobrist_key ^= b.zobrist_values.en_passant[b.state.en_passant.?.x];
        b.state.en_passant = null;
        b.state.zobrist_key ^= b.zobrist_values.en_passant[64];
    }

    pub fn setEnPassant(
        b: *Board,
        sq: usize,
    ) void {
        if (b.state.en_passant) |en| {
            b.state.zobrist_key ^= b.zobrist_values.en_passant[en.x];
        }
        b.state.en_passant = Square.new(sq);
        b.state.zobrist_key ^= b.zobrist_values.en_passant[sq];
    }

    pub fn removePiece(
        b: *Board,
        color: bool,
        piece: usize,
        sq: usize,
    ) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] ^= tmp;
        if (color) {
            b.white ^= tmp;
        } else {
            b.black ^= tmp;
        }
        b.pieces[sq] = constants.pieces.NONE;
        b.state.zobrist_key ^= b.zobrist_values.pieces[@intFromBool(color)][piece][sq];
    }

    pub fn addPiece(
        b: *Board,
        color: bool,
        piece: usize,
        sq: usize,
    ) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] |= tmp;
        if (color) {
            b.white |= tmp;
        } else {
            b.black |= tmp;
        }
        b.pieces[sq] = piece;
        b.state.zobrist_key ^= b.zobrist_values.pieces[@intFromBool(color)][piece][sq];
    }

    pub fn movePiece(
        b: *Board,
        color: bool,
        piece: usize,
        from: usize,
        to: usize,
    ) void {
        const bf = bb.SQUARES[from];
        const bt = bb.SQUARES[to];
        const board = &b.boards[@intFromBool(color)][piece];
        board.* = (board.* ^ bf) | bt;
        if (color) {
            b.white = (b.white ^ bf) | bt;
        } else {
            b.black = (b.black ^ bf) | bt;
        }
        b.pieces[from] = constants.pieces.NONE;
        b.pieces[to] = piece;
        const z = &b.zobrist_values.pieces[@intFromBool(color)][piece];
        b.state.zobrist_key = b.state.zobrist_key ^ z[from] ^ z[to];
    }

    // Popping the move from the history automatically restores a lot of value
    // so we need some different methods for undoing adding and removing pieces
    // so to not interfere with already restored values

    pub fn undoAddPiece(b: *Board, color: bool, piece: usize, sq: usize) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] ^= tmp;
        if (color) {
            b.white ^= tmp;
        } else {
            b.black ^= tmp;
        }
        b.pieces[sq] = constants.pieces.NONE;
    }

    pub fn undoRemovePiece(b: *Board, color: bool, piece: usize, sq: usize) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] |= tmp;
        if (color) {
            b.white |= tmp;
        } else {
            b.black |= tmp;
        }
        b.pieces[sq] = piece;
    }

    pub fn undoMovePiece(b: *Board, color: bool, piece: usize, from: usize, to: usize) void {
        const tmpFrom = bb.SQUARES[from];
        const tmpTo = bb.SQUARES[to];
        const tmp = &b.boards[@intFromBool(color)][piece];
        tmp.* = (tmp.* ^ tmpTo) | tmpFrom;
        if (color) {
            b.white = (b.white ^ tmpTo) | tmpFrom;
        } else {
            b.black = (b.black ^ tmpTo) | tmpFrom;
        }
        b.pieces[to] = constants.pieces.NONE;
        b.pieces[from] = piece;
    }

    pub fn updateCastlingRights(b: *Board, new: u4) void {
        b.state.zobrist_key ^= b.zobrist_values.castling[b.state.castling.x];
        b.state.castling = CastlingRights{ .x = new };
        b.state.zobrist_key ^= b.zobrist_values.castling[new];
    }

    pub fn kingSquare(
        b: *const Board,
        white: bool,
    ) Square {
        return Square.new(@ctz(b.boards[@intFromBool(white)][0]));
    }

    pub fn queens(b: *const Board, white: bool) u64 {
        return b.boards[@intFromBool(white)][1];
    }

    pub fn rooks(b: *const Board, white: bool) u64 {
        return b.boards[@intFromBool(white)][2];
    }

    pub fn bishops(b: *const Board, white: bool) u64 {
        return b.boards[@intFromBool(white)][3];
    }

    pub fn knights(b: *const Board, white: bool) u64 {
        return b.boards[@intFromBool(white)][4];
    }

    pub fn pawns(b: *const Board, white: bool) u64 {
        return b.boards[@intFromBool(white)][5];
    }

    pub fn friends(
        b: *const Board,
        white: bool,
    ) u64 {
        if (white) {
            return b.white;
        } else {
            return b.black;
        }
    }
};
