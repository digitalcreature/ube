pub const Signedness = enum {
    unsigned = 0,
    signed = 1,
};

pub fn Int(comptime signedness: Signedness, comptime bits: u16) type {
    const is_signed = signedness == .signed;
    return @Type(.{
        .Int = .{
            .is_signed = is_signed,
            .bits = bits,
        }
    });
}