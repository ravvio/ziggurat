const std = @import("std");
const ArrayList = std.ArrayList;

const bb = @import("./bitboard.zig");
const GameState = @import("./gamestate.zig").GameState;
const CastlingRights = @import("./gamestate.zig").CastlingRights;
const ZobristValues = @import("./zobrist.zig").ZobristValues;
const ChessMove = @import("./chessmove.zig").ChessMove;
const Square = @import("./square.zig").Square;
const Movelist = @import("movelist.zig").Movelist;
const ChessError = @import("errors.zig").ChessError;
const constants = @import("./constants.zig");
const pieces = constants.pieces;
const MoveType = constants.MoveType;
const tables = @import("tables.zig");

pub const Board = struct {
    boards: [2][6]u64 = std.mem.zeroes([2][6]u64),

    colors: [2]u64 = std.mem.zeroes([2]u64),

    occupied: u64 = 0,
    checkers: u64 = 0,
    pinned: u64 = 0,

    pieces: [64]usize = [1]usize{constants.pieces.NONE} ** 64,

    state: GameState,
    history: ArrayList(GameState),

    zobrist_values: ZobristValues,

    pub fn init(alloc: std.mem.Allocator) Board {
        const history = ArrayList(GameState).init(alloc);
        return .{
            .state = GameState{},
            .history = history,
            .zobrist_values = ZobristValues.new(),
        };
    }

    pub fn setFen(self: *Board, fen: []const u8) !void {
        var it = std.mem.split(u8, fen, " ");

        self.history.clearAndFree();

        // Part 1 - Pieces
        const split = it.next();
        if (split == null) {
            return ChessError.InvalidFen;
        }
        self.pieces = [1]usize{constants.pieces.NONE} ** 64;
        self.boards = std.mem.zeroes([2][6]u64);
        var index: usize = 0;
        for (split.?) |c| {
            switch (c) {
                'k' => {
                    self.boards[0][0] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.KING;
                },
                'q' => {
                    self.boards[0][1] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.QUEEN;
                },
                'r' => {
                    self.boards[0][2] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.ROOK;
                },
                'b' => {
                    self.boards[0][3] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.BISHOP;
                },
                'n' => {
                    self.boards[0][4] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.KNIGHT;
                },
                'p' => {
                    self.boards[0][5] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.PAWN;
                },
                'K' => {
                    self.boards[1][0] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.KING;
                },
                'Q' => {
                    self.boards[1][1] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.QUEEN;
                },
                'R' => {
                    self.boards[1][2] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.ROOK;
                },
                'B' => {
                    self.boards[1][3] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.BISHOP;
                },
                'N' => {
                    self.boards[1][4] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.KNIGHT;
                },
                'P' => {
                    self.boards[1][5] ^= bb.SQUARES[index];
                    self.pieces[index] = constants.pieces.PAWN;
                },
                '1', '2', '3', '4', '5', '6', '7', '8' => {
                    const x = try std.fmt.parseInt(usize, &[1]u8{c}, 10);
                    index += x - 1;
                },
                '/' => {},
                else => {
                    return ChessError.InvalidFen;
                },
            }

            if (c != '/') {
                index += 1;
            }
        }

        if (index != 64) {
            return ChessError.InvalidFen;
        }

        // Part 2 - Color to play
        if (it.next()) |side| {
            if (side.len != 1) {
                return ChessError.InvalidFen;
            }
            switch (side[0]) {
                'w' => self.state.current_side = true,
                'b' => self.state.current_side = false,
                else => {
                    return ChessError.InvalidFen;
                },
            }
        } else {
            return ChessError.InvalidFen;
        }

        // Part 3 - Castling
        self.state.castling = CastlingRights.ZERO;
        if (it.next()) |castling| {
            if (castling.len > 4) {
                return ChessError.InvalidFen;
            }
            for (castling) |c| {
                switch (c) {
                    'k' => self.state.castling.x |= CastlingRights.BK.x,
                    'q' => self.state.castling.x |= CastlingRights.BQ.x,
                    'K' => self.state.castling.x |= CastlingRights.WK.x,
                    'Q' => self.state.castling.x |= CastlingRights.WQ.x,
                    '-' => {},
                    else => return ChessError.InvalidFen,
                }
            }
        } else {
            return ChessError.InvalidFen;
        }

        // Part 4 - En Passant
        if (it.next()) |enpassant| {
            if (!std.mem.eql(u8, enpassant, "-")) {
                if (enpassant.len != 2) {
                    return ChessError.InvalidFen;
                }
                self.state.en_passant = try Square.fromAlgebraic(enpassant[0..2]);
            }
        } else {
            return ChessError.InvalidFen;
        }

        // Part 5 - Halfmove clock
        if (it.next()) |halfmove| {
            self.state.halfmove_clock = try std.fmt.parseInt(usize, halfmove, 10);
        } else {
            self.state.halfmove_clock = 0;
        }

        // Part 6 - Move number
        if (it.next()) |movenum| {
            self.state.move_number = try std.fmt.parseInt(usize, movenum, 10);
        } else {
            self.state.move_number = 1;
        }

        // Derive others
        self.colors = std.mem.zeroes([2]u64);
        for (self.boards[0]) |b| {
            self.colors[0] |= b;
        }
        for (self.boards[1]) |b| {
            self.colors[1] |= b;
        }
        self.occupied = self.colors[0] | self.colors[1];

        self.regenerateZobrist();
    }

    pub fn fromFen(
        alloc: std.mem.Allocator,
        fen: []const u8,
    ) !Board {
        var res = init(alloc);
        try res.setFen(fen);
        return res;
    }

    pub fn deinit(b: *Board) void {
        b.history.deinit();
    }

    pub fn parseMove(b: *Board, str: []const u8) ChessError!ChessMove {
        if (str.len != 4 and str.len != 5) {
            return ChessError.InvalidMove;
        }

        const from = try Square.fromAlgebraic(str[0..2]);
        const to = try Square.fromAlgebraic(str[2..4]);
        const promotion = if (str.len == 5) try pieces.from(str[4]) else pieces.NONE;

        if (promotion != pieces.NONE and !pieces.isPromotionPiece(promotion)) {
            return ChessError.InvalidPromotionPiece;
        }

        var ml = Movelist.new();

        // Deterine if the move is pseudo legal
        if (b.state.current_side) {
            b.generatePseudolegalMoves(
                constants.MoveType.All,
                true,
                &ml,
            );
        } else {
            b.generatePseudolegalMoves(
                constants.MoveType.All,
                false,
                &ml,
            );
        }

        var i: usize = 0;
        while (i < ml.count) : (i += 1) {
            var current = ml.list[i];
            // If the move from, to and promotion are the same
            // then we have found a valid move
            if (current.from() == from.x and current.to() == to.x and current.promotion() == promotion) {
                return current;
            }
        }
        // We have found nothing, the move is not legal
        return ChessError.NonPseudolegalMove;
    }

    pub fn regenerateZobrist(b: *Board) void {
        var z: u64 = 0;
        // Pieces
        var iterator_b = bb.BitboardIterator{ .u = b.colors[0] };
        while (iterator_b.next()) |sq| {
            const piece = b.pieces[sq];
            z ^= b.zobrist_values.pieces[0][piece][sq];
        }
        var iterator_w = bb.BitboardIterator{ .u = b.colors[1] };
        while (iterator_w.next()) |sq| {
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
        }

        b.state.zobrist_key = z;
    }

    /// Makes a move on the board.
    /// This method does not checks the legality
    pub fn makeMove(
        b: *Board,
        move: ChessMove,
        comptime color: bool,
    ) void {
        // Store unmake info
        var state = b.state;
        state.next_move = move;
        b.history.append(state) catch {
            @panic("Tried to append to history but failed");
        };

        // Shorthands
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
        b.occupied = b.colors[0] | b.colors[1];

        // Add move number and check if the move is legal
        if (color) {
            b.state.move_number += 1;
        }
    }

    /// Unmake a move.
    /// The color is the side after the undo
    pub fn unmakeMove(b: *Board, comptime color: bool) void {
        b.state = b.history.pop();

        // Shorthands
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

        b.occupied = b.colors[0] | b.colors[1];
    }

    pub fn swapSide(b: *Board) void {
        b.state.zobrist_key ^= b.zobrist_values.color;
        b.state.current_side = !b.state.current_side;
    }

    pub fn removeEnPassant(b: *Board) void {
        b.state.zobrist_key ^= b.zobrist_values.en_passant[b.state.en_passant.?.x];
        b.state.en_passant = null;
    }

    pub fn setEnPassant(b: *Board, sq: usize) void {
        b.state.en_passant = Square.new(sq);
        b.state.zobrist_key ^= b.zobrist_values.en_passant[sq];
    }

    pub fn removePiece(b: *Board, comptime color: bool, piece: usize, sq: usize) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] ^= tmp;
        b.colors[@intFromBool(color)] ^= tmp;
        b.pieces[sq] = constants.pieces.NONE;
        b.state.zobrist_key ^= b.zobrist_values.pieces[@intFromBool(color)][piece][sq];
    }

    pub fn addPiece(b: *Board, comptime color: bool, piece: usize, sq: usize) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] |= tmp;
        b.colors[@intFromBool(color)] |= tmp;
        b.pieces[sq] = piece;
        b.state.zobrist_key ^= b.zobrist_values.pieces[@intFromBool(color)][piece][sq];
    }

    pub fn movePiece(b: *Board, comptime color: bool, piece: usize, from: usize, to: usize) void {
        const bf = bb.SQUARES[from];
        const bt = bb.SQUARES[to];
        const board = &b.boards[@intFromBool(color)][piece];
        const colorb = &b.colors[@intFromBool(color)];
        board.* = (board.* ^ bf) | bt;
        colorb.* = (colorb.* ^ bf) | bt;
        b.pieces[from] = constants.pieces.NONE;
        b.pieces[to] = piece;
        const z = &b.zobrist_values.pieces[@intFromBool(color)][piece];
        b.state.zobrist_key ^= z[from] | z[to];
    }

    // Popping the move from the history automatically restores a lot of value
    // so we need some different methods for undoing adding and removing pieces
    // so to not interfere with already restored values

    pub fn undoAddPiece(b: *Board, comptime color: bool, piece: usize, sq: usize) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] ^= tmp;
        b.colors[@intFromBool(color)] ^= tmp;
        b.pieces[sq] = constants.pieces.NONE;
    }

    pub fn undoRemovePiece(b: *Board, comptime color: bool, piece: usize, sq: usize) void {
        const tmp = bb.SQUARES[sq];
        b.boards[@intFromBool(color)][piece] |= tmp;
        b.colors[@intFromBool(color)] |= tmp;
        b.pieces[sq] = piece;
    }

    pub fn undoMovePiece(b: *Board, comptime color: bool, piece: usize, from: usize, to: usize) void {
        const tmpFrom = bb.SQUARES[from];
        const tmpTo = bb.SQUARES[to];
        const tmp = &b.boards[@intFromBool(color)][piece];
        const tmpc = &b.colors[@intFromBool(color)];
        tmp.* = (tmp.* ^ tmpTo) | tmpFrom;
        tmpc.* = (tmpc.* ^ tmpTo) | tmpFrom;
        b.pieces[to] = constants.pieces.NONE;
        b.pieces[from] = piece;
    }

    pub fn updateCastlingRights(b: *Board, new: u4) void {
        b.state.zobrist_key ^= b.zobrist_values.castling[b.state.castling.x];
        b.state.castling = CastlingRights{ .x = new };
        b.state.zobrist_key ^= b.zobrist_values.castling[new];
    }

    pub fn kingSquare(b: *const Board, comptime color: bool) Square {
        return Square.new(@ctz(b.boards[@intFromBool(color)][0]));
    }

    pub fn queens(b: *const Board, comptime color: bool) u64 {
        return b.boards[@intFromBool(color)][1];
    }

    pub fn rooks(b: *const Board, comptime color: bool) u64 {
        return b.boards[@intFromBool(color)][2];
    }

    pub fn bishops(b: *const Board, comptime color: bool) u64 {
        return b.boards[@intFromBool(color)][3];
    }

    pub fn knights(b: *const Board, comptime color: bool) u64 {
        return b.boards[@intFromBool(color)][4];
    }

    pub fn pawns(b: *const Board, comptime color: bool) u64 {
        return b.boards[@intFromBool(color)][5];
    }

    pub fn friends(b: *const Board, comptime color: bool) u64 {
        return b.colors[@intFromBool(color)];
    }

    pub fn generatePseudolegalMoves(
        b: *const Board,
        comptime movetype: MoveType,
        comptime color: bool,
        movelist: *Movelist,
    ) void {
        // const us = @intFromBool(color);
        // const op = @intFromBool(!color);

        const friend = b.friends(color);
        const enemy = b.friends(!color);
        const occupied = b.occupied;

        const mask = switch (movetype) {
            .All => ~friend,
            .Quiet => ~occupied,
            .Capture => enemy,
        };

        // Generate Queen moves
        var biter = bb.BitboardIterator.new(b.queens(color));
        while (biter.next()) |sq| {
            addToMovelist(
                color,
                pieces.QUEEN,
                movelist,
                b,
                sq,
                tables.queenAttacks(sq, occupied) & mask,
            );
        }

        // Genereate Rook moves
        biter = bb.BitboardIterator.new(b.rooks(color));
        while (biter.next()) |sq| {
            addToMovelist(
                color,
                pieces.ROOK,
                movelist,
                b,
                sq,
                tables.rookAttacks(sq, occupied) & mask,
            );
        }

        // Genereate Bishop moves
        biter = bb.BitboardIterator.new(b.bishops(color));
        while (biter.next()) |sq| {
            addToMovelist(
                color,
                pieces.BISHOP,
                movelist,
                b,
                sq,
                tables.bishopAttacks(sq, occupied) & mask,
            );
        }

        // Generate Knight moves
        biter = bb.BitboardIterator.new(b.knights(color));
        while (biter.next()) |sq| {
            addToMovelist(
                color,
                pieces.KNIGHT,
                movelist,
                b,
                sq,
                tables.knightAttacks(sq) & mask,
            );
        }

        // Generate pawn moves
        const fourth_rank = if (color) bb.RANK_4 else bb.RANK_5;
        const direction: i8 = if (color) -8 else 8;
        const rot_count = @as(u8, @bitCast(64 + direction));
        biter = bb.BitboardIterator.new(b.pawns(color));
        while (biter.next()) |sq| {
            // TODO rivedere
            const to: usize = @truncate(@as(u128, @bitCast(@as(i128, sq) + direction)));
            var targets: u64 = 0;

            // Pushes
            if (movetype == MoveType.All or movetype == MoveType.Quiet) {
                const empty = ~occupied;
                targets = bb.SQUARES[to] & empty;
                targets |= std.math.rotl(u64, targets, rot_count) & empty & fourth_rank;
            }
            // Captures
            if (movetype == MoveType.All or movetype == MoveType.Capture) {
                const attacks = tables.pawnAttacks(color, sq);
                if (b.state.en_passant) |en| {
                    targets |= (attacks & (enemy | bb.SQUARES[en.x]));
                } else {
                    targets |= (attacks & enemy);
                }
            }

            addToMovelist(color, pieces.PAWN, movelist, b, sq, targets);
        }

        // Generate King moves
        const ksq = b.kingSquare(color).x;
        var targets = tables.kingAttacks(ksq) & mask;
        if (movetype != MoveType.Capture and !b.squareAttacked(color, ksq)) {
            if (color) {
                if (b.state.castling.x & CastlingRights.WK.x > CastlingRights.ZERO.x //
                and (bb.SQUARES[Square.F1.x] | bb.SQUARES[Square.G1.x]) & occupied == 0 //
                and !b.squareAttacked(color, Square.F1.x) //
                and !b.squareAttacked(color, Square.G1.x) //
                ) {
                    // todo: This is a single move, we can cache it
                    targets |= bb.SQUARES[Square.G1.x];
                }
                if (b.state.castling.x & CastlingRights.WQ.x > CastlingRights.ZERO.x //
                and (bb.SQUARES[Square.B1.x] | bb.SQUARES[Square.C1.x] | bb.SQUARES[Square.D1.x]) & occupied == 0 //
                and !b.squareAttacked(color, Square.C1.x) //
                and !b.squareAttacked(color, Square.D1.x) //
                ) {
                    targets |= bb.SQUARES[Square.C1.x];
                }
            } else {
                if (b.state.castling.x & CastlingRights.BK.x > CastlingRights.ZERO.x //
                and (bb.SQUARES[Square.F8.x] | bb.SQUARES[Square.G8.x]) & occupied == 0 //
                and !b.squareAttacked(color, Square.F8.x) //
                and !b.squareAttacked(color, Square.G8.x) //
                ) {
                    // todo: This is a single move, we can cache it
                    targets |= bb.SQUARES[Square.G8.x];
                }
                if (b.state.castling.x & CastlingRights.BQ.x > CastlingRights.ZERO.x //
                and (bb.SQUARES[Square.B8.x] | bb.SQUARES[Square.C8.x] | bb.SQUARES[Square.D8.x]) & occupied == 0 //
                and !b.squareAttacked(color, Square.C8.x) //
                and !b.squareAttacked(color, Square.D8.x) //
                ) {
                    targets |= bb.SQUARES[Square.C8.x];
                }
            }
        }
        addToMovelist(color, pieces.KING, movelist, b, ksq, targets);
    }

    pub fn squareAttacked(b: *const Board, comptime color: bool, sq: usize) bool {
        const attacker = @intFromBool(!color);
        return (b.boards[attacker][pieces.KING] & tables.kingAttacks(sq) != 0 //
        or b.boards[attacker][pieces.QUEEN] & tables.queenAttacks(sq, b.occupied) != 0 //
        or b.boards[attacker][pieces.ROOK] & tables.rookAttacks(sq, b.occupied) != 0 //
        or b.boards[attacker][pieces.BISHOP] & tables.bishopAttacks(sq, b.occupied) != 0 //
        or b.boards[attacker][pieces.KNIGHT] & tables.knightAttacks(sq) != 0 //
        or b.boards[attacker][pieces.PAWN] & tables.pawnAttacks(color, sq) != 0 //
        );
    }

    pub fn isKingAttacked(b: *const Board, comptime color: bool) bool {
        const occupied = b.occupied;
        const attacker = @intFromBool(!color);
        const sq = @ctz(b.boards[@intFromBool(color)][pieces.KING]);

        return (b.boards[attacker][pieces.QUEEN] & tables.queenAttacks(sq, occupied) != 0 or
            b.boards[attacker][pieces.ROOK] & tables.rookAttacks(sq, occupied) != 0 or
            b.boards[attacker][pieces.BISHOP] & tables.bishopAttacks(sq, occupied) != 0 or
            b.boards[attacker][pieces.KNIGHT] & tables.knightAttacks(sq) != 0 or
            b.boards[attacker][pieces.PAWN] & tables.pawnAttacks(color, sq) != 0 or
            b.boards[attacker][pieces.KING] & tables.kingAttacks(sq) != 0);
    }
};

fn addToMovelist(
    comptime color: bool,
    comptime piece: usize,
    movelist: *Movelist,
    board: *const Board,
    from: usize,
    to: u64,
) void {
    var biter = bb.BitboardIterator{ .u = to };
    while (biter.next()) |sq| {
        const capture = board.pieces[sq];

        var move_data = piece | (from << ChessMove.shift.FROM) | (sq << ChessMove.shift.TO) | (capture << ChessMove.shift.CAPTURE);

        // Pawn stuff
        var promotion: bool = false;
        if (piece == pieces.PAWN) {
            promotion = switch (color) {
                true => bb.SQUARES[sq] & bb.RANK_8 != bb.EMPTY,
                false => bb.SQUARES[sq] & bb.RANK_1 != bb.EMPTY,
            };

            var en_passant = false;
            if (board.state.en_passant) |en| {
                en_passant = (en.x == sq);
            }

            const double_push = @abs(@as(i128, sq) - from) == 16;

            move_data |= (@as(u64, @intFromBool(en_passant)) << ChessMove.shift.ENPASSANT) | (@as(u64, @intFromBool(double_push)) << ChessMove.shift.DOUBLE_STEP);
        }

        // King stuff
        if (piece == pieces.KING) {
            const castling = @abs(@as(i128, sq) - from) == 2;
            move_data |= @as(usize, @intFromBool(castling)) << ChessMove.shift.CASTLING;
        }

        if (!promotion) {
            move_data |= pieces.NONE << ChessMove.shift.PROMOTION;
            movelist.add(ChessMove{ .x = move_data });
        } else {
            for (pieces.PROMOTION_PIECES) |p| {
                movelist.add(ChessMove{ .x = move_data | (p << ChessMove.shift.PROMOTION) });
            }
        }
    }
}

test "parse moves" {
    tables.initAll();

    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var board = try Board.fromFen(alloc, constants.Fen.STARTPOS);
    defer board.deinit();

    const moves = "f2f4 d7d5 g1f3 g8f6 b2b3 d5d4 c1b2 c7c5 e2e3 d8a5 e3d4 c5d4 f3d4 e7e5 f1b5 f6d7 d1e2 e8d8 f4e5 a7a6 b5d7 c8d7 h1f1 f7f6 e5f6 g7f6 b1c3 f8g7 e1c1 f6f5 d4e6 d7e6 e2e6 a5e5 e6f7 e5e7 f7e7 d8e7 c3d5 e7f7 f1f5 f7g6 b2g7 g6g7 d5c7 g7g6 d1f1 a8a7 c7e6 g6h6 f5g5 h8g8 g5g8 b8d7 f1f3 d7f6 f3f6 h6h5 e6f4 h5h4 c1b1 a6a5 b1a1 a5a4 a1b1 a4b3 b1c1 b3b2 c1b1 a7a2 b1a2 b2b1b a2a1";
    var it = std.mem.splitScalar(u8, moves, ' ');
    while (it.next()) |str| {
        const move = try board.parseMove(str);
        if (board.state.current_side) {
            board.makeMove(move, true);
        } else {
            board.makeMove(move, false);
        }
    }
}
