usingnamespace @import("c.zig");
usingnamespace @import("types.zig");

const math = @import("math");

pub const BufferTarget = enum(c_uint) {
    Vertex = GL_ARRAY_BUFFER,
    // AtomicCounter = GL_ATOMIC_COUNTER_BUFFER,
    CopyRead = GL_COPY_READ_BUFFER,
    CopyWrite = GL_COPY_WRITE_BUFFER,
    // DispatchIndirect = GL_DISPATCH_INDIRECT_BUFFER,
    // DrawIndirect = GL_DRAW_INDIRECT_BUFFER,
    Index = GL_ELEMENT_ARRAY_BUFFER,
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

pub fn VertexBuffer(comptime Element : type) type {
    return Buffer(.Vertex, Element);
}
pub fn IndexBuffer(comptime Element : type) type {
    return Buffer(.Index, Element);
}

pub const IndexBuffer8 = IndexBuffer(u8);
pub const IndexBuffer16 = IndexBuffer(u16);
pub const IndexBuffer32 = IndexBuffer(u32);

pub fn Buffer(comptime target : BufferTarget, comptime T : type) type {

    return struct {
        handle : Handle,

        pub const Element = T;

        pub const Target = target;

        const Self = @This();

        pub fn init() Self {
            var handle : Handle = undefined;
            glCreateBuffers(1, &handle);
            return Self{ .handle = handle };
        } 

        pub fn initData(data_slice : [] const Element, usage : BufferUsage) Self {
            const buffer = init();
            buffer.data(data_slice, usage);
            return buffer;
        }

        pub fn initAlloc(size : usize, usage : BufferUsage) Self {
            const buffer = init();
            buffer.alloc(size, usage);
            return buffer;
        }

        pub fn deinit(self : Self) void {
            glDeleteBuffers(1, &self.handle);
        }

        pub fn bind(self : Self) void {
            glBindBuffer(@enumToInt(Target), self.handle);
        }

        pub fn unbind(self : Self) void {
            glBindBuffer(@enumToInt(Target), 0);
        }

        pub fn alloc(self : Self, size : usize, usage : BufferUsage) void {
            glNamedBufferData(self.handle, @intcast(c_longlong, size * @sizeOf(Element)), NULL, @enumToInt(usage));
        }

        pub fn data(self : Self, data_slice : [] const Element, usage : BufferUsage) void {
            const ptr = @ptrCast(* const c_void, data_slice.ptr);
            const size = @intCast(c_longlong, @sizeOf(Element) * data_slice.len);
            glNamedBufferData(self.handle, size, ptr, @enumToInt(usage));
        }

        pub fn subdata(self: Self, data_slice : [] const Element, offset : usize) void {
            const ptr = @ptrCast(* const c_void, data_slice.ptr);
            const size = @intCast(c_longlong, @sizeOf(Element) * data_slice.len);
            glNamedBufferSubData(self.handle, offset, size, ptr);
        }

        pub fn update(self : Self, data_slice : [] const Element) void {
            self.subdata(data_slice, 0);
        }
    };
}

// pub const VertexArray = struct {
//     handle : Handle,
//     indexType : ?u32 = null,

//     const Self = @This();

//     pub fn init() Self {
//         var handle : Handle = undefined;
//         glCreateVertexArrays(1, &handle);
//         return Self{ .handle = handle };
//     }

//     pub fn deinit(self : Self) void {
//         glDeleteVertexArrays(1, &self.handle);
//     }

//     pub fn bind(self : Self) Bound {
//         glBindVertexArray(self.handle);
//         return .{.array = self };
//     }

//     pub fn addVertexBuffer(self : Self, bindPoint : u32, buffer : anytype, offset : usize, comptime attribs : anytype) void {
//         const Element = @TypeOf(buffer).Element;
//         const target = @TypeOf(buffer).Target;
//         if (target != .Vertex) {
//             @compileError("Cannot add vertex buffer: target must be .Vertex, not ." ++ @tagName(target));
//         }
//         glVertexArrayVertexBuffer(self.handle, bindPoint, buffer.handle, @intCast(c_longlong, offset), @sizeOf(Element));
//         const info = @typeInfo(Element);
//         switch (info) {
//             .Struct => {
//                 if (info.Struct.layout == .Extern) {
//                     const fields = info.Struct.fields;
//                     inline for (fields) |field, i| {
//                         const field_type = field.field_type;
//                         const elem_count = elementCount(field_type);
//                         const elem_type = elementType(field_type);
//                         const field_offset = @byteOffsetOf(Element, field.name);
//                         const attrib = switch (@TypeOf(attribs)) {
//                             u32, comptime_int => attribs + i,
//                             [fields.len]u32, [fields.len]comptime_int => attribs[i],
//                             *[fields.len]u32, *[fields.len]comptime_int => attribs.*[i],
//                             else => |A| @compileError("invalid type for attribs: " ++ @typeName(A)),
//                         };
//                         glEnableVertexArrayAttrib(self.handle, attrib);
//                         glVertexArrayAttribFormat(self.handle, attrib, elem_count, elem_type, GL_FALSE, field_offset);
//                         glVertexArrayAttribBinding(self.handle, attrib, bindPoint);
//                     }
//                 }
//                 else {
//                     @compileError("cannot read layout of non-extern struct " ++ @typeName(T));
//                 }
//             },
//             else => @compileError("cannot read layout of non-struct " ++ @typeName(T)),
//         }
//     }

//     pub fn addIndexBuffer(self : *Self, buffer : anytype) void {
//         const target = @TypeOf(buffer).Target;
//         if (target != .Index) {
//             @compileError("Cannot add index buffer: target must be .Index, not ." ++ @tagName(target));
//         }
//         glVertexArrayElementBuffer(self.*.handle, buffer.handle);
//         self.*.indexType = switch(@TypeOf(buffer).Element) {
//             u8 => GL_UNSIGNED_BYTE,
//             u16 => GL_UNSIGNED_SHORT,
//             u32 => GL_UNSIGNED_INT,
//             else => unreachable,
//         };
//     }

//     pub fn vertexBindingDivisor(self : Self, bindPoint : u32, divisor : u32) void {
//         glVertexArrayBindingDivisor(self.handle, bindPoint, divisor);
//     }

//     pub fn elementCount(comptime T : type) comptime_int {
//         const info = @typeInfo(T);
//         return switch (info) {
//             .Float => {
//                 1;
//             },
//             .Int => {
//                 1;
//             },
//             .Struct => blk: {
//                 const info = math.meta.vectorTypeInfo(T).assert();
//                 const count = info.dimensions;
//                 if (count < 1 or count > 4) {
//                     @compileError("element count for vector types must be 1, 2, 3, or 4 (not " ++ count ++ ")");
//                 }
//                 break :blk count;
//             },
//             else => @compileError("unsupported type " ++ @typeName(T)),
//         };
//     }

//     pub fn elementType(comptime T : type) c_uint {
//         const info = @typeInfo(T);
//         return switch (info) {
//             .Float => |float| switch (float.bits) {
//                 16 => GL_HALF_FLOAT,
//                 32 => GL_FLOAT,
//                 64 => GL_DOUBLE,
//                 else => @compileError("unsupported float type " ++ @typeName(T)),
//             },
//             .Int => |int| switch (int.signedness) {
//                 .signed => switch (int.bits) {
//                     8 => GL_BYTE,
//                     16 => GL_SHORT,
//                     32 => GL_INT,
//                     else => @compileError("unsupported signed int type " ++ @typeName(T)),
//                 },
//                 .unsigned => switch (int.bits) {
//                     8 => GL_UNSIGNED_BYTE,
//                     16 => GL_UNSIGNED_SHORT,
//                     32 => GL_UNSIGNED_INT,
//                     else => @compileError("unsupported unsigned int type " ++ @typeName(T)),
//                 },
//             },
//             .Struct => elementType(math.meta.vectorTypeInfo(T).assert().Element),
//             else => @compileError("unsupported type " ++ @typeName(T)),
//         };
//     }

//     pub const Bound = struct {
//         array : Self,

//         const BSelf = @This();

//         pub fn drawElements(self : BSelf, mode : PrimitiveType, count : i32, offset : u32) void {
//             const index_type = self.array.indexType;
//             glDrawElements(@enumToInt(mode), count, index_type.?, @intToPtr(?*c_void, offset));
//         }

//         // pub fn unbind(self : BSelf) void {
//         //     glBindVertexArray(0);
//         // }

//     };
// };
