module app;

version = HasScoreboard;

import ld34.ld34;
import std.getopt;
import std.random;
import std.stdio;
import std.conv;
import std.c.stdlib;

immutable string[] adjectives = [
	"Quick",
	"Slow",
	"Bad",
	"Good",
	"Drunken",
	"Advanced",
	"Dark",
	"Light",
	"Super",
];

immutable string[] colors = [
	"Red",
	"Pink",
	"Green",
	"Yellow",
	"Orange",
	"Purple",
	"Cyan",
];

immutable string[] things = [
	"Potato",
	"Tomato",
	"Cucumber",
	"Pickle",
	"Tetromino",
	"Car",
	"Picture",
	"Terminal",
	"Webbrowser",
	"Block",
];

string generateUsername() {
	return adjectives[uniform(0, adjectives.length)] ~ ' ' ~ colors[uniform(0, colors.length)] ~ ' ' ~ things[uniform(0, things.length)];
}

void main(string[] args) {
	string username = generateUsername();
	getopt(args, "u|user|username", &username);
	new LD34(username).run();
	version(HasScoreboard) {
		scoreboardThread.stop();
		exit(0);
	}
}
