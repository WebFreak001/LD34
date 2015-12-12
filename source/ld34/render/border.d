module ld34.render.border;

import d2d;

class Border : Transformable, IDrawable {
public:
	this(Texture texture) {
		//dfmt off
		grid[0][0] = RectangleShape.create(texture, vec2(0, 0), vec2(4, 4), vec4(0, 0, 0.25, 0.25));
		grid[1][0] = RectangleShape.create(texture, vec2(4, 0), vec2(4, 4), vec4(0.25, 0, 0.75, 0.25));
		grid[2][0] = RectangleShape.create(texture, vec2(8, 0), vec2(4, 4), vec4(0.75, 0, 1, 0.25));
		
		grid[0][1] = RectangleShape.create(texture, vec2(0, 4), vec2(4, 4), vec4(0, 0.25, 0.25, 0.75));
		grid[1][1] = RectangleShape.create(texture, vec2(4, 4), vec2(4, 4), vec4(0.25, 0.25, 0.75, 0.75));
		grid[2][1] = RectangleShape.create(texture, vec2(8, 4), vec2(4, 4), vec4(0.75, 0.25, 1, 0.75));
		
		grid[0][2] = RectangleShape.create(texture, vec2(0, 8), vec2(4, 4), vec4(0, 0.75, 0.25, 1));
		grid[1][2] = RectangleShape.create(texture, vec2(4, 8), vec2(4, 4), vec4(0.25, 0.75, 0.75, 1));
		grid[2][2] = RectangleShape.create(texture, vec2(8, 8), vec2(4, 4), vec4(0.75, 0.75, 1, 1));
		//dfmt on
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null) {
		matrixStack.push();
		matrixStack.top = matrixStack.top * transform;
		foreach(x; 0 .. 3)
			foreach(y; 0 .. 3)
				grid[x][y].draw(target, shader);
		matrixStack.pop();
	}

	@property void setSize(vec2 size) {
		_size = size;
		update();
	}

	@property void borderSize(int size) {
		_borderSize = size;
		update();
	}

private:
	void update() {
		auto width = _size.x - _borderSize - _borderSize;
		auto height = _size.y - _borderSize - _borderSize;
		grid[0][0].size = vec2(_borderSize, _borderSize);
		grid[0][0].create();
		
		grid[2][0].size = vec2(_borderSize, _borderSize);
		grid[2][0].position = vec2(_borderSize + width, 0);
		grid[2][0].create();
		
		grid[0][2].size = vec2(_borderSize, _borderSize);
		grid[0][2].position = vec2(0, _borderSize + height);
		grid[0][2].create();
		
		grid[2][2].size = vec2(_borderSize, _borderSize);
		grid[2][2].position = vec2(_borderSize + width, _borderSize + height);
		grid[2][2].create();
		
		grid[1][0].size = vec2(width, _borderSize);
		grid[1][0].position = vec2(_borderSize, 0);
		grid[1][0].create();
		
		grid[0][1].size = vec2(_borderSize, height);
		grid[0][1].position = vec2(0, _borderSize);
		grid[0][1].create();
		
		grid[1][2].size = vec2(width, _borderSize);
		grid[1][2].position = vec2(_borderSize, _borderSize + height);
		grid[1][2].create();
		
		grid[2][1].size = vec2(_borderSize, height);
		grid[2][1].position = vec2(_borderSize + width, _borderSize);
		grid[2][1].create();
		
		grid[1][1].size = vec2(width, height);
		grid[1][1].position = vec2(_borderSize, _borderSize);
		grid[1][1].create();
	}

	int _borderSize = 4;
	vec2 _size;
	RectangleShape[3][3] grid;
}
