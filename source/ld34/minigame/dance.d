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
		_spritesheet = new Texture("res/tex/dance/dancers.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		int div = WindowWidth / 4;
		//dfmt off
		_guys[0] = Guy(RectangleShape.create(
			_spritesheet,
			vec2(div*0 + 64*1, WindowHeight-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0, 0.25, 0.25)
		), 0);
		_guys[1] = Guy(RectangleShape.create(
			_spritesheet,
			vec2(div*1 + 64*1, WindowHeight-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0.25, 0.25, 0.5)
		), 0);
		_guys[2] = Guy(RectangleShape.create(
			_spritesheet,
			vec2(div*2 + 64*1, WindowHeight-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0.5, 0.25, 0.75)
		), 0);
		_guys[3] = Guy(RectangleShape.create(
			_spritesheet,
			vec2(div*3 + 64*1, WindowHeight-64*4),
			vec2(64*4, 64*4),
			vec4(0, 0.75, 0.25, 1)
		), 0);

		_bg = RectangleShape.create(
			vec2(0, 0),
			vec2(WindowWidth, WindowHeight)
		);
		//dfmt on

		_bgShader = ShaderProgram.fromVertexFragmentFiles("res/shader/background.vert",
			"res/shader/background.frag");
		_bgShader.bind();
		_bgShader.registerUniform("transform");
		_bgShader.registerUniform("projection");
		_bgShader.registerUniform("offset");
	}

	override void start(int difficulty) {
		super.start(difficulty);
		_t = 0;
	}

	override void stop() {
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

		float counter = 0;
		foreach (guy; _guys)
			counter += guy.counter;
		_won = counter > 4;
	}

	override void draw() {
		_bgShader.bind();
		_bgShader.set("offset", vec2(_t * 30, _t * 100));
		_game.target.draw(_bg, _bgShader);

		foreach (idx, guy; _guys) {
			_game.textureOffsetShader.bind();

			vec2 texOffset;
			int frame = cast(int)(_guys[idx].counter * 10) % 6;
			if (frame == 0)
				texOffset = vec2(0, 0);
			else if (frame == 1)
				texOffset = vec2(0.25, 0);
			else if (frame == 2)
				texOffset = vec2(0.50, 0);
			else if (frame == 3)
				texOffset = vec2(0.75, 0);
			else if (frame == 4)
				texOffset = vec2(0.50, 0);
			else if (frame == 5)
				texOffset = vec2(0.25, 0);

			_game.textureOffsetShader.set("texOffset", texOffset);
			if (_selected == idx)
				_game.textureOffsetShader.set("color", vec3(1, 1, 1));
			else
				_game.textureOffsetShader.set("color", vec3(0.5, 0.5, 0.5));
			_game.target.draw(_guys[idx].tex, _game.textureOffsetShader);
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

	Texture _spritesheet;
	ShaderProgram _bgShader;
	RectangleShape _bg;
	Guy[4] _guys;
	int _selected;
	Key _key;

	float _t;
}
