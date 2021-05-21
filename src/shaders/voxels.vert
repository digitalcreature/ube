#version 450 core
layout (location = 0) in uint vertID;
layout (location = 1) in uint encodedPos;

out vec3 color;

uniform float voxel_size;
uniform vec3 light_dir;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;

void main() {
    uint vx = encodedPos & 255;
    uint vy = encodedPos >> 8 & 255;
    uint vz = encodedPos >> 16 & 255;
    uint face = encodedPos >> 24 & 255;
    float u;
    float v;
    if (vertID == 0 || vertID == 2) {
        u = 0;
    }
    else {
        u = 1;
    }
    if (vertID < 2) {
        v = 1;
    }
    else {
        v = 0;
    }
    vec3 pos = vec3(0.0);
    vec3 norm = vec3(0.0);
    switch (face) {
        case 0: // x+
            pos.x = 1;
            pos.y = u;
            pos.z = v;
            norm.x = 1;
            break;
        case 1: // y+
            pos.x = v;
            pos.y = 1;
            pos.z = u;
            norm.y = 1;
            break;
        case 2: // z+
            pos.x = u;
            pos.y = v;
            pos.z = 1;
            norm.z = 1;
            break;
        case 3: // x-
            pos.x = 0;
            pos.y = v;
            pos.z = u;
            norm.x = -1;
            break;
        case 4: // y-
            pos.x = u;
            pos.y = 0;
            pos.z = v;
            norm.y = -1;
            break;
        case 5: // z-
            pos.x = v;
            pos.y = u;
            pos.z = 0;
            norm.z = -1;
            break;
    }
    pos += vec3(vx, vy, vz);
    pos *= voxel_size;
    pos -= vec3(16.0); // temporary centering
    gl_Position = proj * view * model * vec4(pos, 1.0);
    float light = abs(dot(light_dir, norm));
    color = vec3(light);
    // if (face < 3) {
    //     color = vec3(0.5, 0.8, 0.5) * light;
    // }
    // else {
    //     color = vec3(0.8, 0.5, 0.5) * light;
    // }
};