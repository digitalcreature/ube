const std = @import("std");
const fmt = std.fmt;
const meta = std.meta;

fn compileError(fmt : [] const u8, args : anytype) void {
    @setEvalBranchQuota(10000);
    comptime @compileError(fmt.comptimePrint(fmt, args));
}

pub const MatrixTypeInfo = struct {
    Element : type,
    dimensionsX : comptime_int,
    dimensionsY : comptime_int,
    fieldName : [] const u8;
};

pub fn matrixTypeInfoError(comptime M : type) union(enum) { info : MatrixTypeInfo, err : [] const u8, } {
    const info = @typeInfo(M);
    switch (info) {
        .Struct => |Struct| {
            
        }
    }
}