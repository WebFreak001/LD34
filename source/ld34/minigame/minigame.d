module ld34.minigame.minigame;

import ld34.ld34;
import core.time;

abstract class Minigame {
public:
	this(LD34 game) {
		this._game = game;
	}

	abstract void start() {
		_done = false;
		_won = false;
	}

	abstract void stop();

	abstract void update();
	abstract void draw();

	@property abstract Duration getPlayTime() const;

	@property bool isDone() const {
		return _done;
	}

	@property bool hasWon() const {
		return _won;
	}

protected:
	LD34 _game;
	bool _done;
	bool _won;
}