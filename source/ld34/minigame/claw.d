module ld34.minigame.claw;

import d2d;
import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;
import std.math;
import std.algorithm;
import std.random;

final class Claw : Minigame {
public:
	this(LD34 game) {
		super(game);
		_spritesheet = new Texture("res/tex/claw/parts.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);

		//dfmt off
		_stick = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4*2),
			vec4(0, 0, 0.25, 0.25)
		);

		_bar = RectangleShape.create(
			_spritesheet,
			vec2(0, 4),
			vec2(64*4*100, 64*4),
			vec4(0.25, 0, 0.5, 0.25)
		);

		_connector = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0.5, 0, 0.75, 0.25)
		);

		_claw = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0, 0.25, 0.25, 0.5)
		);

		_face[TargetBox.Red] = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0, 0.5, 0.25, 0.75)
		);
		_face[TargetBox.Green] = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0.25, 0.5, 0.5, 0.75)
		);
		_face[TargetBox.Pink] = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0.5, 0.5, 0.75, 0.75)
		);

		_box[TargetBox.Red] = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0, 0.75, 0.25, 1)
		);
		_box[TargetBox.Green] = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0.25, 0.75, 0.5, 1)
		);
		_box[TargetBox.Pink] = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(64*4, 64*4),
			vec4(0.5, 0.75, 0.75, 1)
		);

		_floor = RectangleShape.create(
			_spritesheet,
			vec2(0, WindowHeight-64*4),
			vec2(64*4*10, 64*4),
			vec4(0.75, 0, 1, 0.25)
		);

		_putBox = RectangleShape.create(
			_spritesheet,
			vec2(0, 0),
			vec2(22*4, 9*4),
			vec4(0.75, 0.25, 1, 0.5)
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
		_clawTexOffset = vec2(0, 0);
		_pos = vec2(WindowWidth / 2 - 64 * 2, 0);
		_state = ClawState.GoingDown;
		_target = uniform!TargetBox();
		_putBoxOnLeft = !!dice(0.5, 0.5);
		_putBox.position = vec2(_putBoxOnLeft ? 0 : (WindowWidth - 22 * 4),
			WindowHeight - (9 + 2) * 4);
		foreach (box; _box)
			box.position = vec2(uniform(_putBoxOnLeft ? 32 * 4 : 0,
				WindowWidth - 64 * 4) - (_putBoxOnLeft ? 0 : 32 * 4),
				WindowHeight - 64 * 4);
		_gotBox = false;
	}

	override void stop() {
	}

	override void update() {
		_t += _game.delta;

		if (_state == ClawState.GoingDown) {
			if (_game.isButtonADown)
				_pos.x -= _game.delta * 600;
			else if (_game.isButtonBDown)
				_pos.x += _game.delta * 600;

			_pos.y += _game.delta * 300;
			_pos.y = min(_pos.y, WindowHeight - _claw.size.y);
			if (_pos.y == WindowHeight - _claw.size.y) {
				_state = ClawState.Grabing;
				_t = 0;
			}
		} else if (_state == ClawState.Grabing) {
			int frame = cast(int)(_t * 4) % 3;
			if (frame == 0)
				_clawTexOffset = vec2(0, 0);
			else if (frame == 1)
				_clawTexOffset = vec2(0.25, 0);
			else if (frame == 2) {
				_clawTexOffset = vec2(0.50, 0);

				if (std.math.abs(_pos.x - _box[_target].position.x) < 16)
					_gotBox = true;

				_state = ClawState.GoingUp;
			}
		} else if (_state == ClawState.GoingUp) {
			if (_game.isButtonADown)
				_pos.x -= _game.delta * 650;
			else if (_game.isButtonBDown)
				_pos.x += _game.delta * 650;

			_pos.y -= _game.delta * 250;
			_pos.y = max(_pos.y, 4);

			if (_gotBox)
				_box[_target].position = _pos;

			if (_pos.y == 4) {
				_state = ClawState.Dropping;
				_t = 0;
			}
		} else if (_state == ClawState.Dropping) {
			int frame = cast(int)(_t * 4) % 3;
			if (frame == 0)
				_clawTexOffset = vec2(0.50, 0);
			else if (frame == 1)
				_clawTexOffset = vec2(0.25, 0);
			else if (frame == 2) {
				_clawTexOffset = vec2(0, 0);
				_state = ClawState.BoxFalling;
			}
		} else if (_state == ClawState.BoxFalling) {
			if (!_gotBox) {
				_done = true;
				_won = false;
			} else {
				_box[_target].position = _box[_target].position + vec2(0, _game.delta * 300);
				_box[_target].position = vec2(_box[_target].position.x,
					min(_box[_target].position.y, WindowHeight - _claw.size.y));
				if (_box[_target].position.y == WindowHeight - _claw.size.y) {
					_done = true;
					if (_putBoxOnLeft) {
						_won = _box[_target].position.x + _box[_target].size.x / 2 < _putBox.size.x;
					} else {
						_won = _box[_target].position.x + _box[_target].size.x / 2 > _putBox.position.x;
					}
				}
			}
		}
	}

	override void draw() {
		_shader.bind();
		_shader.set("texOffset", _clawTexOffset);

		foreach (box; _box)
			_game.target.draw(box);

		_stick.position = _pos - vec2(0, _stick.size.y);
		_game.target.draw(_stick);

		_game.target.draw(_floor);
		_game.target.draw(_putBox);

		_claw.position = _pos;
		_game.target.draw(_claw, _shader);
		_face[_target].position = _pos;
		_game.target.draw(_face[_target]);

		_game.target.draw(_bar);
		_connector.position = vec2(_pos.x, 4);
		_game.target.draw(_connector);

		if (_state == ClawState.GoingDown || _state == ClawState.GoingUp) {
			_game.indicatorA.position = _pos + vec2(16, _claw.size.y / 3 * 2);
			_game.target.draw(_game.indicatorA);
			_game.indicatorB.position = _pos + vec2(_claw.size.x - 16 * 4, _claw.size.y / 3 * 2);
			_game.target.draw(_game.indicatorB);
		}
	}

	@property override Duration getPlayTime() const {
		return 7.seconds;
	}

private:
	enum TargetBox : int {
		Green,
		Red,
		Pink
	}

	enum ClawState {
		GoingDown,
		Grabing,
		GoingUp,
		Dropping,
		BoxFalling
	}

	Texture _spritesheet;
	ShaderProgram _shader;
	float _t = 0;
	vec2 _clawTexOffset;
	vec2 _pos;
	ClawState _state;
	TargetBox _target;

	RectangleShape _stick;
	RectangleShape _bar;
	RectangleShape _connector;
	RectangleShape _claw;
	RectangleShape[TargetBox] _face;
	RectangleShape[TargetBox] _box;

	RectangleShape _floor;
	RectangleShape _putBox;
	bool _putBoxOnLeft;
	bool _gotBox;
}
