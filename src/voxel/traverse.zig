const std = @import("std");
const util = @import("util");
const math = @import("math");


const Int = util.types.Int;

usingnamespace @import("chunk.zig");

pub const Cardinal = math.cardinals.Cardinal3;
pub const Axis = Cardinal.Axis;

pub const Coords = extern struct {
    x: i32,
    y: i32,
    z: i32,
    
    const Self = @This();

    pub usingnamespace math.vector.ops(Self).arithmetic;

};

pub const LocalCoords = struct {
    
    x: Element,
    y: Element,
    z: Element,

    pub const element_bits = LocalIndex.element_bits;
    pub const Element = LocalIndex.Element;

    const Self = @This();

    pub const toLocalIndex = LocalIndex.fromLocalCoords;
    pub const fromLocalIndex = LocalIndex.toLocalCoords;

    pub usingnamespace math.vector.ops(Self).arithmetic;

};

pub const LocalIndex = struct {

    tag: Tag,

    pub const element_bits = Chunk.subdivisions;
    pub const tag_bits = element_bits * 3;

    pub const Element = Int(.unsigned, element_bits);
    pub const Tag = Int(.unsigned, tag_bits);

    pub const element_max: Element = std.math.maxInt(Element);
    
    const Self = @This();

    pub fn init(x: Element, y: Element, z: Element) Self {
        var tag: Tag = z;
        tag = (tag << element_bits) | y;
        tag = (tag << element_bits) | x;
        return Self {.tag = tag};
    }

    fn elementOffset(comptime axis: Axis) usize {
        return @enumToInt(axis) * element_bits;
    }

    fn elementMask(comptime axis: Axis) Tag {
        return @as(Tag, element_max) << elementOffset(axis);
    }

    pub fn toLocalCoords(self: Self) LocalCoords {
        return LocalCoords {
            .x = self.get(.x),
            .y = self.get(.y),
            .z = self.get(.z),
        };
    }

    pub fn fromLocalCoords(coords: LocalCoords) Self {
        return init(coords.x, coords.y, coords.z);
    }

    pub fn get(self: Self, comptime axis: Axis) Element {
        return @truncate(Element, self.tag >> elementOffset(axis));
    }

    pub fn set(self: *Self, comptime axis: Axis, value: Element) void {
        const mask = ~elementMask(axis);
        self.index = (self.index & mask) | (@as(Element3, value) << elementOffset(axis));
    }


    /// returns the location of this voxels neighbor in the given direction
    /// no bounds checks are performed. calling this on indices around the edges of the
    /// chunk will produce undefined behaviour. only call this when you know for sure your
    /// input is good
    pub fn getNeighborFast(self: Self, comptime dir: Cardinal) Self {
        const axis = dir.axis();
        const incr = 1 << elementOffset(axis);
        return switch (dir.sign()) {
            .positive => Self{ .tag = self.tag + incr },
            .negative => Self{ .tag = self.tag - incr },
        };
    }

    pub fn tryGetNeighbor(self: Self, comptime dir: Cardinal) ?Self {
        if (self.isAtBoundary(dir)) {
            return null;
        }
        else {
            return self.getNeighborFast(dir);
        }
    }

    pub fn isAtBoundary(self: Self, comptime dir: Cardinal) bool {
        const axis = dir.axis();
        const mask = elementMask(axis);
        const tag = self.tag;
        return switch (dir.sign()) {
            .positive => (tag | mask) == tag,
            .negative => (tag & ~mask) == tag,
        };
    }

    pub fn getAtBoundary(self: Self, comptime dir: Cardinal) Self {
        const axis = dir.axis();
        const mask = elementMask(axis);
        const tag = self.tag;
        return switch (dir.sign()) {
            .positive => Self{ .tag = tag | mask },
            .negative => Self{ .tag = tag & ~mask },
        };
    }
};

pub const PortableIndex = struct {
    
    chunk: *Chunk,
    index: LocalIndex,

    const Self = @This();

    pub fn init(chunk: *Chunk, index: LocalIndex) Self {
        return Self{
            .chunk = chunk,
            .index = index,
        };
    }

    pub fn initTag(chunk: *Chunk, tag: LocalIndex.Tag) Self {
        return init(chunk, LocalIndex{ .tag = tag });
    }

    /// get block neighbor, traversing chunk boundaries
    pub fn getNeighbor(self: Self, comptime dir: Cardinal) ?Self {
        const chunk = self.chunk;
        const index = self.index;
        if (index.isAtBoundary(dir)) {
            if (chunk.neighbors.get(dir)) |neighbor_chunk| {
                return init(neighbor_chunk, index.getAtBoundary(dir.negate()));
            }
            else {
                return null;
            }
        }
        else {
            return init(chunk, index.getNeighborFast(dir));
        }
    }

};