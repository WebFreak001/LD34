module ld34.minigame.dance;

import d2d;
import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;
import std.random;

final class Dance : Minigame {
public:
	this(LD34 game) {
		super(game);
		spritesheet = new Texture("res/tex/dance/dancers.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		int div = _game.target.width / 4;
		//dfmt off
		_guys[0] = Guy(RectangleShape.create(
			spritesheet,
			vec2(div*0 + 64*1, _game.target.height-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0, 0.25, 0.25)
		), 0);
		_guys[1] = Guy(RectangleShape.create(
			spritesheet,
			vec2(div*1 + 64*1, _game.target.height-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0.25, 0.25, 0.5)
		), 0);
		_guys[2] = Guy(RectangleShape.create(
			spritesheet,
			vec2(div*2 + 64*1, _game.target.height-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0.5, 0.25, 0.75)
		), 0);
		_guys[3] = Guy(RectangleShape.create(
			spritesheet,
			vec2(div*3 + 64*1, _game.target.height-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0.75, 0.25, 1)
		), 0);
		//dfmt on

		_shader = ShaderProgram.fromVertexFragmentFiles("res/shader/base.vert", "res/shader/texoffset.frag");
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
		writeln(__PRETTY_FUNCTION__);
	}

	override void stop() {
		writeln(__PRETTY_FUNCTION__);
	}

	override void update() {
		_t += _game.delta;

		if (_key == Key.A) {
			if (_game.isButtonADown && !_game.isButtonBDown)
				_guys[_selected].counter += _game.delta;
		} else if (_key == Key.B) {
			if (!_game.isButtonADown && _game.isButtonBDown)
				_guys[_selected].counter += _game.delta;
		} else if (_key == Key.AB) {
			if (_game.isButtonADown && _game.isButtonBDown)
				_guys[_selected].counter += _game.delta;
		} else if (_key == Key.NONE) {
			if (!_game.isButtonADown && !_game.isButtonBDown)
				_guys[_selected].counter += _game.delta;
		}

		int oldSelect = _selected;
		_selected = cast(int)(_t * 1.25) % 4;
		if (oldSelect != _selected) {
			_key = uniform!Key();
		}

		if (_t >= 10) {
			float counter = 0;
			foreach (guy; _guys)
				counter += guy.counter;

			_done = true;
			_won = counter > 5;
		}
	}

	override void draw() {
		foreach (idx, guy; _guys) {
			_shader.bind();

			vec2 _texOffset;
			int frame = cast(int)(_guys[idx].counter * 10) % 6;
			if (frame == 0)
				_texOffset = vec2(0, 0);
			else if (frame == 1)
				_texOffset = vec2(0.25, 0);
			else if (frame == 2)
				_texOffset = vec2(0.50, 0);
			else if (frame == 3)
				_texOffset = vec2(0.75, 0);
			else if (frame == 4)
				_texOffset = vec2(0.50, 0);
			else if (frame == 5)
				_texOffset = vec2(0.25, 0);

			_shader.set("texOffset", _texOffset);
			if (_selected == idx)
				_shader.set("color", vec3(1, 1, 1));
			else
				_shader.set("color", vec3(0.15, 0.15, 0.15));
			_game.target.draw(_guys[idx].tex, _shader);
		}

		ShaderProgram.defaultShader.bind();

		if (_key == Key.A) {
			_game.indicatorA.position = _guys[_selected].tex.position + vec2(
				_guys[_selected].tex.size.x / 2 - 24, -50);
			_game.target.draw(_game.indicatorA);
		} else if (_key == Key.B) {
			_game.indicatorB.position = _guys[_selected].tex.position + vec2(
				_guys[_selected].tex.size.x / 2 - 24, -50);
			_game.target.draw(_game.indicatorB);
		} else if (_key == Key.AB) {
			_game.indicatorA.position = _guys[_selected].tex.position + vec2(
				_guys[_selected].tex.size.x / 2 - 24 - 26, -50);
			_game.target.draw(_game.indicatorA);

			_game.indicatorB.position = _guys[_selected].tex.position + vec2(
				_guys[_selected].tex.size.x / 2 - 24 + 26, -50);
			_game.target.draw(_game.indicatorB);
		}
	}

	@property override Duration getPlayTime() const {
		return 10.seconds;
	}

private:
	enum Key {
		A,
		B,
		AB,
		NONE
	}

	struct Guy {
		RectangleShape tex;
		float counter;
	}

	Texture spritesheet;
	ShaderProgram _shader;
	Guy[4] _guys;
	int _selected;
	Key _key;

	float _t;
}
