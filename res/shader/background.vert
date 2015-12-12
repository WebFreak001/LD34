#version 330
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_tex;
uniform mat4 transform;
uniform mat4 projection;
void main()
{
	gl_Position = projection * transform * vec4(in_position, 1);
}