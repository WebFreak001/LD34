module ld34.minigame.flappy;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;
import d2d;

final class Flappy : Minigame {
public:
	this(LD34 game) {
		super(game);
		heli = RectangleShape.create(new Texture("res/tex/flappy/heli.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest), vec2(), vec2(64,
			32));
		auto pipe = new Texture("res/tex/flappy/pipe.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		//dfmt off
		pipes = [
			RectangleShape.create(pipe, vec2(1000, -64), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(1400, -100), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(1800, -150), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(2200, -30), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(2600, -64), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3000, -100), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3400, -150), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3800, -30), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(4200, -64), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(4600, -100), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(5000, -150), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(5400, -30), vec2(64, 256), vec4(0, 1, 1, 0)),
			
			RectangleShape.create(pipe, vec2(1000, WindowHeight - 164), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(1400, WindowHeight - 200), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(1800, WindowHeight - 250), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(2200, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(2600, WindowHeight - 164), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(3000, WindowHeight - 200), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(3400, WindowHeight - 250), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(3800, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(4200, WindowHeight - 164), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(4600, WindowHeight - 200), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(5000, WindowHeight - 250), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(5400, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
		];
		//dfmt on
	}

	override void start(int difficulty) {
		super.start(difficulty);
		x = 200;
		y = 200;
		xv = 0.01f;
		yv = 0.002f;
		_won = true;
	}

	override void stop() {
	}

	override void update() {
		if (_game.isButtonADown)
			xv += 0.001f;
		if (_game.isButtonBDown)
			yv += 0.002f;
		y -= yv;
		yv -= 0.001f;
		x += xv;

		foreach (pipe; pipes) {
			if (hitsPipe(pipe.position, pipe.size)) {
				_done = true;
				_won = false;
			}
		}
		if (y < 0 || y >= WindowHeight) {
			_done = true;
			_won = false;
		}
	}

	bool hitsPipe(vec2 pos, vec2 size) {
		float px = pos.x - 400;
		float py = pos.y;
		return x >= px && x <= px + size.x && y >= py && y <= py + size.y;
	}

	override void draw() {
		heli.position = vec2(400, y);
		_game.target.draw(heli);

		matrixStack.push();
		matrixStack.top = matrixStack.top.translate2d(-x, 0);
		foreach (pipe; pipes) {
			_game.target.draw(pipe);
		}
		matrixStack.pop();
	}

	@property override Duration getPlayTime() const {
		return 5.seconds;
	}

private:
	RectangleShape heli;
	RectangleShape[] pipes;
	float x, y;
	float xv, yv;
}
