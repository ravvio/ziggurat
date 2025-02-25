const std = @import("std");
const chess = @import("chess.zig");
const uci = @import("uci.zig");
const engine = @import("engine.zig");

const perft = @import("perft.zig");

const CommandError = error{
    MissingArgumentError,
    InvalidArgument,
};

pub fn run_perft(args: *std.process.ArgIterator) !void {
    var fen = args.next();
    if (fen == null) {
        return CommandError.MissingArgumentError;
    }
    if (std.mem.eql(u8, fen.?, "startpos")) {
        fen = chess.constants.Fen.STARTPOS;
    }

    const depth_str = args.next();
    if (depth_str == null) {
        return CommandError.MissingArgumentError;
    }
    const depth = std.fmt.parseInt(i8, depth_str.?, 10) catch {
        return CommandError.InvalidArgument;
    };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var board = try chess.Board.fromFen(allocator, fen.?);
    defer board.deinit();
    const color = board.state.current_side;

    if (color) {
        _ = perft.perftDivide(&board, true, depth);
    } else {
        _ = perft.perftDivide(&board, false, depth);
    }
}

pub fn run_eval(args: *std.process.ArgIterator) !void {
    var fen = args.next();
    if (fen == null) {
        return CommandError.MissingArgumentError;
    }
    if (std.mem.eql(u8, fen.?, "startpos")) {
        fen = chess.constants.Fen.STARTPOS;
    }

    const depth_str = args.next();
    if (depth_str == null) {
        return CommandError.MissingArgumentError;
    }
    const depth = std.fmt.parseInt(i8, depth_str.?, 10) catch {
        return CommandError.InvalidArgument;
    };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var board = try chess.Board.fromFen(allocator, fen.?);
    defer board.deinit();
    const color = board.state.current_side;

    var e = engine.Engine.init(allocator);
    defer e.deinit();

    if (color) {
        e.search(&board, true, depth);
    } else {
        e.search(&board, false, depth);
    }

    std.debug.print("Best: {}\n", .{e.best_move});
    std.debug.print("Eval: {}\n", .{e.eval});
}

pub fn main() !void {
    chess.tables.initAll();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    _ = args.next();
    const subcommand = args.next();

    if (subcommand == null) {
        // TODO
    }

    if (std.mem.eql(u8, subcommand.?, "perft")) {
        try run_perft(&args);
    } else if (std.mem.eql(u8, subcommand.?, "eval")) {
        try run_eval(&args);
    }
}
