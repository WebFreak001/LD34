module ld34.minigame.floppyavoid;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.algorithm;
import std.random;
import std.stdio;
import d2d;

final class FloppyAvoid : Minigame {
public:
	this(LD34 game) {
		super(game);

		_ballTex = new Texture("res/tex/floppy/ball.png");
		_floppyTex = new Texture("res/tex/floppy/floppy.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);

		_ball = RectangleShape.create(_ballTex, vec2(), vec2(64, 64));
	}

	override void start(int difficulty) {
		super.start(difficulty);
		_floppies.length = 0;
		_spawns.length = 0;
		_won = true;
		ballX = 640;
		time = 0;
		for (int i = 0; i < max(2, min(10, difficulty * 2)); i++) {
			_spawns ~= uniform(0.0f, 3.0f);
		}
	}

	override void stop() {
		_floppies.length = 0;
		_spawns.length = 0;
	}

	override void update() {
		time += _game.delta;
		foreach_reverse (i, spawn; _spawns) {
			if (time >= spawn) {
				_spawns = _spawns.remove(i);
				if (uniform(0, 2) == 0) {
					_floppies ~= Floppy(RectangleShape.create(_floppyTex, vec2(),
						vec2(64, 64), vec4(0, 0, 0.25f, 1)), uniform(450, 830), -32, false);
				} else {
					_floppies ~= Floppy(RectangleShape.create(_floppyTex, vec2(),
						vec2(64, 64), vec4(0, 0, 0.25f, 1)), uniform(450, 830), 752, true);
				}
			}
		}
		if(_game.isButtonADown)
			ballX -= _game.delta * 200;
		if(_game.isButtonBDown)
			ballX += _game.delta * 200;
		ballX = min(max(ballX, 450), 830);
		foreach (ref floppy; _floppies)
			with (floppy) {
				if(invert)
					y -= _game.delta * 400;
				else
					y += _game.delta * 400;
				if (vec2(ballX - x, ballY - y).length_squared() < 64 * 64) {
					_done = true;
					_won = false;
				}
			}
	}

	override void draw() {
		foreach (ref floppy; _floppies)
			with (floppy) {
				shape.position = vec2(x - 32, y - 32);
				_game.target.draw(shape);
			}
		_ball.position = vec2(ballX - 32, ballY - 32);
		_game.target.draw(_ball);
		
		_game.indicatorA.position = vec2(ballX - 32 - 48, ballY - 24);
		_game.target.draw(_game.indicatorA);
		
		_game.indicatorB.position = vec2(ballX + 32, ballY - 24);
		_game.target.draw(_game.indicatorB);
	}

	@property override Duration getPlayTime() const {
		return 5.seconds;
	}

private:
	struct Floppy {
		RectangleShape shape;
		float x, y;
		bool invert;
	}

	float time = 0;
	float ballX = 640;
	enum ballY = 360;
	RectangleShape _ball;
	Floppy[] _floppies;
	float[] _spawns;
	Texture _ballTex, _floppyTex;
}
