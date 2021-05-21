#version 450 core

layout (location = 0) in vec2 quadUV;

layout (location = 1) in uint encoded_pos;
layout (location = 2) in uint encoded_lighting;

in int gl_VertexID;
in int gl_InstanceID;

out vec3 color;
out vec2 tex_coord;
out vec2 uv;
out float ao[2][2];

uniform float voxel_size;
uniform vec3 light_dir;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;

float get_ao(uint vert_id) {
    uint lighting = (encoded_lighting >> (8 * vert_id)) & 255;
    return (float(lighting) / 3) * 0.75; // ao_strength;
}

void main() {
    uint vx = encoded_pos & 255;
    uint vy = encoded_pos >> 8 & 255;
    uint vz = encoded_pos >> 16 & 255;
    uint face = encoded_pos >> 24 & 255;
    float u = quadUV.x;
    float v = quadUV.y;
    uv = vec2(u, v);
    vec3 pos = vec3(0.0);
    vec3 norm = vec3(0.0);
    switch (face) {
        case 0: // x+
            pos.x = 1;
            pos.y = u;
            pos.z = v;
            norm.x = 1;
            tex_coord.x = vy + u;
            tex_coord.y = vz + v;
            break;
        case 1: // y+
            pos.x = v;
            pos.y = 1;
            pos.z = u;
            norm.y = 1;
            tex_coord.x = vz + u;
            tex_coord.y = vx + v;
            break;
        case 2: // z+
            pos.x = u;
            pos.y = v;
            pos.z = 1;
            norm.z = 1;
            tex_coord.x = vx + u;
            tex_coord.y = vy + v;
            break;
        case 3: // x-
            pos.x = 0;
            pos.y = v;
            pos.z = u;
            norm.x = -1;
            tex_coord.x = vz + u;
            tex_coord.y = vy + v;
            break;
        case 4: // y-
            pos.x = u;
            pos.y = 0;
            pos.z = v;
            norm.y = -1;
            tex_coord.x = vx + u;
            tex_coord.y = vz + v;
            break;
        case 5: // z-
            pos.x = v;
            pos.y = u;
            pos.z = 0;
            norm.z = -1;
            tex_coord.x = vy + u;
            tex_coord.y = vx + v;
            break;
    }
    pos += vec3(vx, vy, vz);
    pos *= voxel_size;
    pos -= vec3(16.0); // temporary centering
    gl_Position = proj * view * model * vec4(pos, 1.0);
    float light = abs(dot(light_dir, norm));
    color = vec3(light);
    tex_coord /= 4;
    ao[0][0] = get_ao(2);
    ao[0][1] = get_ao(0);
    ao[1][0] = get_ao(3);
    ao[1][1] = get_ao(1);
};