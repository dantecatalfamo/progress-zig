//! A basic progress bar in zig

const std = @import("std");
const time = std.time;
const testing = std.testing;

const Progress = @This();

fn Typed(comptime Writer: type) type {
    return struct {
        width: u32 = 20,
        total: u32 = 100,
        left_end: ?u8 = '[',
        right_end: ?u8 = ']',
        progress: u32 = 0,
        filled: u8 = '=',
        head: u8 = '>',
        display_fraction: bool = false,
        display_percentage: bool = true,
        writer: Writer,

        const Self = @This();

        pub fn init(writer: Writer) Self {
            return .{ .writer = writer };
        }

        pub fn draw(self: *Self) !void {
            if (self.progress > self.total)
                self.progress = self.total;
            const percent = @intToFloat(f32, self.progress) / @intToFloat(f32, self.total);
            const filled_width = @floatToInt(u32, percent * @intToFloat(f32, self.width));
            var remaining = self.width;

            try self.writer.writeByte('\r');
            if (self.left_end) |char|
                try self.writer.writeByte(char);

            while (remaining > self.width - filled_width) : (remaining -= 1) {
                try self.writer.writeByte(self.filled);
            }

            if (remaining > 0) {
                try self.writer.writeByte(self.head);
                remaining -= 1;
            }

            while (remaining > 0) : (remaining -= 1) {
                try self.writer.writeByte(' ');
            }
            if (self.right_end) |char| {
                try self.writer.writeByte(char);
            }

            if (self.display_fraction) {
                try self.writer.print(" {d}/{d}", .{ self.progress, self.total });
            }

            if (self.display_percentage) {
                if (percent == 0.0) {
                    try self.writer.print(" 0%", .{});
                } else {
                    try self.writer.print(" {d:.0}%", .{percent * 100});
                }
            }
        }

        /// Increase the progress by 1.
        /// Return the current progress, or `null` if complete.
        /// Re-renders the progress bar.
        pub fn next(self: *Self) !?u32 {
            self.progress += 1;
            try self.draw();
            if (self.progress == self.total) {
                return null;
            }
            return self.progress;
        }

        /// Increment the progress by `step`.
        /// Returns the current progress, or `null` if complete.
        /// Re-renders the progress bar.
        pub fn increment(self: *Self, step: u32) !?u32 {
            self.progress += step;
            try self.draw();
            if (self.progress == self.total) {
                return null;
            }
            return self.progress;
        }
    };
}

/// Initialize a new progress bar with a writer, typically stdout or stderr.
pub fn init(writer: anytype) Typed(@TypeOf(writer)) {
    return Typed(@TypeOf(writer)).init(writer);
}

test "initialization" {
    var stdout = std.io.getStdOut().writer();
    var bar = Progress.init(stdout);
}

test "display bar" {
    var stdout = std.io.getStdOut().writer();
    var bar = Progress.init(stdout);
    bar.total = 300;
    bar.width = 50;
    bar.display_fraction = true;
    try stdout.writeByte('\n');
    try bar.draw();
    while (try bar.next()) |_| {
        time.sleep(time.ns_per_ms * 5);
    }
    try stdout.writeByte('\n');
}
