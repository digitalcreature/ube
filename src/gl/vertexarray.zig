const std = @import("std");
const meta = std.meta;
const math = @import("math");
// const math = @import("../math/lib.zig");

usingnamespace @import("buffer.zig");

usingnamespace @import("c");
usingnamespace @import("types.zig");

const voxel = @import("voxel");

pub const VertexBufferBindConfig = struct {
    bind_index : c_uint = 0,
    attrib_start : c_uint = 0,
    divisor : ?c_uint = null,
};

pub const VertexBufferBindInfo = struct {
    
    Attribs: type,
    config: VertexBufferBindConfig,

    const Self = @This();

    pub fn tryGet(comptime T: type) ?Self {
        if (@hasDecl(T, "info") and @TypeOf(T.info) == Self) {
            return T.info;
        }
        else {
            return null;
        }
    }

};

pub fn VertexBufferBind(comptime Attribs: type, comptime config : VertexBufferBindConfig) type {
    switch (@typeInfo(Attribs)) {
        .Struct => |Struct| {
            if (Struct.layout == .Extern) {
                const fields = Struct.fields;
                const attrib_count = fields.len;

                return struct {
                    vao: Handle,
                    vbo : ?VertexBuffer(Attribs) = null,

                    pub const binding_index = config.bind_index;

                    pub const info = VertexBufferBindInfo{ .Attribs = Attribs, .config = config };

                    const Self = @This();

                    pub const AttribsType = Attribs;

                    pub fn init(vao: Handle) Self {
                        const self: Self = .{
                            .vao = vao,
                        };
                        inline for (fields) |field, i| {
                            const attrib_index = i + config.attrib_start;
                            const name = field.name ++ ""; // quick and dirty conversion to null-terminated string
                            const Element = field.field_type;
                            const attrib_info = attribInfo(Element);
                            const attrib_type = @enumToInt(attrib_info.attrib_type);
                            glEnableVertexArrayAttrib(vao, attrib_index);
                            const offset = @byteOffsetOf(Attribs, field.name);
                            switch (attrib_info.attrib_type) {
                                .Half, .Float => glVertexArrayAttribFormat(vao, attrib_index, attrib_info.element_count, attrib_type, 0, offset),
                                .Double => glVertexArrayAttribLFormat(vao, attrib_index, attrib_info.element_count, attrib_type, offset),
                                else => glVertexArrayAttribIFormat(vao, attrib_index, attrib_info.element_count, attrib_type, offset),
                            }
                            glVertexArrayAttribBinding(vao, attrib_index, binding_index);
                        }
                        if (config.divisor) |divisor| {
                            glVertexArrayBindingDivisor(vao, binding_index, divisor);
                        }
                        return self;
                    }

                    pub fn bindBuffer(self: *Self, buffer: VertexBuffer(Attribs)) void {
                        const offset = 0; // TODO: figure out good api for these offsets
                        glVertexArrayVertexBuffer(self.*.vao, binding_index, buffer.handle, offset, @sizeOf(Attribs));
                        self.*.vbo = buffer;
                    }

                    pub fn deinitBoundBuffer(self: Self) void {
                        if (self.vbo) |buffer| {
                            buffer.deinit();
                        }
                    }

                };
            } else {
                @compileError("attribs type must be an extern struct, not " ++ @typeName(Attribs));
            }
        },
        else => @compileError("attribs type must be an extern struct, not " ++ @typeName(Attribs)),
    }
}

pub const AttribType = enum(c_uint) {
    Byte = GL_BYTE,
    UByte = GL_UNSIGNED_BYTE,
    Short = GL_SHORT,
    UShort = GL_UNSIGNED_SHORT,
    Int = GL_INT,
    UInt = GL_UNSIGNED_INT,
    Half = GL_HALF_FLOAT,
    Float = GL_FLOAT,
    Double = GL_DOUBLE,

    pub fn getType(comptime self: AttribType) type {
        return switch (self) {
            .Byte => i8,
            .UByte => u8,
            .Short => i16,
            .UShort => u16,
            .Int => i32,
            .UInt => u32,
            .Half => f16,
            .Float => f32,
            .Double => f64,
        };
    }

    pub fn fromType(comptime T: type) AttribType {
        return switch (T) {
            i8 => .Byte,
            u8 => .UByte,
            i16 => .Short,
            u16 => .UShort,
            i32 => .Int,
            u32 => .UInt,
            f16 => .Half,
            f32 => .Float,
            f64 => .Double,
            else => @compileError("unsupported attrib primitive " ++ @typeName(T)),
        };
    }
};

pub const AttribInfo = struct {
    Element: type,
    attrib_type: AttribType,
    element_count: usize,
};

fn attribInfo(comptime Element: type) AttribInfo {
    switch (@typeInfo(Element)) {
        .Int, .Float => return .{
            .Element = Element,
            .attrib_type = AttribType.fromType(Element),
            .element_count = 1,
        },
        .Struct => {
            const vector_info = math.meta.vectorTypeInfo(Element).option();
            if (vector_info) |info| {
                switch (info.dimensions) {
                    2, 3, 4 => return .{
                        .Element = Element,
                        .attrib_type = AttribType.fromType(info.Element),
                        .element_count = info.dimensions,
                    },
                    else => @compileError("only 2, 3, and 4 dimensional vector attribs are supported, not " ++ @typeName(Element)),
                }
            } else {
                @compileError("only vectors and single attrib types currently supported. matrix support is planned (" ++ @typeName(Element) ++ ")");
            }
        },
        else => @compileError("only vectors and single attrib types currently supported, not " ++ @typeName(Element)),
    }
}

fn EmptyMixin(comptime Self: type) type { return struct {}; }

pub fn VertexArray(comptime VertexBufferBinds: type, comptime index_element: type) type {
    return VertexArrayExt(VertexBufferBinds, index_element, EmptyMixin);
}

pub fn VertexArrayExt(comptime VertexBufferBinds: type, comptime index_element: type, comptime Mixin : fn(comptime type) type) type {
    return struct {
        handle: Handle,
        buffers: VertexBufferBinds,
        ibo: ?IndexBuffer(IndexElement) = null,
        owns_ibo: bool = false,

        pub const IndexElement = index_element;

        const Self = @This();

        pub usingnamespace Mixin(Self);

        pub fn init() Self {
            var self: Self = undefined;
            glCreateVertexArrays(1, &self.handle);
            self.initVertexBufferBinds(VertexBufferBinds, &self.buffers);
            return self;
        }

        fn initVertexBufferBinds(self: *Self, comptime Binds: type, binds: *Binds) void {
            if (VertexBufferBindInfo.tryGet(Binds)) |info| {
                binds.* = Binds.init(self.handle);
            }
            else {
                switch (@typeInfo(Binds)) {
                    .Struct => |Struct| {
                        inline for (Struct.fields) |field| {
                            self.initVertexBufferBinds(field.field_type, &@field(binds, field.name));
                        }
                    },
                    else => @compileError("vertex buffer binds type bust be a struct, not " ++ @typeName(Binds)),
                }
            }
        }

        pub fn deinit(self: Self) void {
            glDeleteVertexArrays(1, &self.handle);
            if (self.owns_ibo) {
                if (self.ibo) |ibo| {
                    ibo.deinit();
                }
            }
        }

        /// given a struct with vertex buffer fields, attempt to bind buffers according to matching bind point field names. attrib types are checked
        // pub fn bindVertexBuffers(self: Self, buffers: anytype) void {
        //     const Buffers = @TypeOf(buffers);
        //     switch (@typeInfo(Buffer)) {
        //         .Struct => |Struct| {
        //             inline for (Struct.fields) |field| {
        //                 if (@hasField(VertexBufferBinds, field.name)) {
        //                     const BindType = @TypeOf(@field(VertexBufferBinds, field.name));
        //                     if (field.field_type == VertexBuffer(BindType.AttribsType)) {
        //                         @field(VertexBufferBinds, field.name).bindBuffer(@field(buffers, field.name));
        //                     }
        //                 }
        //             }
        //         },
        //         else => @compileError("cannot bind non-struct vertex buffer value of type " ++ @typeName(Buffers)),
        //     }
        // }

        pub fn bindIndexBuffer(self: *Self, buffer: IndexBuffer(IndexElement)) void {
            glVertexArrayElementBuffer(self.handle, buffer.handle);
            self.*.ibo = buffer;
        }

        pub fn bind(self: Self) void {
            glBindVertexArray(self.handle);
        }

        /// this is just glBindVertexArray(0), it doesnt need to be called from the currently bound array
        pub fn unbind(self: Self) void {
            glBindVertexArray(0);
        }
    };
}
