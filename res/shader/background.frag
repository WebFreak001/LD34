#version 330
uniform vec2 offset;
layout(location = 0) out vec4 out_frag_color;

float x;
float y;
float d;
float rx;
float ry;
float randRes;

float rand(vec2 seed);

float hasStar() {
	if (randRes > 0.0) {
		float cx = rx * d;
		float cy = ry * d;

		float r = sqrt(pow(x - cx, 2) + pow(y - cy, 2));
		return 1.0 - ((r * 2.0) / d);
	}
	return 0.0;
}

vec4 starColor() {
	return vec4(
		abs(mod(y - x, 255.0)) / 255.0,
		abs(mod(x + y, 255.0)) / 255.0,
		abs(mod(x - y, 255.0)) / 255.0,
		1.0
	) * 1.5;
}

float blink() {
	if (randRes > 0.5) {
		return sin(randRes/3.0+(offset.x+offset.y+gl_FragCoord.x)/d*10)/2.0 + 0.5;
	}
	return 1.0;
}

void main() {
	x = round(offset.x + gl_FragCoord.x);
	y = round(offset.y + gl_FragCoord.y);
	d = 100.0;
	rx = round(x / d);
	ry = round(y / d);
	randRes = rand(vec2(rx, ry));
	vec4 result = starColor() * hasStar() * blink();
	out_frag_color = result;
}

float rand(vec2 seed) {
	return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453);
}