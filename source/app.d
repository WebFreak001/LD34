module app;

version = HasScoreboard;

import ld34.ld34;
import std.getopt;
import std.random;
import std.stdio;
import std.conv;
import std.c.stdlib;

void main(string[] args) {
	string username = "Anon#" ~ to!string(uniform(uint.min, uint.max));
	getopt(args, "u|user|username", &username);
	new LD34(username).run();
	version(HasScoreboard) {
		scoreboardThread.stop();
		exit(0);
	}
}
