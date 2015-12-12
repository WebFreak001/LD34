#version 330
uniform sampler2D tex;
uniform vec3 color;
uniform float opacity;
in vec2 texCoord;
layout(location = 0) out vec4 out_frag_color;
void main()
{
	out_frag_color = texture(tex, texCoord) * vec4(color, opacity);
}