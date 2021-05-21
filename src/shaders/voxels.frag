#version 450 core


in vec3 color;
in vec2 tex_coord;
in vec2 uv;
in float ao[2][2];

out vec4 FragColor;

uniform sampler2D albedo;

#define TILE_RES 4

void main() {
   vec2 quantized_uv = floor(uv * TILE_RES) / TILE_RES;
   float frag_ao = 1 - mix(
      mix(ao[0][0], ao[1][0], quantized_uv.x),
      mix(ao[0][1], ao[1][1], quantized_uv.x),
      quantized_uv.y
   );
   FragColor = vec4(color * frag_ao, 1.0f) * texture(albedo, tex_coord);
};