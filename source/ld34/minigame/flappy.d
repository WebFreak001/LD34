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
			RectangleShape.create(pipe, vec2(1400, -80), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(1800, -130), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(2200, -10), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(2600, -44), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3000, -80), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3400, -130), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3800, -10), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(4200, -44), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(4600, -80), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(5000, -130), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(5400, -10), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(5800, -10), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(6200, -44), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(6600, -80), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(7000, -130), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(7400, -10), vec2(64, 256), vec4(0, 1, 1, 0)),

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
			RectangleShape.create(pipe, vec2(5800, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(6200, WindowHeight - 164), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(6600, WindowHeight - 200), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(7000, WindowHeight - 250), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(7400, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
		];
		//dfmt on
	}

	override void start(int difficulty) {
		super.start(difficulty);
		x = 200;
		y = 200;
		xv = 1 + difficulty * 0.5f;
		yv = 0.002f;
		t = 0;
		_won = true;
	}

	override void stop() {
	}

	override void update() {
		t += _game.delta;
		if(t <= 0.001666f)
			return;
		t -= 0.001666f;
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
		_game.indicatorA.position = vec2(470, y);
		_game.target.draw(_game.indicatorA);
		_game.indicatorB.position = vec2(380, y - 64);
		_game.target.draw(_game.indicatorB);
	
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
	float x, y, t;
	float xv, yv;
}
