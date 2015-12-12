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
		spritesheet = new Texture("res/tex/dance/dancers.png", TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		int div = _game.target.width/4;
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

		_shader = new ShaderProgram();
		Shader vertex = new Shader();
		vertex.load(ShaderType.Vertex, "#version 330
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_tex;
uniform mat4 transform;
uniform mat4 projection;
out vec2 texCoord;
void main()
{
	gl_Position = projection * transform * vec4(in_position, 1);
	texCoord = in_tex;
}
");
		Shader fragment = new Shader();
		fragment.load(ShaderType.Fragment, "#version 330
uniform sampler2D tex;
uniform vec3 color;
uniform vec2 texOffset;
in vec2 texCoord;
layout(location = 0) out vec4 out_frag_color;
void main()
{
	out_frag_color = texture(tex, (texCoord+texOffset)) * vec4(color, 1);
}
");
		_shader.attach(vertex);
		_shader.attach(fragment);
		_shader.link();
		_shader.bind();
		_shader.registerUniform("tex");
		_shader.registerUniform("color");
		_shader.registerUniform("transform");
		_shader.registerUniform("projection");
		_shader.registerUniform("texOffset");
		_shader.set("tex", 0);
		_shader.set("color", vec3(1, 1, 1));

		_font = new TTFFont();
		_font.load("res/font/Roboto-Regular.ttf", 64);
		_a = new TTFText(_font);
		_a.text = "A";
		_aSize = _font.measureText(_a.text);
		_b = new TTFText(_font);
		_b.text = "B";
		_bSize = _font.measureText(_b.text);
		_ab = new TTFText(_font);
		_ab.text = "A+B";
		_abSize = _font.measureText(_ab.text);
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
		_selected = cast(int)(_t*1.25) % 4;
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
			int frame = cast(int)(_guys[idx].counter*10) % 6;
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
			_a.position = _guys[_selected].tex.position + vec2(_guys[_selected].tex.size.x/2 - _aSize.x/2, -_aSize.y);
			_game.target.draw(_a);
		} else if (_key == Key.B) {
			_b.position = _guys[_selected].tex.position + vec2(_guys[_selected].tex.size.x/2 - _bSize.x/2, -_bSize.y);
			_game.target.draw(_b);
		} else if (_key == Key.AB) {
			_ab.position = _guys[_selected].tex.position + vec2(_guys[_selected].tex.size.x/2 - _abSize.x/2, -_abSize.y);
			_game.target.draw(_ab);
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

	TTFFont _font;
	TTFText _a;
	vec2 _aSize;
	TTFText _b;
	vec2 _bSize;
	TTFText _ab;
	vec2 _abSize;
	float _t;
}