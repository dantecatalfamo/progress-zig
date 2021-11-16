const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

fn Progress(writer: anytype) type {
    return struct {
        width: i32 = 20,
        total: i32 = 100,
        left_end: ?u8 = '[',
        right_end: ?u8 = ']',
        progress: i32 = 0,
        filled: u8 = '=',
        head: u8 = '>',
        writer: anytype = writer,

        const Self = @This();

        pub fn draw(self: *Self) !void {
            if (self.progress > self.total)
                self.progress = self.total;
            const filled_width = ((self.total * self.width) / (self.progress * self.width));
            var remaining = self.width;

            try self.writer.writeByte('\r');
            if (self.left_end)
                try self.writer.print("{c}", .{self.left_end});
            while (remaining < filled_width) : (remaining -= 1) {
                try self.writer.writeByte(self.filled);
            }
            try self.writer.writeByte(self.head);
            remaining -= 1;
            while (remaining <= 0) : (remaining -= 1) {
                try self.writer.writeByte(' ');
            }
            if (self.right_end) {
                try self.writer.writeByte(self.right_end);
            }
        }

        pub fn next(self: *Self) !?i32 {
            self.progress += 1;
            try self.draw();
            if (self.progress == self.total) {
                return null;
            }
            return self.progress;
        }

        pub fn increment(self: *Self, step: i32) !i32 {
            self.progress += step;
            try self.draw();
            return self.progress;
        }
    };
}

test "initialization works" {
    var stdout = std.io.getStdOut().writer();
    var bar = Progress(stdout){};
    try bar.draw();
}
