const std = @import("std");
const chess = @import("../chess.zig");
const Engine = @import("./engine.zig").Engine;
const perft = @import("../perft.zig");

/// Implementation of the Universal Chess Interface
/// More: https://www.chessprogramming.org/UCI
/// Specification: https://gist.github.com/DOBRO/2592c6dad754ba67e6dcaec8c90165bf
pub const Uci = struct {
    /// The arena allocator for the board and the engine
    board: chess.Board,
    engine: Engine,
    search_thread: ?std.Thread,

    pub fn init(allocator: std.mem.Allocator) !Uci {
        var engine = try Engine.init(allocator);
        engine.quiet = false;
        return .{
            .board = try chess.Board.fromFen(allocator, chess.constants.Fen.STARTPOS),
            .engine = engine,
            .search_thread = null,
        };
    }

    pub fn deinit(self: *Uci) void {
        self.engine.deinit();
        self.board.deinit();
    }

    /// Main loop inspired from Avalanche
    /// https://github.com/SnowballSH/Avalanche
    pub fn run(self: *Uci) !void {
        var stdin = std.io.getStdIn().reader();
        var stdout = std.io.getStdOut().writer();

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        while (true) {
            const in = try stdin.readUntilDelimiterOrEofAlloc(allocator, '\n', 16348);
            if (in == null) {
                break;
            }

            // Trim carriage return and split on space
            const line = std.mem.trim(u8, in.?, "\r");
            var tokens = std.mem.splitScalar(u8, line, ' ');

            // First token is the command
            const cmd = tokens.next();
            if (in == null) {
                break;
            }

            // Stop the search
            if (std.mem.eql(u8, cmd.?, "stop")) {
                self.engine.stop = true;
                continue;
            }
            // Ask if ready
            else if (std.mem.eql(u8, cmd.?, "isready")) {
                _ = try stdout.writeAll("readyok\n");
            }
            // Switch debug mode
            else if (std.mem.eql(u8, cmd.?, "debug")) {
                if (tokens.next()) |onoff| {
                    var debug: bool = undefined;
                    if (std.mem.eql(u8, onoff, "on")) {
                        debug = true;
                    } else if (std.mem.eql(u8, onoff, "off")) {
                        debug = false;
                    }
                    // TODO switch debug mode
                }
            }

            // If the engine is searching continue
            if (self.engine.searching) {
                continue;
            }

            // Quit the program
            if (std.mem.eql(u8, cmd.?, "quit")) {
                break;
            }
            // Ask for idetification
            else if (std.mem.eql(u8, cmd.?, "uci")) {
                _ = try stdout.writeAll(
                    \\id name ziggurat_0.4.0
                    \\id author Alessio Raviola
                    \\
                );
                // TODO add options
                _ = try stdout.writeAll("uciok\n");
            }
            // Set an engine option
            else if (std.mem.eql(u8, cmd.?, "setoption")) {
                // TODO set options
            }
            // Start a new game
            else if (std.mem.eql(u8, cmd.?, "ucinewgame")) {
                self.board.deinit();
                self.engine.deinit();
                // TODO Clear TT table
                try self.board.setFen(chess.constants.Fen.STARTPOS);
            }
            // Print a debug view of the current position
            else if (std.mem.eql(u8, cmd.?, "d")) {
                // TODO Debug print position
            }
            // Ask for the perft divide of the current position
            else if (std.mem.eql(u8, cmd.?, "perft")) {
                var depth: u8 = 1;
                if (tokens.next()) |dep| {
                    depth = @max(1, std.fmt.parseInt(u8, dep, 10) catch 1);
                }
                if (self.board.state.current_side) {
                    _ = perft.perftDivide(&self.board, true, depth);
                } else {
                    _ = perft.perftDivide(&self.board, false, depth);
                }
            }
            // Set fen position
            else if (std.mem.eql(u8, cmd.?, "position")) {
                if (tokens.next()) |subcmd| {
                    // Set fen
                    if (std.mem.eql(u8, subcmd, "startpos")) {
                        try self.board.setFen(chess.constants.Fen.STARTPOS);
                    } else if (std.mem.eql(u8, subcmd, "fen")) {
                        if (tokens.next()) |fen| {
                            try self.board.setFen(fen);
                        }
                    } else {
                        continue;
                    }

                    // TODO Clear any history and stuff some already done inside the board

                    // Apply moves if present
                    if (tokens.next()) |token| {
                        if (std.mem.eql(u8, token, "moves")) {
                            while (tokens.next()) |movestr| {
                                const move = try self.board.parseMove(movestr);
                                if (self.board.state.current_side) {
                                    self.board.makeMove(move, true);
                                } else {
                                    self.board.makeMove(move, false);
                                }
                                // TODO Also push the move to any other history
                            }
                        }
                    }
                }
            }
            // Run evaluation
            else if (std.mem.eql(u8, cmd.?, "go")) {
                // Parse other settings and set stuff like the time to tink for
                const movetime, const max_depth = self.handleGoInfo(&tokens);

                // Start the engine
                self.engine.stop = false;
                self.search_thread = try std.Thread.spawn(
                    .{ .stack_size = 64 * 1024 * 1024 },
                    startSearch,
                    .{ &self.engine, &self.board, movetime, max_depth },
                );
            }

            allocator.free(in.?);
        }
    }

    fn handleGoInfo(
        self: *Uci,
        tokens: *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar),
    ) struct { u64, ?u8 } {
        var movetime: ?u64 = null;
        var mytime: ?u64 = null;
        var myinc: u64 = 0;
        var movestogo: ?u64 = null;
        var max_depth: ?u8 = null;

        while (tokens.next()) |token| {
            // The engine has infinit time to search
            if (std.mem.eql(u8, token, "infinite")) {
                movetime = (1 << 63);
                self.engine.search_time = movetime.?;
                break;
            }
            // Set max depth the engine should reach
            if (std.mem.eql(u8, token, "depth")) {
                if (tokens.next()) |max| {
                    max_depth = std.fmt.parseUnsigned(u8, max, 10) catch null;
                    movetime = (1 << 63);
                    self.engine.search_time = movetime.?;
                }
                break;
            }
            // Set the time for the move
            if (std.mem.eql(u8, token, "movetime")) {
                if (tokens.next()) |time| {
                    movetime = std.fmt.parseUnsigned(u64, time, 10) catch 10 * std.time.ms_per_s;
                    self.engine.search_time = movetime.?;
                }
                break;
            }
            // TODO: nodes

            // Set time remaining for white
            if (std.mem.eql(u8, token, "wtime")) {
                if (tokens.next()) |time| {
                    if (self.board.state.current_side) {
                        mytime = std.fmt.parseUnsigned(u64, time, 10) catch 1;
                    }
                } else {
                    break;
                }
            }
            // Set time remaning for black
            else if (std.mem.eql(u8, token, "btime")) {
                if (tokens.next()) |time| {
                    if (!self.board.state.current_side) {
                        mytime = std.fmt.parseUnsigned(u64, time, 10) catch 1;
                    }
                } else {
                    break;
                }
            }
            // Set icrement for white
            else if (std.mem.eql(u8, token, "winc")) {
                if (tokens.next()) |time| {
                    if (self.board.state.current_side) {
                        myinc = std.fmt.parseUnsigned(u64, time, 10) catch 0;
                    }
                } else {
                    break;
                }
            }
            // Set increment for black
            else if (std.mem.eql(u8, token, "binc")) {
                if (tokens.next()) |time| {
                    if (!self.board.state.current_side) {
                        myinc = std.fmt.parseUnsigned(u64, time, 10) catch 0;
                    }
                } else {
                    break;
                }
            }
            // Set number of moves remaining
            else if (std.mem.eql(u8, token, "movestogo")) {
                if (tokens.next()) |n| {
                    movestogo = std.fmt.parseUnsigned(u64, n, 10) catch null;
                    if (movestogo == 0) {
                        movestogo = null;
                    }
                }
            }
        }

        const overhead: u64 = 25;
        if (movetime) |mvtime| {
            if (mvtime <= overhead) {
                self.engine.search_time = mvtime;
            } else {
                self.engine.search_time = mvtime - overhead;
            }
        } else {
            if (mytime) |time| {
                // Time remeaning is less than overhead, do your best
                if (time <= overhead) {
                    self.engine.search_time = overhead - 5;
                    movetime = overhead - 5;
                } else {
                    const t = time - overhead;
                    if (movestogo) |moves| {
                        self.engine.search_time = myinc + 2 * t / (2 * moves + 1);
                        movetime = @min(
                            2 * self.engine.search_time,
                            t - @min(t, overhead * @min(moves, 5)),
                        );
                    } else {
                        self.engine.search_time = myinc + t / 28;
                        movetime = 2 * myinc * t / 16;
                    }
                    self.engine.search_time = @min(self.engine.search_time, t);
                    movetime = @min(movetime.?, t);
                }
            } else {
                movetime = 100 * std.time.ms_per_s;
            }
        }

        return .{ movetime.?, max_depth };
    }
};

fn startSearch(
    engine: *Engine,
    b: *chess.Board,
    movetime: u64,
    max_depth: ?u8,
) void {
    //var ml = chess.Movelist.new();
    // TO TRY - check if we have only a possible move, in which case return now
    engine.max_time = movetime;

    if (b.state.current_side) {
        engine.search(b, true, max_depth);
    } else {
        engine.search(b, false, max_depth);
    }
}
