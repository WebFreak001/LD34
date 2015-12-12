module ld34.minigame.missingpiece;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import std.stdio;

import d2d;

final class MissingPiece : Minigame {
public:
	this(LD34 game) {
		super(game);

		tetrisBlock = RectangleShape.create(new Texture("res/tex/tetris/block.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest), vec2(), vec2(48,
			48));
	}

	// PIECE:
	//  #
	// #R#
	// R = rotation point

	override void start(int difficulty) {
		super.start(difficulty);
		fallTime = 0;
		blockTime = 0;
		wasADown = false;
		x = 6;
		y = -3;
		rota = 0;
		//dfmt off
		switch (difficulty) {
		default:
			blocks = [
				[4, 4, 4, 0, 0, 0, 0, 0, 0, 0],
				[3, 3, 4, 5, 5, 5, 0, 0, 0, 1],
				[1, 3, 3, 5, 6, 0, 0, 0, 6, 1],
				[1, 2, 2, 6, 6, 5, 0, 6, 6, 1],
			];
			break;
		}
		//dfmt on
	}

	override void stop() {
		writeln(__PRETTY_FUNCTION__);
	}

	override void update() {
		fallTime += _game.delta;

		if (_game.isButtonBDown) // speed up
			fallTime += _game.delta;

		if (_game.isButtonADown && !wasADown)
			rotateRight();

		if (fallTime > 0.2f) {
			moveDown();
			fallTime -= 0.2f;
		}
		if (!canFit(x, y + 1, rota))
			blockTime += _game.delta;
		if (blockTime >= 0.4f) {
			_done = true;
		}
		wasADown = _game.isButtonADown;
		writeln("Can fit: ", canFit(x, y + 1, rota));
	}

	void moveDown() {
		if (canFit(x, y + 1, rota))
			y++;
	}

	void rotateRight() {
		if (canFit(x, y, (rota + 1) % 4))
			rota = (rota + 1) % 4;
		else if (canFit(x, y - 1, (rota + 1) % 4)) {
			y--;
			rota = (rota + 1) % 4;
		}
	}

	bool canFit(int x, int y, int rota) {
		switch (rota) {
		case 0:
			return getBlock(x - 1, y) == 0 && getBlock(x + 1, y) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y - 1) == 0;
		case 1:
			return getBlock(x - 1, y) == 0 && getBlock(x, y - 1) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y + 1) == 0;
		case 2:
			return getBlock(x - 1, y) == 0 && getBlock(x + 1, y) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y + 1) == 0;
		case 3:
			return getBlock(x + 1, y) == 0 && getBlock(x, y - 1) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y + 1) == 0;
		default:
			return false;
		}
	}

	ubyte getBlock(int x, int y) {
		if (x < 0 || y >= blocks.length || x >= blocks[0].length)
			return ubyte.max;
		if (y < 0)
			return 0;
		return blocks[y][x];
	}

	vec3 getColor(int x, int y) {
		if (x < 0 || y < 0 || y >= blocks.length || x >= blocks[0].length)
			return vec3(0, 0, 0);
		if (blocks[y][x] >= 0 && blocks[y][x] < 8) {
			auto color = colors[blocks[y][x]];
			return vec3(color.fR, color.fG, color.fB);
		}
		return vec3(0, 0, 0);
	}

	override void draw() {
		for (int y = 0; y < blocks.length; y++) {
			for (int x = 0; x < blocks[0].length; x++) {
				if (getBlock(x, y)) {
					tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY);
					_game.colorTextureShader.bind();
					_game.colorTextureShader.set("color", getColor(x, y));
					_game.target.draw(tetrisBlock, _game.colorTextureShader);
				}
			}
		}

		tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY);
		_game.colorTextureShader.bind();
		_game.colorTextureShader.set("color", playerColor);
		_game.target.draw(tetrisBlock, _game.colorTextureShader);
	}

	@property override Duration getPlayTime() const {
		return 5.seconds;
	}

private:
	Color[7] colors = [
		Color.Cyan, Color.Blue, Color.Orange, Color.Yellow, Color.LimeGreen,
		Color.Magenta, Color.Red
	];
	auto playerColor = vec3(Color3.Magenta);
	ubyte[][] blocks;
	int offsetX = 256;
	int offsetY = 400; 
	int x, y, rota;
	float fallTime, blockTime;
	bool wasADown = false;
	RectangleShape tetrisBlock;
}
