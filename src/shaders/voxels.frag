#version 450 core

in vec3 color;
in vec2 uv;

out vec4 FragColor;

uniform sampler2D albedo;

void main() {
   FragColor = vec4(color.x, color.y, color.z, 1.0f) * texture(albedo, uv);
};