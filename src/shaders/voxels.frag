#version 450 core


in vec3 color;
in vec2 tex_coord;
in vec2 uv;
flat in float ao[2][2];
flat in uint material;

out vec4 FragColor;

uniform sampler2DArray albedo;

#define TILE_RES 8

float layer2coord(uint capacity, uint layer) {
	return max(0, min(float(capacity - 1), floor(float(layer) + 0.5)));
}

void main() {
   vec2 quantized_uv = floor(uv * TILE_RES) / TILE_RES;
   float frag_ao = 1 - mix(
      mix(ao[0][0], ao[1][0], quantized_uv.x),
      mix(ao[0][1], ao[1][1], quantized_uv.x),
      quantized_uv.y
   );
   FragColor = vec4(color * frag_ao, 1.0f) * texture(albedo, vec3(tex_coord, layer2coord(2, material)));
};