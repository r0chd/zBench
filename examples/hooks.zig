const std = @import("std");
const zbench = @import("zbench");

fn beforeAllHook() void {
    std.debug.print("Starting benchmarking...\n", .{});
}

fn afterAllHook() void {
    std.debug.print("Finished benchmarking.\n", .{});
}

fn myBenchmark(_: std.mem.Allocator) void {
    var result: usize = 0;
    for (0..1_000_000) |i| {
        std.mem.doNotOptimizeAway(i);
        result += i * i;
    }
}

pub fn main() !void {
    var threaded: std.Io.Threaded = .init_single_threaded;
    const io = threaded.io();

    var stdout: std.Io.File.Writer = std.Io.File.stdout().writerStreaming(io, &.{});
    const writer = &stdout.interface;

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("My Benchmark", myBenchmark, .{
        .iterations = 100,
        .hooks = .{
            .before_all = beforeAllHook,
            .after_all = afterAllHook,
        },
    });

    try writer.writeAll("\n");
    try bench.run(writer);
}
