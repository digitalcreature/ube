const std = @import("std");
const fs = std.fs;


const open_options = fs.Dir.OpenDirOptions{
    .iterate = true,
};

pub fn main() !void {
    try buildResources("res");
}

// const Pkg = std.build.Pkg;

pub fn buildResources(root: []const u8) !void {
    var dir = try fs.cwd().openDir(root, open_options);
    defer dir.close();
    try createZigFile(dir);
}

fn readDir(dir: *fs.Dir) anyerror!void {
    try readDirIndent(dir, 0);
}

const indent_str = " " ** 128;

fn readDirIndent(dir: *fs.Dir, indent: u8) anyerror!void {
    std.log.info("{s}{s}/", .{indent_str[0..(indent * 3)], dir.name});
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .File) {
            std.log.info("{s}{s}", .{indent_str[0..(indent * 3)], entry.name});
        }
        if (entry.kind == .Directory) {
            var child = try dir.openDir(entry.name, open_options);
            defer child.close();
            try readDirIndent(&child, indent + 1);
        }
    }
}

pub fn createZigFile(dir: fs.Dir) anyerror!void {
    var iter = dir.iterate();
    var file = try dir.createFile(".zig", .{ .read = true });
    var writer = file.writer();
    defer file.close();
    while (try iter.next()) |entry| {
        if (entry.kind == .File) {
            if (!std.mem.eql(u8, entry.name, ".zig")) {
                try writer.print("pub const @\"{s}\" = @embedFile(\"{s}\");\n", .{ entry.name, entry.name });
            }
        }
        if (entry.kind == .Directory) {
            try writer.print("pub const @\"{s}\" = @import(\"{s}/.zig\");\n", .{ entry.name, entry.name });
            var child = try dir.openDir(entry.name, open_options);
            defer child.close();
            try createZigFile(child);
        }
    }
}