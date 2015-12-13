module ld34.minigame.climb;

import d2d;
import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;

final class Climb : Minigame {
public:
	this(LD34 game) {
		super(game);
		_spritesheet = new Texture("res/tex/climb/sprites.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		//dfmt off
		_ladder = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64 * 4, 64 * 4),
			vec4(0, 0, 0.25, 0.25)
		);

		_guy = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0, 0.25, 0.25, 0.5)
		);
		//dfmt on

		_shader = ShaderProgram.fromVertexFragmentFiles("res/shader/base.vert",
			"res/shader/texoffset.frag");
		_shader.bind();
		_shader.registerUniform("tex");
		_shader.registerUniform("color");
		_shader.registerUniform("transform");
		_shader.registerUniform("projection");
		_shader.registerUniform("texOffset");
		_shader.set("tex", 0);
		_shader.set("color", vec3(1, 1, 1));
	}

	override void start(int difficulty) {
		super.start(difficulty);
		_t = 0;
		_done = false;
		_won = false;
		_guy.position = vec2(64 * 4 * 2, 64 * 4);
		_accel = vec2(0, 0);
		_isA = 0;
	}

	override void stop() {
	}

	override void update() {
		_isA += _game.delta;
		if (cast(int)(_isA * 2) % 2 == 0) {
			if (_game.isButtonADown && !_game.isButtonBDown) {
				_t += _game.delta;
				_accel = _accel - vec2(0, _game.delta * 200);
			} else
				_accel = _accel + vec2(0, _game.delta * 30);
		} else {
			if (_game.isButtonBDown && !_game.isButtonADown) {
				_t += _game.delta;
				_accel = _accel - vec2(0, _game.delta * 200);
			} else
				_accel = _accel + vec2(0, _game.delta * 30);
		}

		_guy.position = _guy.position + _accel * _game.delta;

		if (_guy.position.y < -_guy.size.y) {
			_done = true;
			_won = true;
		} else if (_guy.position.y > WindowHeight) {
			_done = true;
			_won = false;
		}
	}

	override void draw() {
		for (int y = 0; y < 4; y++) {
			_ladder.position = vec2(64 * 4 * 2, 64 * 4 * y);
			_game.target.draw(_ladder);
		}

		vec2 texOffset;
		int frame = cast(int)(_t * 10) % 5;
		if (frame == 0)
			texOffset = vec2(0, 0);
		else if (frame == 1)
			texOffset = vec2(0.25, 0);
		else if (frame == 2)
			texOffset = vec2(0.50, 0);
		else if (frame == 3)
			texOffset = vec2(0.75, 0);
		else if (frame == 4)
			texOffset = vec2(0, 0.25);

		_shader.bind();
		_shader.set("texOffset", texOffset);
		_game.target.draw(_guy, _shader);
		if (cast(int)(_isA) % 2 == 0) {
			_game.indicatorA.position = _guy.position + vec2(0, 0);
			_game.target.draw(_game.indicatorA);
		} else {
			_game.indicatorB.position = _guy.position + vec2(0, 0);
			_game.target.draw(_game.indicatorB);
		}
	}

	@property override Duration getPlayTime() const {
		return 10.seconds;
	}

private:
	float _t;
	Texture _spritesheet;
	ShaderProgram _shader;
	RectangleShape _ladder;
	RectangleShape _guy;
	float _isA;
	vec2 _accel;
}
