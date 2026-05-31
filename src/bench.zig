const zbench = @import("zbench");
const std = @import("std");
const chess = @import("chess.zig");
const engine = @import("engine.zig");
const ziggurat = @import("root.zig");

const perft = @import("./benches/perft.zig");
const eval = @import("./benches/eval.zig");

pub fn main(init: std.process.Init) !void {
    const stdout: std.Io.File = .stdout();
    const io = init.io;
    const allocator = init.gpa;

    ziggurat.initAll();
    try engine.transposition.initGlobalTranspositionTable(allocator, 64);
    try engine.pawn_hashtable.initGlobalPawnTable(allocator, 4);
    defer engine.transposition.global_tt.deinit(allocator);
    defer engine.pawn_hashtable.global_pt.deinit(allocator);

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{
        .time_budget_ns = 5e9,
    });
    defer bench.deinit();

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
        "Eval6 startpos",
        &eval.EvalBench.init(io, chess.constants.Fen.STARTPOS, 6),
        .{},
    );
    try bench.addParam(
        "Eval8 startpos",
        &eval.EvalBench.init(io, chess.constants.Fen.STARTPOS, 8),
        .{},
    );
    try bench.addParam(
        "Eval10 startpos",
        &eval.EvalBench.init(io, chess.constants.Fen.STARTPOS, 10),
        .{},
    );
    try bench.addParam(
        "Eval12 startpos",
        &eval.EvalBench.init(io, chess.constants.Fen.STARTPOS, 12),
        .{},
    );
    try bench.addParam(
        "Eval6 kiwipete",
        &eval.EvalBench.init(io, chess.constants.Fen.KIWIPETE, 6),
        .{},
    );
    try bench.addParam(
        "Eval8 kiwipete",
        &eval.EvalBench.init(io, chess.constants.Fen.KIWIPETE, 8),
        .{},
    );
    try bench.addParam(
        "Eval10 kiwipete",
        &eval.EvalBench.init(io, chess.constants.Fen.KIWIPETE, 10),
        .{},
    );
    try bench.addParam(
        "Eval12 kiwipete",
        &eval.EvalBench.init(io, chess.constants.Fen.KIWIPETE, 12),
        .{},
    );

    try bench.run(io, stdout);
}
