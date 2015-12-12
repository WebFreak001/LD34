module ld34.ld34;

import d2d;
import std.algorithm;
import std.stdio;

class LD34 : Game {
private:
public:
	override void start() {
		windowWidth = 1280;
		windowHeight = 720;
		windowTitle = "LD34 Growing madness!";
		maxFPS = 0;
		flags |= WindowFlags.Resizable;
	}

	override void load() {

	}

	override void update(float delta) {

	}

	override void onEvent(Event event) {
		switch (event.type) {
		case Event.Type.Resized:
			window.resize(event.width, event.height);
			writefln("New Size: %sx%s", event.width, event.height);
			break;
		default:
			break;
		}
	}

	override void draw() {

		window.clear(Color3.SkyBlue);
	}
}
