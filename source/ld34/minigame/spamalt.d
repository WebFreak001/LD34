module ld34.minigame.spamalt;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;

final class SpamAlternating : Minigame {
public:
	this(LD34 game) {
		super(game);
	}

	override void start(int difficulty) {
		super.start(difficulty);
		t = 0;
		writeln(__PRETTY_FUNCTION__);
	}

	override void stop() {
		writeln(__PRETTY_FUNCTION__);
	}

	override void update() {
		t += _game.delta;
		if (t >= 1) {
			_done = true;
			_won = true;
		}
	}

	override void draw() {
	}

	@property override Duration getPlayTime() const {
		return 5.seconds;
	}

private:
	float t;
}
