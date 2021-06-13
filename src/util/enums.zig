const std = @import("std");

pub fn EnumIndexedArray(comptime T: type, comptime E: type) type {
    switch (@typeInfo(E)) {
        .Enum => |Enum| {
            if (Enum.is_exhaustive) @compileError("enum must be non-exhaustive to be used as an index");
            for (Enum.fields) |field, i| {
                if (field.value != i) {
                    @compileError("enum must start at 0, increasing by 1, to be used as an index");
                }
            }
            return struct {
                
                data: Data,

                pub const len = Enum.fields.len;
                pub const Data = [len]T;

                const Self = @This();

                pub fn get(self: Self, index: E) T {
                    return self.data[@enumToInt(E)];
                }

                pub fn ptr(self: *Self, index: E) *T {
                    return &self.data[@enumToInt(E)];
                }

                pub fn set(self: *Self, index: E, value: T) void {
                    self.data[@enumToInt(E)] = value;
                }

            };
        },
        else  => @compileError("cannot create enum indexed array indexed by non-enum type " ++ @typeName(E))
    }
}

fn ValuesArray(comptime T: type) type {
    switch (@typeInfo(T)) {
        .Enum => |info| {
            return [info.fields.len]T;
        },
        else => @compileError("expected enum type, found " ++ @typeName(T))
    }
}

    
pub fn valuesArray(comptime T: type) ValuesArray(T) {
    comptime {
        var vals: ValuesArray(T) = undefined;
        const info = @typeInfo(T).Enum;
        for (info.fields) |field, i| {
            vals[i] = @intToEnum(T, field.value);
        }
        return vals;
    }
}