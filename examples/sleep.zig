const std = @import("std");
const zbench = @import("zbench");

fn sleepBenchmark(_: std.mem.Allocator) void {
    std.Thread.sleep(100_000_000);
}

pub fn main() !void {
    var threaded: std.Io.Threaded = .init_single_threaded;
    const io = threaded.io();

    var stdout: std.Io.File.Writer = std.Io.File.stdout().writerStreaming(io, &.{});
    const writer = &stdout.interface;

    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();
    try bench.add("Sleep Benchmark", sleepBenchmark, .{});

    try writer.writeAll("\n");
    try bench.run(writer);
}
