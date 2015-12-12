module ld34.minigame.missingpiece;

import core.time;
import ld34.ld34;
import ld34.minigame.minigame;
import ld34.render.border;
import std.stdio;

import d2d;

final class MissingPiece : Minigame {
public:
	this(LD34 game) {
		super(game);

		tetrisBlock = RectangleShape.create(new Texture("res/tex/tetris/block.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest), vec2(), vec2(48,
			48));

		borderLeft = new Border(new Texture("res/tex/generic/border.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest));
		borderRight = new Border(new Texture("res/tex/generic/border.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest));

		borderLeft.setSize(vec2(500, 600));
		borderRight.setSize(vec2(192, 600));
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
		wasBDown = false;
		x = 5;
		y = -5;
		rota = 0;
		//dfmt off
		switch (difficulty) {
		default:
			blocks = [
				[3, 3, 3, 0, 0, 0, 0, 0, 0, 0],
				[7, 7, 3, 5, 5, 5, 0, 0, 0, 1],
				[1, 7, 7, 5, 6, 0, 0, 0, 6, 1],
				[1, 2, 2, 6, 6, 3, 0, 6, 6, 1],
			];
			inventory = [
				[0, 6, 0],
				[6, 6, 6],
				[0, 0, 0],
				[0, 1, 0],
				[0, 1, 0],
				[0, 1, 0],
				[0, 1, 0],
				[0, 0, 0],
				[3, 0, 0],
				[3, 3, 3],
			];
			break;
		}
		//dfmt on
	}

	override void stop() {
	}

	override @property bool hasWon() const {
		int linesCleared = 0;
		LineLoop: for (int i = 0; i < blocks.length; i++) {
			for (int x = 0; x < blocks[i].length; x++)
				if (blocks[i][x] == 0)
					continue LineLoop;
			linesCleared++;
		}
		return linesCleared > 1;
	}

	void placeBlock() {
		setBlock(x, y, 5);
		switch (rota) {
		case 3:
			setBlock(x - 1, y, 5);
			setBlock(x + 1, y, 5);
			setBlock(x, y - 1, 5);
			break;
		case 2:
			setBlock(x - 1, y, 5);
			setBlock(x, y - 1, 5);
			setBlock(x, y + 1, 5);
			break;
		case 1:
			setBlock(x - 1, y, 5);
			setBlock(x + 1, y, 5);
			setBlock(x, y + 1, 5);
			break;
		case 0:
			setBlock(x + 1, y, 5);
			setBlock(x, y - 1, 5);
			setBlock(x, y + 1, 5);
			break;
		default:
			break;
		}
	}

	override void update() {
		fallTime += _game.delta;

		if (_game.isButtonBDown && !wasBDown)
			moveRight();

		if (_game.isButtonADown && !wasADown)
			rotateRight();

		if (fallTime > 0.2f) {
			moveDown();
			fallTime -= 0.2f;
		}
		if (!canFit(x, y + 1, rota))
			blockTime += _game.delta;
		if (blockTime >= 0.4f) {
			placeBlock();
			_done = true;
		}
		wasADown = _game.isButtonADown;
		wasBDown = _game.isButtonBDown;
	}

	void moveDown() {
		if (canFit(x, y + 1, rota))
			y++;
	}

	void moveRight() {
		if (canFit(x + 1, y, rota))
			x++;
	}

	void rotateRight() {
		if (canFit(x, y, (rota + 1) % 4))
			rota = (rota + 1) % 4;
		else if (canFit(x, y + 1, (rota + 1) % 4)) {
			y++;
			rota = (rota + 1) % 4;
		} else if (canFit(x, y - 1, (rota + 1) % 4)) {
			y--;
			rota = (rota + 1) % 4;
		}
	}

	bool canFit(int x, int y, int rota) {
		switch (rota) {
		case 3:
			return getBlock(x - 1, y) == 0 && getBlock(x + 1, y) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y - 1) == 0;
		case 2:
			return getBlock(x - 1, y) == 0 && getBlock(x, y - 1) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y + 1) == 0;
		case 1:
			return getBlock(x - 1, y) == 0 && getBlock(x + 1, y) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y + 1) == 0;
		case 0:
			return getBlock(x + 1, y) == 0 && getBlock(x, y - 1) == 0
				&& getBlock(x, y) == 0 && getBlock(x, y + 1) == 0;
		default:
			return false;
		}
	}

	ubyte getBlock(int x, int y) {
		if (x < 0 || y >= cast(int) blocks.length || x >= cast(int) blocks[0].length)
			return ubyte.max;
		if (y < 0)
			return 0;
		return blocks[y][x];
	}

	void setBlock(int x, int y, ubyte type) {
		if (x < 0 || y < 0 || y >= cast(int) blocks.length || x >= cast(int) blocks[0].length)
			return;
		blocks[y][x] = type;
	}

	vec3 getColor(int x, int y) {
		if (x < 0 || y < 0 || y >= cast(int) blocks.length || x >= cast(int) blocks[0].length)
			return vec3(0, 0, 0);
		if (blocks[y][x] >= 0 && blocks[y][x] < 8) {
			return getColor(blocks[y][x]);
		}
		return vec3(0, 0, 0);
	}

	vec3 getColor(ubyte b) {
		if (b >= colors.length)
			return vec3(0, 0, 0);
		auto color = colors[b];
		return vec3(color.fR, color.fG, color.fB);
	}

	override void draw() {
		_game.target.clear(0.15f, 0.15f, 0.15f);
		borderLeft.position = vec2(offsetX + (480 - 500) * 0.5f, offsetY - 400);
		borderRight.position = vec2(offsetX + (480 - 500) * 0.5f + 510, offsetY - 400);
		_game.target.draw(borderLeft);
		_game.target.draw(borderRight);

		for (int y = 0; y < inventory.length; y++) {
			for (int x = 0; x < inventory[0].length; x++) {
				if (inventory[y][x] == 0)
					continue;
				tetrisBlock.position = vec2(x * 48 + offsetX + 524, y * 48 + offsetY - 376);
				_game.colorTextureShader.bind();
				_game.colorTextureShader.set("color", getColor(inventory[y][x]));
				_game.target.draw(tetrisBlock, _game.colorTextureShader);
			}
		}

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

		_game.colorTextureShader.bind();
		_game.colorTextureShader.set("color", playerColor);
		tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY);
		_game.target.draw(tetrisBlock, _game.colorTextureShader);
		switch (rota) {
		case 3:
			tetrisBlock.position = vec2(x * 48 + offsetX - 48, y * 48 + offsetY);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX + 48, y * 48 + offsetY);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY - 48);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			break;
		case 2:
			tetrisBlock.position = vec2(x * 48 + offsetX - 48, y * 48 + offsetY);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY - 48);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY + 48);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			break;
		case 1:
			tetrisBlock.position = vec2(x * 48 + offsetX - 48, y * 48 + offsetY);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX + 48, y * 48 + offsetY);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY + 48);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			break;
		case 0:
			tetrisBlock.position = vec2(x * 48 + offsetX + 48, y * 48 + offsetY);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY - 48);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			tetrisBlock.position = vec2(x * 48 + offsetX, y * 48 + offsetY + 48);
			_game.target.draw(tetrisBlock, _game.colorTextureShader);
			break;
		default:
			while (rota < 0)
				rota += 4;
			rota = (rota % 4);
			break;
		}
	}

	@property override Duration getPlayTime() const {
		return 5.seconds;
	}

private:
	Color[8] colors = [
		Color.Black, Color.Cyan, Color.Blue, Color.Orange, Color.Yellow,
		Color.LimeGreen, Color.Magenta, Color.Red
	];
	auto playerColor = vec3(Color3.Magenta);
	ubyte[][] blocks;
	ubyte[][] inventory;
	int offsetX = 256;
	int offsetY = 450;
	int x, y, rota;
	float fallTime, blockTime;
	bool wasADown, wasBDown;
	Border borderLeft, borderRight;
	RectangleShape tetrisBlock;
}
