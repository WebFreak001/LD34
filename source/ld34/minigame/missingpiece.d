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

		//dfmt off
		tetrisBlock = RectangleShape.create(new Texture("res/tex/tetris/block.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest), vec2(), vec2(48, 48));
		//dfmt on

		auto border = new Texture("res/tex/generic/border.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		auto instructions = new Texture("res/tex/tetris/instructions.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);

		borderLeft = new Border(border);
		borderRight = new Border(border);

		borderLeft.setSize(vec2(500, 600));
		borderRight.setSize(vec2(192, 600));

		//dfmt off
		instructionMove = RectangleShape.create(instructions, vec2(), vec2(48, 48), vec4(0, 0, 0.5f, 1));
		instructionRotate = RectangleShape.create(instructions, vec2(), vec2(48, 48), vec4(0.5f, 0, 1, 1));
		//dfmt on
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
		y = -8;
		rota = 0;
		//dfmt off
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
		switch (difficulty) {
		case 3: .. case 5:
			blocks = [
				[0, 0, 0, 2, 0, 0, 0, 0, 0, 0],
				[1, 1, 1, 2, 0, 0, 0, 0, 1, 0],
				[1, 6, 2, 2, 0, 0, 1, 1, 1, 0],
				[6, 6, 3, 3, 0, 0, 0, 2, 2, 2],
				[1, 6, 3, 3, 6, 9, 0, 0, 6, 2],
				[1, 4, 4, 6, 6, 9, 9, 6, 6, 6],
				[1, 1, 4, 4, 6, 9, 5, 5, 5, 5],
			];
			break;
		default:
			blocks = [
				[3, 3, 3, 0, 0, 0, 0, 0, 0, 0],
				[7, 7, 3, 5, 5, 5, 0, 0, 0, 1],
				[1, 7, 7, 5, 6, 9, 9, 9, 6, 1],
				[1, 2, 2, 6, 6, 3, 9, 6, 6, 1],
			];
			break;
		}
		//dfmt on
		offsetY = WindowHeight - cast(int)blocks.length * 48 - 52;
	}

	override void stop() {
	}

	override @property bool hasWon() const {
		int linesCleared = 0;
		LineLoop: for (int i = 0; i < blocks.length; i++) {
			for (int x = 0; x < blocks[i].length; x++)
				if (!collides(x, i))
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

		if (fallTime > 0.3f) {
			moveDown();
			fallTime -= 0.3f;
		}
		if (!canFit(x, y + 1, rota))
			blockTime += _game.delta;
		if (blockTime >= 0.6f) {
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
		if (canFit(x + 1, y, rota)) {
			x++;
			blockTime -= 0.02f;
		}
	}

	void rotateRight() {
		if (canFit(x, y, (rota + 1) % 4)) {
			rota = (rota + 1) % 4;
			blockTime -= 0.03f;
		} else if (canFit(x, y + 1, (rota + 1) % 4)) {
			y++;
			rota = (rota + 1) % 4;
			blockTime -= 0.03f;
		} else if (canFit(x, y - 1, (rota + 1) % 4)) {
			y--;
			rota = (rota + 1) % 4;
			blockTime -= 0.03f;
		}
	}

	bool canFit(int x, int y, int rota) const {
		switch (rota) {
		case 3:
			return !collides(x - 1, y) && !collides(x + 1, y)
				&& !collides(x, y) && !collides(x, y - 1);
		case 2:
			return !collides(x - 1, y) && !collides(x, y - 1)
				&& !collides(x, y) && !collides(x, y + 1);
		case 1:
			return !collides(x - 1, y) && !collides(x + 1, y)
				&& !collides(x, y) && !collides(x, y + 1);
		case 0:
			return !collides(x + 1, y) && !collides(x, y - 1)
				&& !collides(x, y) && !collides(x, y + 1);
		default:
			return false;
		}
	}

	bool collides(int x, int y) const {
		if (x < 0 || y >= cast(int) blocks.length || x >= cast(int) blocks[0].length)
			return true;
		if (y < 0)
			return false;
		if (blocks[y][x] == 9)
			return false;
		return blocks[y][x] != 0;
	}

	ubyte getBlock(int x, int y) const {
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

	vec3 getColor(int x, int y) const {
		if (x < 0 || y < 0 || y >= cast(int) blocks.length || x >= cast(int) blocks[0].length)
			return vec3(0, 0, 0);
		if (blocks[y][x] >= 0 && blocks[y][x] < 8) {
			return getColor(blocks[y][x]);
		}
		return vec3(0, 0, 0);
	}

	vec3 getColor(ubyte b) const {
		if (b >= colors.length)
			return vec3(0, 0, 0);
		auto color = colors[b];
		return vec3(color.fR, color.fG, color.fB);
	}

	override void draw() {
		_game.target.clear(0.15f, 0.15f, 0.15f);
		borderLeft.position = vec2(offsetX + (480 - 500) * 0.5f, 80);
		borderRight.position = vec2(offsetX + (480 - 500) * 0.5f + 510, 80);
		_game.target.draw(borderLeft);
		_game.target.draw(borderRight);

		for (int y = 0; y < inventory.length; y++) {
			for (int x = 0; x < inventory[0].length; x++) {
				if (inventory[y][x] == 0)
					continue;
				tetrisBlock.position = vec2(x * 48 + offsetX + 524, y * 48 + 100);
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
					if (getBlock(x, y) == 9) {
						_game.colorTextureShader.set("opacity", 0.3f);
						_game.colorTextureShader.set("color", playerColor);
						_game.target.draw(tetrisBlock, _game.colorTextureShader);
						_game.colorTextureShader.set("opacity", 1.0f);
					} else {
						_game.target.draw(tetrisBlock, _game.colorTextureShader);
					}
				}
			}
		}

		_game.indicatorA.position = vec2(x * 48 + offsetX + 100, y * 48 + offsetY - 25);
		_game.target.draw(_game.indicatorA);
		instructionRotate.position = vec2(x * 48 + offsetX + 150, y * 48 + offsetY - 25);
		_game.target.draw(instructionRotate);

		_game.indicatorB.position = vec2(x * 48 + offsetX + 100, y * 48 + offsetY + 25);
		_game.target.draw(_game.indicatorB);
		instructionMove.position = vec2(x * 48 + offsetX + 150, y * 48 + offsetY + 25);
		_game.target.draw(instructionMove);

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
	RectangleShape instructionMove;
	RectangleShape instructionRotate;
}
