usingnamespace @import("c.zig");
usingnamespace @import("types.zig");

pub const BufferTarget = enum(c_uint) {
    Array = GL_ARRAY_BUFFER,
    // AtomicCounter = GL_ATOMIC_COUNTER_BUFFER,
    CopyRead = GL_COPY_READ_BUFFER,
    CopyWrite = GL_COPY_WRITE_BUFFER,
    // DispatchIndirect = GL_DISPATCH_INDIRECT_BUFFER,
    // DrawIndirect = GL_DRAW_INDIRECT_BUFFER,
    ElementArray = GL_ELEMENT_ARRAY_BUFFER,
    PixelPack = GL_PIXEL_PACK_BUFFER,
    PixelUnpack = GL_PIXEL_UNPACK_BUFFER,
    // Query = GL_QUERY_BUFFER,
    // ShaderStorage = GL_SHADER_STORAGE_BUFFER,
    Texture = GL_TEXTURE_BUFFER,
    TransformFeedback = GL_TRANSFORM_FEEDBACK_BUFFER,
    Uniform = GL_UNIFORM_BUFFER,
};

pub const BufferUsage = enum(c_uint) {
    StreamDraw = GL_STREAM_DRAW,
    StreamRead = GL_STREAM_READ,
    StreamCopy = GL_STREAM_COPY,
    StaticDraw = GL_STATIC_DRAW,
    StaticRead = GL_STATIC_READ,
    StaticCopy = GL_STATIC_COPY,
    DynamicDraw = GL_DYNAMIC_DRAW,
    DynamicRead = GL_DYNAMIC_READ,
    DynamicCopy = GL_DYNAMIC_COPY,
};

pub fn Buffer(comptime target : BufferTarget) type {

    return struct {
        handle : Handle,

        const Self = @This();

        pub fn init() Self {
            var handle : Handle = undefined;
            glGenBuffers(1, &handle);
            return Self{ .handle = handle };
        } 

        pub fn deinit(self : Self) void {
            glDeleteBuffers(1, &self.handle);
        }

        pub fn bind(self : Self) void {
            glBindBuffer(@enumToInt(target), self.handle);
        }

        pub fn unbind(self : Self) void {
            glBindBuffer(@enumToInt(target), 0);
        }

        fn data_size(comptime T : type) c_longlong {
            const info = @typeInfo(T);
            var ptr : *const c_void = undefined;
            var len : usize = undefined;
            comptime var Child : type = undefined;
            const Pointer = info.Pointer;
            switch (Pointer.size) {
                .One => switch (@typeInfo(Pointer.child)) {
                    .Array => |Array| {
                        len = Array.len;
                        Child = Array.child;
                    },
                    else => @compileError("only slices or array pointers are supported " ++ @typeName(T)),
                },
                .Slice => |Slice| {
                    len = val.len;
                    Child = Slice.child;
                },
                else => @compileError("only slices or array pointers are supported " ++ @typeName(T)),
            }
           return @intCast(c_longlong, len * @sizeOf(Child));
        }

        pub fn alloc(self : Self, size : usize, draw_type : BufferUsage) void {
            glBufferData(@enumToInt(target), size, NULL, @enumToInt(draw_type));
        }

        pub fn data(self : Self, data_ptr : anytype, draw_type : BufferUsage) void {
            const ptr = @ptrCast(* const c_void, data_ptr);
            const size = data_size(@TypeOf(data_ptr));
            glBufferData(@enumToInt(target), size, ptr, @enumToInt(draw_type));
        }

        pub fn subdata(self: Self, data_ptr : anytype, offset : usize) void {
            const ptr = @ptrCast(* const c_void, data_ptr);
            const size = data_size(@TypeOf(data_ptr));
            glBufferSubData(@enumToInt(target), offset, size, ptr);
        }

        pub fn update(self : Self, data_ptr : anytype) void {
            self.subdata(data_ptr, 0);
        }
    };
}

pub const VertexArray = struct {
    handle : Handle,

    const Self = @This();

    pub fn init() Self {
        var handle : Handle = undefined;
        glGenVertexArrays(1, &handle);
        return Self{ .handle = handle };
    }

    pub fn deinit(self : Self) void {
        glDeleteVertexArrays(1, &self.handle);
    }

    pub fn bind(self : Self) void {
        glBindVertexArray(self.handle);
    }

    pub fn unbind(self : Self) void {
        glBindVertexArray(0);
    }

    // pub fn attrib_pointer(self : Self, index : c_uint) void {
    //     // glVertexAttribPointer();
    // }

    pub fn element_count(comptime T : type) comptime_int {
        const info = @typeInfo(T);
        return switch (info) {
            .Float => {
                1;
            },
            .Int => {
                1;
            },
            .Struct => blk: {
                const count = T.component_count;
                if (count < 1 or count > 4) {
                    @compileError("element count for vector types must be 1, 2, 3, or 4 (not " ++ count ++ ")");
                }
                break :blk count;
            },
            else => @compileError("unsupported type " ++ @typeName(T)),
        };
    }

    pub fn element_type(comptime T : type) c_uint {
        const info = @typeInfo(T);
        return switch (info) {
            .Float => |float| switch (float.bits) {
                16 => GL_HALF_FLOAT,
                32 => GL_FLOAT,
                64 => GL_DOUBLE,
                else => @compileError("unsupported float type " ++ @typeName(T)),
            },
            .Int => |int| switch (int.signedness) {
                .signed => switch (int.bits) {
                    8 => GL_BYTE,
                    16 => GL_SHORT,
                    32 => GL_INT,
                    else => @compileError("unsupported signed int type " ++ @typeName(T)),
                },
                .unsigned => switch (int.bits) {
                    8 => GL_UNSIGNED_BYTE,
                    16 => GL_UNSIGNED_SHORT,
                    32 => GL_UNSIGNED_INT,
                    else => @compileError("unsupported unsigned int type " ++ @typeName(T)),
                },
            },
            .Struct => element_type(T.Component),   // vector types store their componenet types in their Component declaration
            else => @compileError("unsupported type " ++ @typeName(T)),
        };
    }

    pub fn attrib_pointers(self : Self, comptime T : type, start_attrib : comptime_int) void {
        const info = @typeInfo(T);
        switch (info) {
            .Struct => {
                if (info.Struct.layout == .Extern) {
                    const stride = @sizeOf(T);
                    // std.log.info("struct {s}: stride {d} bytes", .{@typeName(T), @sizeOf(T)});
                    const fields = info.Struct.fields;
                    inline for (fields) |field, i| {
                        const ftype = field.field_type;
                        const elem_count = element_count(ftype);
                        const elem_type = element_type(ftype);
                        const offset = @byteOffsetOf(T, field.name);
                        glVertexAttribPointer(start_attrib + i, elem_count, elem_type, 0, stride, @intToPtr(?*c_void, offset));
                        glEnableVertexAttribArray(start_attrib + i);
                        // std.log.info("glAttribPointer({d}, {d}, {d}, 0, {d}, @intToPtr(?*c_void, {d}));", .{start_attrib + i, elem_count, elem_type, stride, offset});
                    }
                }
                else {
                    @compileError("cannot read layout of non-extern struct " ++ @typeName(T));
                }
            },
            else => @compileError("cannot read layout of non-struct " ++ @typeName(T)),
        }
    }

};