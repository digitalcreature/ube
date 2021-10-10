// SPDX-License-Identifier: MIT
// Copyright (c) 2015-2020 Zig Contributors
// This file is part of [zig](https://ziglang.org/), which is MIT licensed.
// The MIT license requires this copyright notice to be included in all copies
// and substantial portions of the software.
const std = @import("../std.zig");
const Allocator = std.mem.Allocator;

/// This allocator is used in front of another allocator and logs to the provided stream
/// on every call to the allocator. Stream errors are ignored.
/// If https://github.com/ziglang/zig/issues/2586 is implemented, this API can be improved.
pub fn LoggingAllocator(comptime OutStreamType: type) type {
    return struct {
                     allocator: Allocator,
                     parent_allocator: *Allocator,
                     out_stream: OutStreamType,

                     const Self = @This();

                     pub fn init(parent_allocator: *Allocator, out_stream: OutStreamType) Self {
                                      return Self{
                                          .allocator = Allocator{
                                                           .allocFn = alloc,
                                                           .resizeFn = resize,
                                          },
                                          .parent_allocator = parent_allocator,
                                          .out_stream = out_stream,
                                      };
                     }

                     fn alloc(
                                      allocator: *Allocator,
                                      len: usize,
                                      ptr_align: u29,
                                      len_align: u29,
                                      ra: usize,
                     ) error{OutOfMemory}![]u8 {
                                      const self = @fieldParentPtr(Self, "allocator", allocator);
                                      self.out_stream.print("alloc : {}", .{len}) catch {};
                                      const result = self.parent_allocator.allocFn(self.parent_allocator, len, ptr_align, len_align, ra);
                                      if (result) |buff| {
                                          self.out_stream.print(" success!\n", .{}) catch {};
                                      } else |err| {
                                          self.out_stream.print(" failure!\n", .{}) catch {};
                                      }
                                      return result;
                     }

                     fn resize(
                                      allocator: *Allocator,
                                      buf: []u8,
                                      buf_align: u29,
                                      new_len: usize,
                                      len_align: u29,
                                      ra: usize,
                     ) error{OutOfMemory}!usize {
                                      const self = @fieldParentPtr(Self, "allocator", allocator);
                                      if (new_len == 0) {
                                          self.out_stream.print("free  : {}\n", .{buf.len}) catch {};
                                      } else if (new_len <= buf.len) {
                                          self.out_stream.print("shrink: {} to {}\n", .{ buf.len, new_len }) catch {};
                                      } else {
                                          self.out_stream.print("expand: {} to {}", .{ buf.len, new_len }) catch {};
                                      }
                                      if (self.parent_allocator.resizeFn(self.parent_allocator, buf, buf_align, new_len, len_align, ra)) |resized_len| {
                                          if (new_len > buf.len) {
                                                           self.out_stream.print(" success!\n", .{}) catch {};
                                          }
                                          return resized_len;
                                      } else |e| {
                                          std.debug.assert(new_len > buf.len);
                                          self.out_stream.print(" failure!\n", .{}) catch {};
                                          return e;
                                      }
                     }
    };
}

pub fn loggingAllocator(
    parent_allocator: *Allocator,
    out_stream: anytype,
) LoggingAllocator(@TypeOf(out_stream)) {
    return LoggingAllocator(@TypeOf(out_stream)).init(parent_allocator, out_stream);
}

test "LoggingAllocator" {
    var log_buf: [255]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&log_buf);

    var allocator_buf: [10]u8 = undefined;
    var fixedBufferAllocator = std.mem.validationWrap(std.heap.FixedBufferAllocator.init(&allocator_buf));
    const allocator = &loggingAllocator(&fixedBufferAllocator.allocator, fbs.outStream()).allocator;

    var a = try allocator.alloc(u8, 10);
    a = allocator.shrink(a, 5);
    std.testing.expect(a.len == 5);
    std.testing.expectError(error.OutOfMemory, allocator.resize(a, 20));
    allocator.free(a);

    std.testing.expectEqualSlices(u8,
                     \\alloc : 10 success!
                     \\shrink: 10 to 5
                     \\expand: 5 to 20 failure!
                     \\free  : 5
                     \\
    , fbs.getWritten());
}
