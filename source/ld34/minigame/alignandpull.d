module ld34.minigame.alignandpull;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;
import std.random;
import d2d;

final class AlignAndPull : Minigame {
public:
	this(LD34 game) {
		super(game);

		auto tex = new Texture("res/tex/cucumber/graphics.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		finger = RectangleShape.create(tex, vec2(), vec2(128, 128), vec4(0, 0, 0.5,
			0.5));
		jar = RectangleShape.create(tex, vec2(), vec2(128, 128), vec4(0, 0.5, 0.5,
			1));
		cucumber = RectangleShape.create(tex, vec2(), vec2(128, 128), vec4(0.5, 0.5,
			1, 1));
	}

	override void start(int difficulty) {
		super.start(difficulty);
		aDown = false;
		bDown = false;
		isDecending = false;
		isPulling = false;
		needA = false;
		strength = 0;
		x = 0;
		y = 200;
		jarX = uniform(-400, 400);
		cucumberX = jarX;
		cucumberY = 0;
		if (_difficulty < 1)
			_difficulty = 1;
		if (_difficulty > 2)
			_difficulty = 2;
			
		if(_difficulty == 2) {
			cucumber.texCoords = vec4(0.5, 0, 1, 0.5);
			cucumber.create();
		} else {
			cucumber.texCoords = vec4(0.5, 0.5, 1, 1);
			cucumber.create();
		}
	}

	override void stop() {
	}

	override void update() {
		strength -= _game.delta;
		if (_game.isButtonADown && !aDown)
			x -= 8 / _difficulty;
		if (_game.isButtonBDown && !bDown)
			x += 8 / _difficulty;
		if (_game.isButtonADown && _game.isButtonBDown && !isDecending && !isPulling && y > 199)
			isDecending = true;

		if (!isDecending && y < 200 && !isPulling)
			y += 40 * _game.delta;
		if (!isDecending && y < 200 && isPulling)
			y += 15 * _game.delta;
		if (isDecending && y > 0)
			y -= 40 * _game.delta;
		if (isDecending && y <= 0) {
			isDecending = false;
			if (cucumberX > x - 24 && cucumberX < x + 24 && cucumberY < 1) {
				isPulling = true;
				strength = 1;
			}
		}

		if (isPulling) {
			if (_game.isButtonADown && !aDown && needA) {
				needA = !needA;
				strength += 0.2f / _difficulty;
			}
			if (_game.isButtonBDown && !bDown && !needA) {
				needA = !needA;
				strength += 0.2f / _difficulty;
			}
			strength = min(strength, 1);
			cucumberX = x;
			cucumberY = y;
			if (strength < 0) {
				isPulling = false;
			}
		} else {
			cucumberY = max(cucumberY - _game.delta * 40, 0);
		}

		if (cucumberY > 199) {
			_done = true;
			_won = true;
		}

		aDown = _game.isButtonADown;
		bDown = _game.isButtonBDown;
	}

	override void draw() {
		if (!isPulling && !isDecending) {
			if (x > cucumberX + 24) {
				_game.indicatorA.position = vec2(x - 50 + WindowWidth / 2, y);
				_game.target.draw(_game.indicatorA);
			} else if (x < cucumberX - 24) {
				_game.indicatorB.position = vec2(x + 100 + WindowWidth / 2, y);
				_game.target.draw(_game.indicatorB);
			} else if (cucumberX > x - 24 && cucumberX < x + 24) {
				_game.indicatorA.position = vec2(x + WindowWidth / 2, y + 64);
				_game.target.draw(_game.indicatorA);
				_game.indicatorB.position = vec2(x + 50 + WindowWidth / 2, y + 64);
				_game.target.draw(_game.indicatorB);
			}
		}
		if (isPulling) {
			if (needA) {
				_game.indicatorA.position = vec2(x - 50 + WindowWidth / 2, -y + WindowHeight / 2);
				_game.target.draw(_game.indicatorA);
			} else {
				_game.indicatorB.position = vec2(x + 100 + WindowWidth / 2, -y + WindowHeight / 2);
				_game.target.draw(_game.indicatorB);
			}
		}

		finger.position = vec2(x + WindowWidth / 2, -y + WindowHeight / 2);
		_game.target.draw(finger);

		cucumber.position = vec2(cucumberX + WindowWidth / 2, -cucumberY + WindowHeight / 2);
		_game.target.draw(cucumber);

		jar.position = vec2(jarX + WindowWidth / 2, WindowHeight / 2 + 8);
		_game.target.draw(jar);
	}

	@property override Duration getPlayTime() const {
		return 30.seconds;
	}

private:
	bool aDown, bDown, isDecending, isPulling, needA;
	float x = 0, y = 0, jarX = 0, cucumberX = 0, cucumberY = 0, strength = 0;
	RectangleShape finger, jar, cucumber;
}
