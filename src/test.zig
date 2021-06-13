const std = @import("std");

test "" {
    std.testing.log_level = .debug;
    std.log.info("", .{});
    inline for (Axis) |axis| {
        std.log.info("{s} = {d}", .{@tagName(axis), @enumToInt(axis)});
    }
}


