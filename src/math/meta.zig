const std = @import("std");
const fmt = std.fmt;
const meta = std.meta;

pub fn TypeInfoOrError(comptime T : type) type {
    return union(enum) {
        info : T,
        err : [] const u8,

        const Self = @This();

        pub fn assert(comptime self : Self) T {
            return switch (self) {
                .info => |info| info,
                .err => |err| @compileError(err),
            };
        }

        pub fn option(comptime self : Self) ?T {
            return switch (self) {
                .info => |info| info,
                .err => null,
            };
        }
    };
}

pub fn compileError(fmt : [] const u8, args : anytype) void {
    @setEvalBranchQuota(10000);
    comptime @compileError(fmt.comptimePrint(fmt, args));
}

pub const VectorTypeInfo = struct {
    dimensions : u32,
    Element : type,
    field_names : []const []const u8,

    pub fn assertDimensions(comptime self : VectorTypeInfo, comptime dimensions : u32) void {
        if (self.dimensions != dimensions) {
            comptime compileError("expected {d} dimensional vector, found {d} dimensional vector", .{dimensions, self.dimensions});
        }
    }

    pub fn assertElementType(comptime self : VectorTypeInfo, comptime Element : type) void {
        if (self.Element != Element) {
            @compileError("expected " ++ @typeName(Element) ++ " vector, found " ++ @typeName(self.Element) ++ " vector");
        }
    }

    pub fn assertSimilar(comptime self : VectorTypeInfo, comptime T : type) void {
        const info = vectorTypeInfo(T).assert();
        self.assertDimensions(info.dimensions);
        self.assertElementType(info.Element);
    }
};

pub fn vectorTypeInfo(comptime T : type) TypeInfoOrError(VectorTypeInfo) {
    var info = @typeInfo(T);
    switch (info) {
        .Struct => |Struct| {
            // if (Struct.layout == .Extern) {
                const fields = Struct.fields;
                if (fields.len < 1) return .{ .err = "vector struct must have at least one member" };
                const dimensions = fields.len;
                const Element = fields[0].field_type;
                comptime var i : comptime_int = 1;
                inline while (i < fields.len) : (i += 1) {
                    const ftype = fields[i].field_type;
                    if (ftype != Element) {
                        return .{ .err = "vector struct must have homogenous field types (expected "
                            ++ @typeName(Element) ++ ", found " ++ @typeName(ftype) ++ " for field " ++ fields[i].name ++ ")"};
                    }
                }
                var field_names : [dimensions][]const u8 = undefined;
                inline for (fields) |field, f| {
                    field_names[f] = field.name;
                }
                return .{ .info = .{ .dimensions = dimensions, .Element = Element, .field_names = field_names[0..] }};
            // }
            // else {
            //     return .{ .err = "vector struct must be extern" } ;
            // }
        },
        else => return .{ .err = "vector type must be a struct, not " ++ @typeName(T)},
    }
}

pub const MatrixTypeInfo = struct {
    Element : type,
    row_count : comptime_int,
    col_count : comptime_int,
    field_name : [] const u8,

    const Self = @This();

    pub fn isSquare(comptime self : Self) bool {
        return self.row_count == self.col_count;
    }

    pub fn assertSquare(comptime self : Self) void {
        if (!self.isSquare()) {
            comptime compileError("matrix must be square, not {d}x{d}", .{self.row_count, self.col_count});
        }
    }

    pub fn assertDimensions(comptime self : Self, comptime rows : comptime_int, comptime cols : comptime_int) void {
        if (self.row_count != rows or self.col_count != cols) {
            comptime compileError("expected {d}x{d} matrix, found {d}x{d} matrix", .{rows, cols, self.row_count, self.col_count});
        }
    }

    pub fn assertElementType(comptime self : Self, comptime T : type) void {
        if (T != self.Element) {
            @compileError("expected " ++ @typeName(T) ++ " matrix, found " ++ @typeName(self.Element) ++ "matrix");
        }
    }

    pub fn assertSimilar(comptime self : Self, comptime T : type) void {
        const info = matrixTypeInfo(T).assert();
        self.assertDimensions(info.row_count, info.col_count);
        self.assertElementType(info.Element);
    }
};

pub fn matrixTypeInfo(comptime M : type) TypeInfoOrError(MatrixTypeInfo) {
    const info = @typeInfo(M);
    switch (info) {
        .Struct => |Struct| {
            const fields = Struct.fields;
            if (fields.len != 1) return .{ .err = "matrix struct must have a single member" };
            const field = fields[0];
            switch (@typeInfo(field.field_type)) {
                .Array => |Array| {
                    const row_count = Array.len;
                    switch (@typeInfo(Array.child)) {
                        .Array => |Array2| {
                            const col_count = Array2.len;
                            switch (@typeInfo(Array2.child)) {
                                .Float => {
                                    const Element = Array2.child;
                                    return .{ .info = .{
                                        .Element = Element,
                                        .row_count = row_count,
                                        .col_count = col_count,
                                        .field_name = field.name,
                                    }};
                                },
                                else => {
                                    return .{ .err = "only floating point matrices are supported, not " ++ @typeName(Array2.child) };
                                }
                            }
                        },
                        else => {
                            return .{ .err = "matrix field must be a 2d array, not " ++ @typeName(field.field_type)};
                        }
                    }
                },
                else => {
                    return .{ .err = "matrix field must be a 2d array, not " ++ @typeName(field.field_type)};
                }
            }
        },
        else => return .{ .err = "matrix type must be a struct, not " ++ @typeName(M)}
    }
}