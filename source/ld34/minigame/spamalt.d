module ld34.minigame.spamalt;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.random;
import std.stdio;
import d2d;

final class SpamAlternating : Minigame {
public:
	this(LD34 game) {
		super(game);
		//dfmt off
		foreach(txt; [
			"lol",
			"you suck at this",
			"git gud",
			"Kappa",
			"RIP",
			":O",
			"NOOB",
			"REKT",
			"MLG",
			"HAHAHAHAHAHAA!!!!111",
			"Go buy some drugs: <deleted link>",
			"SUB HYPE \\o/",
			"#1 boys",
			"EXPERT PogChanmp",
			"gg",
			"DUN",
			"WR",
			"69 Keepo",
			"uuuuhhh",
			"UUUUUUUHH",
			"uuuuuuuuuuuhhhhhhhhhhhhhhh",
			"eat a shit",
			"art DansGame",
			"!help",
			"!commands",
			"!spam",
			"!rules",
			"Nazi mods!",
			"Wow this game sucks!",
		]) {
			auto msg = new TTFText(game.font);
			msg.text = txt;
			msg.position = vec2(0, 0);
			_messages ~= msg;
		}
		_banned = new TTFText(game.font);
		_banned.text = "MLG_Hax0r1 has been banned from this channel.";
		_banned.position = vec2(0, 0);
		lineHeight = game.font.lineHeight;
		
		_prefix = new TTFText(game.font);
		_prefix.text = "MLG_Hax0r1: ";
		_prefix.position = vec2(0, 0);
		offX = _prefix.texture.width;
		
		_messagesDeleted = new TTFText(game.font);
		_messagesDeleted.text = "<message deleted>";
		_messagesDeleted.position = vec2(0, 0);
		
		//dfmt on
	}

	override void start(int difficulty) {
		super.start(difficulty);
		aDown = false;
		bDown = false;
		active.length = 0;
		needed = 50 + difficulty * 5;
		active.reserve(100);
		t = 0;
		done = false;
	}

	override void stop() {
		active.length = 0;
	}

	override void update() {
		t += _game.delta;
		if (_game.isButtonADown && !aDown && !done)
			active ~= uniform(0, _messages.length);
		if (_game.isButtonBDown && !bDown && !done)
			active ~= uniform(0, _messages.length);

		if (active.length >= needed && !done) {
			done = true;
			t = 0;
			_won = true;
		}
		
		if(done && t >= 0.5f)
			_done = true;

		aDown = _game.isButtonADown;
		bDown = _game.isButtonBDown;
	}

	override void draw() {
		matrixStack.push();
		matrixStack.top = matrixStack.top.scale2d(0.5f, 0.5f);
		if (done) {
			_game.colorTextureShader.bind();
			_game.colorTextureShader.set("color", vec3(0.5f, 0.5f, 0.5f));
			_banned.position = vec2(50, WindowHeight * 2 - lineHeight * 1.25f);
			_game.target.draw(_banned, _game.colorTextureShader);
			float y = WindowHeight * 2 - lineHeight * 2.5f;
			foreach_reverse (i; active) {
				_prefix.position = vec2(50, y);
				_game.colorTextureShader.set("color", vec3(Color3.White));
				_game.target.draw(_prefix);
				_game.colorTextureShader.set("color", vec3(Color3.DarkMagenta));
				_messagesDeleted.position = vec2(50 + offX, y);
				_game.target.draw(_messagesDeleted, _game.colorTextureShader);
				y -= lineHeight * 1.25f;
			}
		} else {
			float y = WindowHeight * 2 - lineHeight * 1.25f;
			foreach_reverse (i; active) {
				_prefix.position = vec2(50, y);
				_game.target.draw(_prefix);
				_messages[i].position = vec2(50 + offX, y);
				_game.target.draw(_messages[i]);
				y -= lineHeight * 1.25f;
			}
		}
		matrixStack.pop();
		
		if(!done) {
			_game.indicatorA.pressed = cast(int)(t * 10) % 2 == 0;
			_game.indicatorB.pressed = cast(int)(t * 10) % 2 == 1;
			_game.indicatorA.position = vec2(10, WindowHeight - 50);
			_game.target.draw(_game.indicatorA);
			_game.indicatorB.position = vec2(60, WindowHeight - 50);
			_game.target.draw(_game.indicatorB);
		}
	}

	@property override Duration getPlayTime() const {
		return 5.seconds;
	}

private:
	bool aDown, bDown;
	size_t needed;
	size_t[] active;
	bool done;
	float t = 0, lineHeight;
	TTFText[] _messages;
	TTFText _prefix;
	float offX;
	TTFText _messagesDeleted;
	TTFText _banned;
}
