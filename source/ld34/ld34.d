module ld34.ld34;

import d2d;
import std.algorithm;
import std.stdio;

import ld34.minigame.minigame;

class LD34 : Game {
public:
	override void start() {
		windowWidth = 1280;
		windowHeight = 720;
		windowTitle = "LD34 Growing madness!";
		maxFPS = 0;
		flags |= WindowFlags.Resizable;
		_buttonA = SDLK_LEFT;
		_buttonB = SDLK_RIGHT;
	}

	override void load() {
		registerMinigame();
		currentMinigame = _minigames[0];
	}

	override void update(float delta) {
		_delta = delta;
		_currentMinigame.update();

		if (_currentMinigame.isDone) {
			writeln("isWon: ", _currentMinigame.hasWon);
			currentMinigame = _minigames[0];
		}
	}

	override void onEvent(Event event) {
		switch (event.type) {
		case Event.Type.Resized:
			window.resize(event.width, event.height);
			writefln("New Size: %sx%s", event.width, event.height);
			break;
		case Event.Type.KeyPressed:
			if (event.key == _buttonA)
				_buttonADown = true;
			else if (event.key == _buttonB)
				_buttonBDown = true;
			break;
		case Event.Type.KeyReleased:
			if (event.key == _buttonA)
				_buttonADown = false;
			else if (event.key == _buttonB)
				_buttonBDown = false;
			break;
		default:
			break;
		}
	}

	override void draw() {
		window.clear(Color3.SkyBlue);
		_currentMinigame.draw();
	}

	@property float delta() const {
		return _delta;
	}

	@property bool isButtonADown() const {
		return _buttonADown;
	}

	@property bool isButtonBDown() const {
		return _buttonBDown;
	}

	@property Minigame currentMinigame() {
		return _currentMinigame;
	}

	@property Minigame currentMinigame(Minigame minigame) {
		if (_currentMinigame)
			_currentMinigame.stop();

		_currentMinigame = minigame;

		game++;

		if (_currentMinigame)
			_currentMinigame.start(game / 5);
		return _currentMinigame;
	}

private:
	float _delta;
	int _buttonA;
	int _buttonB;
	bool _buttonADown;
	bool _buttonBDown;
	Minigame[] _minigames;
	Minigame _currentMinigame;
	int game = 0;

	void registerMinigame() {
		import ld34.minigame.testgame : TestGame;

		_minigames ~= new TestGame(this);
	}
}
