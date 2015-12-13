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
			RectangleShape.create(pipe, vec2(1600, -10), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(2000, -64), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(2400, -100), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(2800, -150), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3200, -30), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(3600, -64), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(4000, -100), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(4400, -150), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(4800, -30), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(5200, -64), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(5600, -100), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(6000, -150), vec2(64, 256), vec4(0, 1, 1, 0)),
			RectangleShape.create(pipe, vec2(6400, -30), vec2(64, 256), vec4(0, 1, 1, 0)),
			
			RectangleShape.create(pipe, vec2(1600, WindowHeight - 110), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(2000, WindowHeight - 164), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(2400, WindowHeight - 200), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(2800, WindowHeight - 250), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(3200, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(3600, WindowHeight - 164), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(4000, WindowHeight - 200), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(4400, WindowHeight - 250), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(4800, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(5200, WindowHeight - 164), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(5600, WindowHeight - 200), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(6000, WindowHeight - 250), vec2(64, 256), vec4(0, 0, 1, 1)),
			RectangleShape.create(pipe, vec2(6400, WindowHeight - 130), vec2(64, 256), vec4(0, 0, 1, 1)),
		];
		//dfmt on
	}

	override void start(int difficulty) {
		super.start(difficulty);
		x = 200;
		y = 200;
		xv = 1;
		yv = 0.2f;
		_won = true;
	}

	override void stop() {
	}

	override void update() {
		if (_game.isButtonADown)
			xv += _game.delta * 0.1f;
		if (_game.isButtonBDown)
			yv += _game.delta * 2;
		y -= yv;
		yv -= _game.delta;
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
