# Progress-zig

Simple progress bar in zig.

## Interface

```zig
const Progress = @import("progress");

var stdout = std.io.getStdOut().writer();
var bar = Progress.init(stdout); // Initiate the bar using a writer
try bar.draw() // Draw the current status of the progress bar.
_ = try bar.next() // Increment the progress by 1.
                   // Returns the current progress or `null` if complete. 
                   // Re-renders the progress bar.
const step = 3;
_ = try bar.increment(step) // Increment the progress by `step`. 
                            // Returns the current progress or `null` if complete. 
                            // Re-renders the progress bar.
```

## Options

```zig
bar.width: u32 = 20,
bar.total: u32 = 100,
bar.left_end: ?u8 = '[',
bar.right_end: ?u8 = ']',
bar.progress: u32 = 0,
bar.filled: u8 = '=',
bar.head: u8 = '>',
bar.display_fraction: bool = false,
bar.display_percentage: bool = true,
```

## Example

```zig
const std = @import("std");
const time = std.time;
const Progress = @import("progress");

var stdout = std.io.getStdOut().writer();
var bar = Progress.init(stdout);
bar.total = 300;
bar.width = 50;
bar.display_fraction = true;
while (try bar.next()) |_| {
    time.sleep(time.ns_per_ms * 5);
}
```
