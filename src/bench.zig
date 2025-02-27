const zbench = @import("zbench");
const std = @import("std");
const chess = @import("chess.zig");
const testing = std.testing;
const engine = @import("engine.zig");

const perft = @import("./benches/perft.zig");
const eval = @import("./benches/eval.zig");

pub fn main() !void {
    chess.tables.initAll();

    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try engine.transposition.initGlobalTranspositionTable(allocator, 64);
    defer engine.transposition.global_tt.deinit();

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
    try bench.addParam(
        "Eval2 kiwipete",
        &eval.EvalBench.init(chess.constants.Fen.STARTPOS, 2),
        .{},
    );
    try bench.addParam(
        "Eval4 kiwipete",
        &eval.EvalBench.init(chess.constants.Fen.KIWIPETE, 4),
        .{},
    );

    try stdout.writeAll("\n");
    try bench.run(stdout);
}
