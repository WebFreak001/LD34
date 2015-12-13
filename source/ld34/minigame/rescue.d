module ld34.minigame.rescue;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.random;
import std.stdio;
import std.algorithm;
import d2d;

final class Rescue : Minigame {
public:
	this(LD34 game) {
		super(game);

		_heroTex = new Texture("res/tex/rescue/running.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		_spikeTex = new Texture("res/tex/rescue/spike.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		_deadTex = new Texture("res/tex/rescue/dead.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		auto _winTex = new Texture("res/tex/rescue/end.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);

		_hero = RectangleShape.create(_heroTex, vec2(), vec2(64, 64), vec4(0, 0, 0.5f, 1));
		_win = RectangleShape.create(_winTex, vec2(), vec2(512, 512));
	}

	override void start(int difficulty) {
		super.start(difficulty);
		_spikes.length = 0;
		_spawns.length = 0;
		_won = false;
		heroX = 640;
		time = 0;
		for (int i = 0; i < max(2, min(10, difficulty * 2)); i++) {
			_spawns ~= uniform(0.0f, 3.0f);
		}
		_spawns ~= 4 - min(0.4f, difficulty * 0.1f);
		_dead = false;
		_animation = false;
		_animationTime = 0;
	}

	override void stop() {
		_spikes.length = 0;
		_spawns.length = 0;
	}

	override void update() {
		time += _game.delta;
		if(_animation)
			_animationTime += _game.delta;
		if(_animationTime > 2)
			_done = true;
		foreach_reverse (i, spawn; _spawns) {
			if (time >= spawn && time < 3.5f) {
				_spawns = _spawns.remove(i);
				_spikes ~= Spike(RectangleShape.create(_spikeTex,
					vec2(), vec2(64, 64)), uniform(450, 830),
					-32);
			}
			if (time >= spawn && time > 3.5f) {
				_spawns = _spawns.remove(i);
				_spikes ~= Spike(RectangleShape.create(_deadTex,
					vec2(), vec2(64, 32)), uniform(450, 830),
					-32, true);
			}
		}
		if (_game.isButtonADown)
			heroX -= _game.delta * 200;
		if (_game.isButtonBDown)
			heroX += _game.delta * 200;
		heroX = min(max(heroX, 450), 830);
		foreach (ref spike; _spikes)
			with (spike) {
				y += _game.delta * 400;
				float radius = 64;
				if (vec2(heroX - x, heroY - y).length_squared() < radius * radius) {
					if(spike.wins) {
						_animation = true;
						_won = true;
					} else {
						_won = false;
						_dead = true;
						_done = true;
					}
				}
			}
	}

	override void draw() {
		if(_animation) {
			_win.position = vec2(_animationTime * WindowWidth * 0.5f, WindowHeight * 0.5f - _animationTime * WindowHeight * 0.5f);
			_game.target.draw(_win);
		} else {
			foreach (ref spike; _spikes)
				with (spike) {
					shape.position = vec2(x - 32, y - 32);
					_game.target.draw(shape);
				}
				
			if(_dead)
				_hero.texture = _deadTex;
			else
				_hero.texture = _heroTex;
			_hero.position = vec2(heroX - 32, heroY - 32);
			_game.textureOffsetShader.bind();
			_game.textureOffsetShader.set("texOffset", vec2((cast(int)(time * 4) % 2) == 0 ? 0 : 0.5f, 0));
			_game.target.draw(_hero, _game.textureOffsetShader);
	
			_game.indicatorA.position = vec2(heroX - 32 - 48, heroY - 24);
			_game.target.draw(_game.indicatorA);
	
			_game.indicatorB.position = vec2(heroX + 32, heroY - 24);
			_game.target.draw(_game.indicatorB);
		}
	}

	@property override Duration getPlayTime() const {
		return 6.seconds;
	}

private:
	struct Spike {
		RectangleShape shape;
		float x, y;
		bool wins = false;
	}

	float time = 0, _animationTime = 0;
	float heroX = 640;
	enum heroY = 360;
	bool _dead = false, _animation = false;
	RectangleShape _hero, _win;
	Spike[] _spikes;
	float[] _spawns;
	Texture _heroTex, _spikeTex, _deadTex;
}
