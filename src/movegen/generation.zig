const std = @import("std");
const assert = std.debug.assert;

const chess = @import("../chess.zig");
const pieces = chess.constants.pieces;
const bitboard = chess.bitboard;
const Movelist = chess.Movelist;
const Square = chess.Square;
const chessmove = chess.chessmove;
const ChessMove = chess.ChessMove;
const Board = chess.Board;
const MoveGenTables = @import("tables.zig").MoveGenTables;

pub const MoveType = enum {
    All,
    Quiet,
    Capture,
};

pub fn genMovesPseudolegal(
    mg: *const MoveGenTables,
    white: bool,
    comptime movetype: MoveType,
    board: *const Board,
    movelist: *Movelist(ChessMove),
) void {
    const ksq = board.kingSquare(white).x;
    const enemies = board.friends(!white);
    const not_friends = ~board.friends(white);
    const occupied = board.occupied;

    generateKing(mg, board, movelist, white, movetype, ksq, occupied, enemies, not_friends);
    generateQueen(mg, board, movelist, white, movetype, occupied, enemies, not_friends);
    generateRook(mg, board, movelist, white, movetype, occupied, enemies, not_friends);
    generateBishop(mg, board, movelist, white, movetype, occupied, enemies, not_friends);
    generateKnight(mg, board, movelist, white, movetype, occupied, enemies, not_friends);
    generatePawns(mg, board, movelist, white, movetype, occupied, enemies);

    if (movetype == MoveType.All or movetype == MoveType.Quiet) {
        generateCastling(mg, board, movelist, white, ksq, occupied);
    }
}

fn addToMovelist(
    white: bool,
    comptime piece: usize,
    movelist: *Movelist(ChessMove),
    board: *const Board,
    from: usize,
    to: u64,
) void {
    var biter = chess.bitboard.BitboardIterator{ .u = to };
    while (biter.next()) |sq| {
        const capture = board.pieces[sq];

        var move_data = piece | (from << chessmove.shift.FROM) | (sq << chessmove.shift.TO) | (capture << chessmove.shift.CAPTURE);

        // Pawn stuff
        var promotion: bool = false;
        if (piece == pieces.PAWN) {
            promotion = switch (white) {
                true => bitboard.SQUARES[sq] & bitboard.RANK_8 != bitboard.EMPTY,
                false => bitboard.SQUARES[sq] & bitboard.RANK_1 != bitboard.EMPTY,
            };

            var en_passant = false;
            if (board.state.en_passant) |en| {
                en_passant = (en.x == sq);
            }

            const double_push = @abs(@as(i128, sq) - from) == 16;

            move_data |= (@as(u64, @intFromBool(en_passant)) << chessmove.shift.ENPASSANT) | (@as(u64, @intFromBool(double_push)) << chessmove.shift.DOUBLE_STEP);
        }

        // King stuff
        if (piece == pieces.KING) {
            const castling = @abs(@as(i128, sq) - from) == 2;
            move_data |= @as(usize, @intFromBool(castling)) << chessmove.shift.CASTLING;
        }

        if (!promotion) {
            move_data |= pieces.NONE << chessmove.shift.PROMOTION;
            movelist.add(ChessMove{ .x = move_data });
        } else {
            for (pieces.PROMOTION_PIECES) |p| {
                movelist.add(ChessMove{ .x = move_data | (p << chessmove.shift.PROMOTION) });
            }
        }
    }
}

fn movesFromType(comptime movetype: MoveType, targets: u64, not_friends: u64, occupied: u64, enemies: u64) u64 {
    return switch (movetype) {
        .All => targets & not_friends,
        .Quiet => targets & occupied,
        .Capture => targets & enemies,
    };
}

fn generateCastling(mg: *const MoveGenTables, board: *const Board, movelist: *Movelist(ChessMove), white: bool, ksq: usize, occupied: u64) void {
    // This we can probably chanche
    // if we are in check we are generating way too many moves
    if (squareAttacked(mg, board, white, ksq, occupied)) {
        return;
    }
    if (white) {
        if (board.state.castling.x & chess.CastlingRights.WK.x > chess.CastlingRights.ZERO.x //
        and (bitboard.SQUARES[Square.F1.x] | bitboard.SQUARES[Square.G1.x]) & occupied == 0 //
        and !squareAttacked(mg, board, white, Square.F1.x, occupied) //
        and !squareAttacked(mg, board, white, Square.G1.x, occupied) //
        ) {
            // todo: This is a single move, we can cache it
            addToMovelist(white, pieces.KING, movelist, board, ksq, bitboard.SQUARES[Square.G1.x]);
        }
        if (board.state.castling.x & chess.CastlingRights.WQ.x > chess.CastlingRights.ZERO.x //
        and (bitboard.SQUARES[Square.B1.x] | bitboard.SQUARES[Square.C1.x] | bitboard.SQUARES[Square.D1.x]) & occupied == 0 //
        and !squareAttacked(mg, board, white, Square.C1.x, occupied) //
        and !squareAttacked(mg, board, white, Square.D1.x, occupied) //
        ) {
            addToMovelist(white, pieces.KING, movelist, board, ksq, bitboard.SQUARES[Square.C1.x]);
        }
    } else {
        if (board.state.castling.x & chess.CastlingRights.BK.x > chess.CastlingRights.ZERO.x //
        and (bitboard.SQUARES[Square.F8.x] | bitboard.SQUARES[Square.G8.x]) & occupied == 0 //
        and !squareAttacked(mg, board, white, Square.F8.x, occupied) //
        and !squareAttacked(mg, board, white, Square.G8.x, occupied) //
        ) {
            // todo: This is a single move, we can cache it
            addToMovelist(white, pieces.KING, movelist, board, ksq, bitboard.SQUARES[Square.G8.x]);
        }
        if (board.state.castling.x & chess.CastlingRights.BQ.x > chess.CastlingRights.ZERO.x //
        and (bitboard.SQUARES[Square.B8.x] | bitboard.SQUARES[Square.C8.x] | bitboard.SQUARES[Square.D8.x]) & occupied == 0 //
        and !squareAttacked(mg, board, white, Square.C8.x, occupied) //
        and !squareAttacked(mg, board, white, Square.D8.x, occupied) //
        ) {
            addToMovelist(white, pieces.KING, movelist, board, ksq, bitboard.SQUARES[Square.C8.x]);
        }
    }
}

fn generateKing(
    mg: *const MoveGenTables,
    board: *const Board,
    movelist: *Movelist(ChessMove),
    white: bool,
    comptime movetype: MoveType,
    ksq: usize,
    occupied: u64,
    enemies: u64,
    not_friends: u64,
) void {
    const targets = mg.kingAttacks(ksq);
    const m = movesFromType(
        movetype,
        targets,
        not_friends,
        occupied,
        enemies,
    );
    addToMovelist(white, pieces.KING, movelist, board, ksq, m);
}

fn generateQueen(
    mg: *const MoveGenTables,
    board: *const Board,
    movelist: *Movelist(ChessMove),
    white: bool,
    comptime movetype: MoveType,
    occupied: u64,
    enemies: u64,
    not_friends: u64,
) void {
    const queens = board.queens(white);

    var biter = chess.bitboard.BitboardIterator{ .u = queens };
    while (biter.next()) |sq| {
        const targets = mg.queenAttacks(sq, occupied);
        const m = movesFromType(
            movetype,
            targets,
            not_friends,
            occupied,
            enemies,
        );
        addToMovelist(white, pieces.QUEEN, movelist, board, sq, m);
    }
}

fn generateRook(
    mg: *const MoveGenTables,
    board: *const Board,
    movelist: *Movelist(ChessMove),
    white: bool,
    comptime movetype: MoveType,
    occupied: u64,
    enemies: u64,
    not_friends: u64,
) void {
    const rooks = board.rooks(white);

    var biter = chess.bitboard.BitboardIterator{ .u = rooks };
    while (biter.next()) |sq| {
        const targets = mg.rookAttacks(sq, occupied);
        const m = movesFromType(
            movetype,
            targets,
            not_friends,
            occupied,
            enemies,
        );
        addToMovelist(white, pieces.ROOK, movelist, board, sq, m);
    }
}

fn generateBishop(
    mg: *const MoveGenTables,
    board: *const Board,
    movelist: *Movelist(ChessMove),
    white: bool,
    comptime movetype: MoveType,
    occupied: u64,
    enemies: u64,
    not_friends: u64,
) void {
    const bishops = board.bishops(white);

    var biter = chess.bitboard.BitboardIterator{ .u = bishops };
    while (biter.next()) |sq| {
        const targets = mg.bishopAttacks(sq, occupied);
        const m = movesFromType(
            movetype,
            targets,
            not_friends,
            occupied,
            enemies,
        );
        addToMovelist(white, pieces.BISHOP, movelist, board, sq, m);
    }
}

pub fn generateKnight(
    mg: *const MoveGenTables,
    board: *const Board,
    movelist: *Movelist(ChessMove),
    white: bool,
    comptime movetype: MoveType,
    occupied: u64,
    enemies: u64,
    not_friends: u64,
) void {
    const knights = board.knights(white);

    var biter = chess.bitboard.BitboardIterator{ .u = knights };
    while (biter.next()) |sq| {
        const targets = mg.knightAttacks(sq);
        const m = movesFromType(
            movetype,
            targets,
            not_friends,
            occupied,
            enemies,
        );
        addToMovelist(white, pieces.KNIGHT, movelist, board, sq, m);
    }
}

pub fn generatePawns(
    mg: *const MoveGenTables,
    board: *const Board,
    movelist: *Movelist(ChessMove),
    white: bool,
    comptime movetype: MoveType,
    occupied: u64,
    enemies: u64,
) void {
    const pawns = board.pawns(white);

    const fourth_rank = if (white) bitboard.RANK_4 else bitboard.RANK_5;
    const direction: i8 = if (white) -8 else 8;
    const rot_count = @as(u8, @bitCast(64 + direction));

    var biter = chess.bitboard.BitboardIterator{ .u = pawns };
    while (biter.next()) |sq| {
        // TODO rivedere
        const to: usize = @truncate(@as(u128, @bitCast(@as(i128, sq) + direction)));
        var targets: u64 = 0;

        // Pushes
        if (movetype == MoveType.All or movetype == MoveType.Quiet) {
            const empty = ~occupied;
            targets = bitboard.SQUARES[to] & empty;
            targets |= std.math.rotl(u64, targets, rot_count) & empty & fourth_rank;
        }
        // Captures
        if (movetype == MoveType.All or movetype == MoveType.Capture) {
            const attacks = mg.pawnAttacks(white, sq);
            if (board.state.en_passant) |en| {
                targets |= (attacks & (enemies | bitboard.SQUARES[en.x]));
            } else {
                targets |= (attacks & enemies);
            }
        }

        addToMovelist(white, pieces.PAWN, movelist, board, sq, targets);
    }
}

pub fn squareAttacked(
    mg: *const MoveGenTables,
    board: *const Board,
    color: bool,
    sq: usize,
    occupied: u64,
) bool {
    const attacker = @intFromBool(!color);
    return (board.boards[attacker][pieces.KING] & mg.kingAttacks(sq) != 0 //
    or board.boards[attacker][pieces.QUEEN] & mg.queenAttacks(sq, occupied) != 0 //
    or board.boards[attacker][pieces.ROOK] & mg.rookAttacks(sq, occupied) != 0 //
    or board.boards[attacker][pieces.BISHOP] & mg.bishopAttacks(sq, occupied) != 0 //
    or board.boards[attacker][pieces.KNIGHT] & mg.knightAttacks(sq) != 0 //
    or board.boards[attacker][pieces.PAWN] & mg.pawnAttacks(color, sq) != 0 //
    );
}
