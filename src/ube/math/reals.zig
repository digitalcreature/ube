const std = @import("std");

/// Makes all numeric functions work across any real Real
pub fn specializeOn(comptime Real: type) type {

    return struct {
        
        const is_float : bool = switch(@typeInfo(Real)) {
            .Float => true,
            else => false,
        };

        pub fn lerp(x : Real, y : Real, t : Real) Real {
            return x + t * (y - x);
        }

        pub fn min(args: anytype) Real {
            var m : Real = args[0];
            comptime var i = 1;
            inline while (i < args.len) : (i +=1) {
                if (args[i] < m) {
                    m = args[i];
                }
            }
            return m;
        }

        pub fn max(args: anytype) Real {
            var m : Real = args[0];
            comptime var i = 1;
            inline while (i < args.len) : (i +=1) {
                if (args[i] > m) {
                    m = args[i];
                }
            }
            return m;
        }

        pub fn clamp(x : Real, low : Real, high : Real) Real {
            if (x < low) return low;
            if (is_float) {
                if (x > high) return high;
            }
            else {
                if (x >= high) return high - 1;
            }
            return x;
        }

        pub fn clamp01(x : Real) Real {
            return clamp(x, 0, 1);
        }
    };

}

usingnamespace std.testing;