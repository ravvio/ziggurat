const std = @import("std");
const chess = @import("chess.zig");
const engine = @import("engine.zig");
const ziggurat = @import("root.zig");

const perft = @import("perft.zig");

const CommandError = error{
    MissingArgumentError,
    InvalidArgument,
};

pub fn run_perft(allocator: std.mem.Allocator, args: *std.process.Args.Iterator) !void {
    const depth_str = args.next();
    if (depth_str == null) {
        return CommandError.MissingArgumentError;
    }
    const depth = std.fmt.parseInt(u8, depth_str.?, 10) catch {
        return CommandError.InvalidArgument;
    };

    var fen = args.next();
    if (fen == null) {
        return CommandError.MissingArgumentError;
    }
    if (std.mem.eql(u8, fen.?, "startpos")) {
        fen = chess.constants.Fen.STARTPOS;
    }

    var board = try chess.Board.fromFen(allocator, fen.?);
    defer board.deinit(allocator);

    if (args.next()) |token| {
        if (std.mem.eql(u8, token, "moves")) {
            while (args.next()) |m| {
                const move = try board.parseMove(m);
                if (board.state.current_side) {
                    board.makeMove(allocator, move, true);
                } else {
                    board.makeMove(allocator, move, false);
                }
            }
        }
    }

    const color = board.state.current_side;

    if (color) {
        _ = perft.perftDivide(allocator, &board, true, depth);
    } else {
        _ = perft.perftDivide(allocator, &board, false, depth);
    }
}

pub fn run_eval(allocator: std.mem.Allocator, io: std.Io, args: *std.process.Args.Iterator) !void {
    const depth_str = args.next();
    if (depth_str == null) {
        return CommandError.MissingArgumentError;
    }
    const depth = std.fmt.parseInt(u8, depth_str.?, 10) catch {
        return CommandError.InvalidArgument;
    };

    var fen = args.next();
    if (fen == null) {
        return CommandError.MissingArgumentError;
    }
    if (std.mem.eql(u8, fen.?, "startpos")) {
        fen = chess.constants.Fen.STARTPOS;
    }

    var board = try chess.Board.fromFen(allocator, fen.?);
    defer board.deinit(allocator);
    const color = board.state.current_side;

    if (args.next()) |token| {
        if (std.mem.eql(u8, token, "moves")) {
            while (args.next()) |m| {
                const move = try board.parseMove(m);
                if (board.state.current_side) {
                    board.makeMove(allocator, move, true);
                } else {
                    board.makeMove(allocator, move, false);
                }
            }
        }
    }

    var e = engine.Engine.init(allocator) catch {
        @panic("could not initialize engine");
    };
    defer e.deinit(allocator);

    if (color) {
        e.search(allocator, io, &board, true, depth);
    } else {
        e.search(allocator, io, &board, false, depth);
    }
}

pub fn main(init: std.process.Init) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const io = init.io;

    ziggurat.initAll();
    try engine.transposition.initGlobalTranspositionTable(allocator, 64);
    try engine.pawn_hashtable.initGlobalPawnTable(allocator, 4);
    defer engine.transposition.global_tt.deinit(allocator);
    defer engine.pawn_hashtable.global_pt.deinit(allocator);

    var args = init.minimal.args.iterate();
    _ = args.next();
    const subcommand = args.next();

    if (subcommand == null) {
        var uci = try engine.Uci.init(allocator);
        defer uci.deinit(allocator);
        try uci.run(allocator, io);
    } else if (std.mem.eql(u8, subcommand.?, "perft")) {
        try run_perft(allocator, &args);
    } else if (std.mem.eql(u8, subcommand.?, "eval")) {
        try run_eval(allocator, io, &args);
    }
}
