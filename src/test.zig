const std = @import("std");
const time = std.time;
const progress = @import("main.zig");

pub fn main() !void {
    var stdout = std.io.getStdOut().writer();
    var bar = progress.Progress.init(stdout);
    try bar.draw();
    while (try bar.next()) |_| {
        time.sleep(time.ns_per_ms * 50);
    }
    try stdout.writeByte('\n');
}
