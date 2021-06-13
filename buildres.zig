const std = @import("std");
const fs = std.fs;

usingnamespace std.build;

const open_options = fs.Dir.OpenDirOptions{
    .iterate = true,
};

pub fn main() !void {
    try buildResources("res");
    // try createStep("res");
}

// const Pkg = std.build.Pkg;

pub fn buildResources(root: []const u8) !void {
    var dir = try fs.cwd().openDir(root, open_options);
    defer dir.close();
    try createZigFile(dir);
}

pub fn createEmbedResourcesStep(builder: *Builder, root: []const u8) !*WriteFileStep {
    var allocator = builder.allocator;
    var step = try allocator.create(WriteFileStep);
    errdefer allocator.destroy(step);
    step.* = WriteFileStep.init(builder);
    var dir = try fs.cwd().openDir(root, open_options);
    defer dir.close();
    try addFileToStep(allocator, root, dir, step);
    return step;
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
    var file = try dir.createFile(".zig", .{});
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

pub fn addFileToStep(allocator: *std.mem.Allocator, path: []const u8, dir: fs.Dir, step: *WriteFileStep) anyerror!void {
    // std.log.info("{s}", .{path});
    var iter = dir.iterate();
    var list = std.ArrayList(u8).init(allocator);
    var writer = list.writer();
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
            var child_path = try fs.path.join(allocator, &[_][]const u8{path, entry.name});
            defer allocator.free(child_path);
            try addFileToStep(allocator, child_path, child, step);
        }
    }
    var zig_path = try fs.path.join(allocator, &[_][]const u8{path, ".zig"});
    // std.log.info("{s}: [\n{s}\n]", .{zig_path, list.items});

    step.add(zig_path, list.items);
}