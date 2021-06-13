const std = @import("std");
const math = @import("math");

usingnamespace @import("types.zig");
usingnamespace math.glm;

const config = @import("config.zig").config;

const Volume = @import("volume.zig").Volume;
// const ChunkMesh = @import("mesh.zig").ChunkMesh;

pub const Chunk = struct {

    volume: *Volume,
    position: Coords,
    voxels: VoxelData,
    neighbors: Neighbors = std.mem.zeroes(Neighbors),
    model: ?*Model = null,

    const Neighbors = EnumIndexedArray(?*Self, Cardinal);

    pub const VoxelData = DataArray(VoxelTypeId);

    const Self = @This();

    pub const width = config.chunk_width;
    pub const width2 = width * width;
    pub const width3 = width * width * width;
    pub const edge_distance = @intToFloat(f32, config.chunk_width) * config.voxel_size;

    pub usingnamespace @import("chunk/lib.zig");

    pub const DataArray = ChunkDataArray;

    pub fn init(volume: *Volume, position: Coords) Self {
        return .{
            .volume = volume,
            .position = position,
            .voxels = VoxelData.init(),
        };
    }

    pub fn deinit(self : Self) void {
        self.voxels.deinit();
    }

    pub fn coordsAreInBounds(coords: Coords) bool {
        return
            (coords.x < width and coords.y < width and coords.z < width) and
            (coords.x >= 0 and coords.y >= 0 and coords.z >= 0);
    }

    pub const QualifiedCoords = struct { chunk: *const Self, coords: Coords };

    pub fn getNeighborCoords(self: *const Self, coords: Coords) ?QualifiedCoords {
        if (coordsAreInBounds(coords)) {
            return QualifiedCoords{
                .chunk = self,
                .coords = coords,
            };
        }
        var x = coords.x;
        var y = coords.y;
        var z = coords.z;
        const w = @intCast(i32, width);
        // check x
        if (x >= width) {
            if (self.neighbors[0]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x - w, y, z));
            }
        }
        else if (x < 0) {
            if (self.neighbors[3]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x + w, y, z));
            }
        }
        // check y
        if (y >= width) {
            if (self.neighbors[1]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y - w, z));
            }
        }
        else if (y < 0) {
            if (self.neighbors[4]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y + w, z));
            }
        }
        // check z
        if (z >= width) {
            if (self.neighbors[2]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y, z - w));
            }
        }
        else if (z < 0) {
            if (self.neighbors[5]) |neighbor| {
                return neighbor.getNeighborCoords(Coords.init(x, y, z + w));
            }
        }
        return null;
    }
};

fn ChunkDataArray(comptime T : type) type {
    return struct {

        data : Data = std.mem.zeroes(Data),

        pub const Data = [width3]T;

        pub const width = Chunk.width;
        pub const width2 = Chunk.width2;
        pub const width3 = Chunk.width3;

        pub fn init() @This() {
            return .{};
        }

        fn deinit(self : @This()) void {}

        pub fn indexToCoordsFast(i: usize) Coords {
            const x: i32 = i % width;
            const y: i32 = (i % (width2)) / width;
            const z: i32 = i / (width2);
            return Coors.init(x, y, z);
        }

        pub fn coordsToIndexFast(coords: Coords) usize {
            const x = coords.x;
            const y = coords.y;
            const z = coords.z;
            return x + y * width + z * width2;
        }

        pub fn tryIndexToCoords(i: usize) ?Coords {
            if (i >= width3) {
                return null;
            }
            else {
                return indexToCoordsFast(i);
            }
        }

        pub fn tryCoordsToIndex(coords: Coords) ?usize {
            const x = coords.x;
            const y = coords.y;
            const z = coords.z;
            if (x < 0 or y < 0 or z < 0 or x >= width or y >= width or z >= width) {
                return null;
            }
            else {
                return x + y * width + z * width2;
            }
        }

        /// get the value stored at coords. out of bounds coords are not checked.
        /// only use when you know your coords are in bounds
        pub fn getFast(self: @This(), coords: Coords) T {
            const index = coordsToIndexFast(coords);
            return self.data[index];
        }

        /// get the value stored at coords. returns null if coords is out of bounds
        pub fn tryGet(self: @This(), coords: Coords) ?T {
            if (tryCoordsToIndex(coords)) |index| {
                return self.data[index];
            }
            else {
                return null;
            }
        }

        pub fn getPtrFast(self: *@This(), coords: Coords) *T {
            const index = coordsToIndexFast(coords);
            return &self.data[index];
        }
        
        pub fn tryGetPtr(self: *This(), coords: Coords) ?*T {
            if (tryCoordsToIndex(coords)) |index| {
                return &self.data[index];
            }
            else {
                return null;
            }
        }

    };
}

pub fn EnumIndexedArray(comptime T: type, comptime E: type) type {
    switch (@typeInfo(E)) {
        .Enum => |Enum| {
            if (Enum.is_exhaustive) @compileError("enum must be non-exhaustive to be used as an index");
            for (Enum.fields) |field, i| {
                if (field.value != i) {
                    @compileError("enum must start at 0, increasing my 1, to be used as an index");
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

                pub fn getPtr(self: *Self, index: E) *T {
                    return &self.data[@enumToInt(E)];
                }

            };
        },
        else  => @compileError("cannot create enum indexed array indexed by non-enum type " ++ @typeName(E))
    }
}

const DataIndex = struct {

        index: Index,

        const width = Chunk.width;

        pub const TryFromCoordsError = error {
            OutOfBounds,
        };

        pub const element_bits = std.math.log2_int(width);
        pub const index_bits = element_bits * 3;

        pub const Index = @Type(.{ .Int = .{ .is_signed = false, .bits = index_bits} });
        pub const Element = @Type(.{ .Int = .{ .is_signed = false, .bits = element_bits} });

        const Self = @This();

        /// convert from coords to index, with no range checks.
        /// only use when coords can be trusted, as out of bounds coords will not encode correctly
        pub fn fromCoords(coords: Coords) Self {
            const x: Index = @truncate(Element, @intCast(u32, coords.x));
            const y: Index = @truncate(Element, @intCast(u32, coords.y));
            const z: Index = @truncate(Element, @intCast(u32, coords.z));
            return Self {
                .index = (x | y << element_bits | z << (element_bits * 2)),
            };
        }

        /// convert from coords to index, checking for out of bounds
        /// you probably wont be using this much
        pub fn tryFromCoords(coords: Coords) TryFromCoordsError!Self {
            const self = fromCoords(coords);
            const check_coords = self.toCoords();
            // if the coords are out of bounds, they will not decode properly from the same index
            if (check_coords.equals(coords)) {
                return self;
            }
            else {
                return TryFromCoordsError.OutOfBounds;
            }
        }

        /// this will always be in bounds, due to our power of 2 requirement
        /// thank god for zig's non-po2 ints!
        pub fn toCoords(self: Self) Coords {
            return Coords.init(self.get(.x), self.get(.y), self.get(.z));
        }

        pub fn get(self: Self, comptime axis: Axis) Element {
            return @truncate(Element, self.index >> (@enumToInt(axis) * element_bits));
        }

        pub fn set(self: *Self, comptime axis: Axis, value: Element) void {
            const v: Index = @as(Index, value) << (@enumToInt(axis) * element_bits);
            self.index = (self.index & ~elementMask(axis)) | v;
        }

        pub fn neighbor(self: Self, comptime dir: Cardinal) Self {
            const axis = dir.axis();
            const increment: Index = 1 << (@enumToInt(axis) * element_bits);
            return switch (dir.sign())  {
                .positive => Self {.index = self.index + increment},
                .negative => Self {.index = self.index - increment},
            };
        }

        // using power of two makes everything so much faster! binary is cool
        pub fn faceIsEdge(self: Self, comptime dir: Cardinal) bool {
            const axis = dir.axis();
            const mask = elementMask(axis);
            const i = self.index;
            return switch (dir.sign()) {
                .positive => (i & mask) == mask,
                .negative => (~i & mask) == mask,
            };
        }

        fn elementMask(comptime axis: Axis) Index {
            const element_mask = @truncate(Index, (width << 1) - 1);
            return element_mask << (@enumToInt(axis) * element_bits);
        }

    };