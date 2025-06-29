const std = @import("std");
const chess = @import("chess.zig");
const engine = @import("engine.zig");
const ziggurat = @import("root.zig");

const perft = @import("perft.zig");

const CommandError = error{
    MissingArgumentError,
    InvalidArgument,
};

pub fn run_perft(args: *std.process.ArgIterator) !void {
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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var board = try chess.Board.fromFen(allocator, fen.?);
    defer board.deinit();

    if (args.next()) |token| {
        if (std.mem.eql(u8, token, "moves")) {
            while (args.next()) |m| {
                const move = try board.parseMove(m);
                if (board.state.current_side) {
                    board.makeMove(move, true);
                } else {
                    board.makeMove(move, false);
                }
            }
        }
    }

    const color = board.state.current_side;

    if (color) {
        _ = perft.perftDivide(&board, true, depth);
    } else {
        _ = perft.perftDivide(&board, false, depth);
    }
}

pub fn run_eval(args: *std.process.ArgIterator) !void {
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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var board = try chess.Board.fromFen(allocator, fen.?);
    defer board.deinit();
    const color = board.state.current_side;

    if (args.next()) |token| {
        if (std.mem.eql(u8, token, "moves")) {
            while (args.next()) |m| {
                const move = try board.parseMove(m);
                if (board.state.current_side) {
                    board.makeMove(move, true);
                } else {
                    board.makeMove(move, false);
                }
            }
        }
    }

    var e = engine.Engine.init(allocator) catch {
        @panic("could not initialize engine");
    };
    defer e.deinit();

    if (color) {
        e.search(&board, true, depth);
    } else {
        e.search(&board, false, depth);
    }

    std.debug.print("Best: {}\n", .{e.best_move});
    std.debug.print("Eval: {}\n", .{e.score});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    ziggurat.initAll();
    try engine.transposition.initGlobalTranspositionTable(allocator, 64);
    defer engine.transposition.global_tt.deinit();

    var args = try std.process.argsWithAllocator(allocator);
    _ = args.next();
    const subcommand = args.next();

    if (subcommand == null) {
        var uci = try engine.Uci.init(allocator);
        try uci.run();
    } else if (std.mem.eql(u8, subcommand.?, "perft")) {
        try run_perft(&args);
    } else if (std.mem.eql(u8, subcommand.?, "eval")) {
        try run_eval(&args);
    }
}
