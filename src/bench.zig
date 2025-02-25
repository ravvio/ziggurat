const zbench = @import("zbench");
const std = @import("std");
const chess = @import("chess.zig");
const testing = std.testing;

const movelist = @import("./benches/movelist.zig");
const board = @import("./benches/board.zig");
const math = @import("./benches/math.zig");
const perft = @import("./benches/perft.zig");
const eval = @import("./benches/eval.zig");

pub fn main() !void {
    chess.tables.initAll();

    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.addParam("Movelist Swap", &movelist.SwapBench.init(20), .{
        .time_budget_ns = 1e9, // 1 second
    });

    try bench.addParam("Board From FEN 1", &board.ParseFenBench.init("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"), .{});
    try bench.addParam("Board From FEN 2", &board.ParseFenBench.init("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2"), .{});

    try bench.add("Subtract usize", math.benchSubtractUsize, .{});

    try bench.addParam(
        "Perft2 startpos",
        &perft.PerftBench.init(chess.constants.Fen.STARTPOS, 2),
        .{},
    );
    try bench.addParam(
        "Perft4 startpos",
        &perft.PerftBench.init(chess.constants.Fen.STARTPOS, 4),
        .{},
    );
    try bench.addParam(
        "Perft6 startpos",
        &perft.PerftBench.init(chess.constants.Fen.STARTPOS, 6),
        .{},
    );
    try bench.addParam(
        "Perft2 kiwipete",
        &perft.PerftBench.init(chess.constants.Fen.KIWIPETE, 2),
        .{},
    );
    try bench.addParam(
        "Perft4 kiwipete",
        &perft.PerftBench.init(chess.constants.Fen.KIWIPETE, 4),
        .{},
    );

    try bench.addParam(
        "Eval2 startpos",
        &eval.EvalBench.init(chess.constants.Fen.STARTPOS, 2),
        .{},
    );
    try bench.addParam(
        "Eval4 startpos",
        &eval.EvalBench.init(chess.constants.Fen.STARTPOS, 4),
        .{},
    );

    try stdout.writeAll("\n");
    try bench.run(stdout);
}
