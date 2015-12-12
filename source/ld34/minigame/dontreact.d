module ld34.minigame.dontreact;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;
import std.random;
import d2d;

final class DontReact : Minigame {
public:
	this(LD34 game) {
		super(game);
		//dfmt off
		foreach (str; [
			"Leave the button",
			"Don't press the button",
			"Look at the button",
			"Feel the buttons presence",
			"Leave the button in an unpressed state",
			"Press any other button except this one"
		]) {
			auto text = new TTFText(_game.font);
			text.text = str;
			text.position = vec2(640 - _game.font.measureText(str).x / 2, 150);
			texts ~= text;
			button = RectangleShape.create(new Texture("res/tex/button/button.png", TextureFilterMode.Nearest, TextureFilterMode.Nearest), vec2(), vec2(512, 512));
		}
		//dfmt on
	}

	override void start(int difficulty) {
		super.start(difficulty);
		selected = uniform(0, texts.length);
		t = 0;
		_won = true;
	}

	override void stop() {
		_game.indicatorA.pressed = _game.isButtonADown;
		_game.indicatorB.pressed = _game.isButtonBDown;
	}

	override void update() {
		t += _game.delta;
		_game.indicatorA.pressed = (cast(int)(t * 5) % 2 == 0);
		_game.indicatorB.pressed = (cast(int)(t * 5) % 2 == 1);
		if (_game.isButtonADown || _game.isButtonBDown) {
			_done = true;
			_won = false;
		}
	}

	override void draw() {
		button.position = vec2((1280 - 512) * 0.5f, 150);
		_game.target.draw(button);
		_game.target.draw(texts[selected]);
		_game.indicatorA.position = vec2(590 - 24, 400);
		_game.target.draw(_game.indicatorA);
		_game.indicatorB.position = vec2(690 - 24, 400);
		_game.target.draw(_game.indicatorB);
	}

	@property override Duration getPlayTime() const {
		return 3.seconds;
	}

private:
	RectangleShape button;
	TTFText[] texts;
	size_t selected = 0;
	float t;
}
