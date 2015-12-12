module ld34.ld34;

import d2d;

import std.algorithm;
import std.stdio;
import std.random;
import std.datetime;

import ld34.minigame.minigame;
import ld34.render.keyindicator;
import ld34.render.rendertexture;

public enum WindowWidth = 1280;
public enum WindowHeight = 720;

enum GameState {
	GameOverStart,
	GameOver,
	MenuStart,
	Menu,
	FasterAnnounceShow,
	ControlsShow,
	Game,
	GameEnd,
}

static double cubicin(double delta, double offset, double time) {
	return delta * time * time * time + offset;
}

static double circularin(double delta, double offset, double time) {
	return -delta * (sqrt(1 - time * time) - 1) + offset;
}

class LD34 : Game {
public:
	override void start() {
		windowWidth = WindowWidth;
		windowHeight = WindowHeight;
		windowTitle = "LD34 Growing madness!";
		maxFPS = 0;
		flags |= WindowFlags.Resizable;
		_buttonA = SDLK_LEFT;
		_buttonB = SDLK_RIGHT;
	}

	override void load() {
		_font = new TTFFont();
		_font.load("res/font/Roboto-Regular.ttf", 64);
		_faster = new TTFText(_font);
		_faster.text = "FASTER!";
		_gameOverText = new TTFText(_font);
		_gameOverText.text = "Game Over! Your Score: ???";
		_gameOverDescription = new TTFText(_font);
		_gameOverDescription.text = "Press any key to continue...";
		_startDescription = new TTFText(_font);
		_startDescription.text = "PRESS ANY KEY";

		_sAdvance = new Sound("res/sound/advance.wav");
		_sFaster = new Sound("res/sound/faster.wav");
		_sHPDown = new Sound("res/sound/hpdown.wav");
		_sHPUp = new Sound("res/sound/hpup.wav");

		auto key = new Texture("res/tex/generic/key.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		auto down = new Texture("res/tex/generic/keydown.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		_indicatorA = new KeyIndicator("<", _font, key, down);
		_indicatorB = new KeyIndicator(">", _font, key, down);

		registerMinigame();
		_currentMinigameIdx = 0;
		currentMinigame = _minigames[_currentMinigameIdx];

		_colorTexture = ShaderProgram.fromVertexFragmentFiles("res/shader/base.vert",
			"res/shader/base.frag");
		_colorTexture.bind();
		_colorTexture.registerUniform("tex");
		_colorTexture.registerUniform("color");
		_colorTexture.registerUniform("transform");
		_colorTexture.registerUniform("projection");
		_colorTexture.registerUniform("opacity");
		_colorTexture.set("tex", 0);
		_colorTexture.set("opacity", 1);
		_colorTexture.set("color", vec3(1, 1, 1));

		_renderTex = new RenderTexture(WindowWidth, WindowHeight);
		_renderQuad = RectangleShape.create(_renderTex.texture, vec2(0, 0),
			vec2(WindowWidth, WindowHeight), vec4(0, 1, 1, 0));

		_healthBar = RectangleShape.create(new Texture("res/tex/generic/health.png",
			TextureFilterMode.Nearest, TextureFilterMode.Nearest),
			vec2((WindowWidth - 256) * 0.5f, 0), vec2(256, 64));
			
		_blank = new Texture();
		_blank.create(1, 1, cast(ubyte[]) [255, 255, 255, 255]);
		
		_blankShape = RectangleShape.create(_blank, vec2(0, 0), vec2(1, 1));
		_blendShape = RectangleShape.create(_blank, vec2(0, 0), vec2(WindowWidth, WindowHeight));

		randomizeKeys();
	}

	override void update(float delta) {
		delta *= _speed;
		_delta = delta;
		_time += delta;
		final switch (_state) with (GameState) {
		case FasterAnnounceShow:
			if (_time > 1.0f) {
				_state = ControlsShow;
				_time = 0;
			}
			break;
		case ControlsShow:
			if (_time > 2.5f) {
				_state = Game;
				_time = 0;
				newGame();
			}
			break;
		case Game:
			_currentMinigame.update();
			auto t = _currentMinigame.getPlayTime;
			t = dur!"nsecs"(cast(long)(t.total!"nsecs" / _speed));
			if (_currentMinigame.isDone || _gameTimer.peek.to!Duration >= t) {
				_currentMinigame.stop();
				_gameTimer.stop();
				_gameTimer.reset();
				if (!_currentMinigame.hasWon)
					reduceLife();
				else
					_sAdvance.play(0, 0);
				if (_health > 0)
					_state = GameEnd;
				_time = 0;
			}
			break;
		case GameEnd:
			if (_time > 0.5f) {
				if (game % 4 == 0)
					increaseSpeed();
				else
					_state = ControlsShow;
				_time = 0;
				randomizeKeys();
			}
			break;
		case GameOverStart:
			if (_time > 2.0f) {
				_state = GameOver;
				_time = 0;
				_gameOverText.text = "Game Over! Your Score: " ~ to!string(totalScore);
				_blankShape.position = _gameOverText.position;
				_blankShape.size = _gameOverText.size;
				_blankShape.create();
			}
			break;
		case GameOver:
			break;
		case MenuStart:
			if (_time > 0.5f) {
				_state = Menu;
				_time = 0;
				writeln("Menu");
			}
			break;
		case Menu:
			break;
		}
	}

	override void onEvent(Event event) {
		switch (event.type) {
		case Event.Type.Resized:
			window.resize(WindowWidth, WindowHeight);
			break;
		case Event.Type.KeyPressed:
			if (event.key == _buttonA) {
				_buttonADown = true;
				_indicatorA.pressed = true;
			} else if (event.key == _buttonB) {
				_buttonBDown = true;
				_indicatorB.pressed = true;
			}
			break;
		case Event.Type.KeyReleased:
			if (event.key == _buttonA) {
				_buttonADown = false;
				_indicatorA.pressed = false;
			} else if (event.key == _buttonB) {
				_buttonBDown = false;
				_indicatorB.pressed = false;
			}
			if (_state == GameState.GameOver) {
				_state = GameState.MenuStart;
				_time = 0;
			}
			if (_state == GameState.Menu) {
				_state = GameState.ControlsShow;
				_time = 0;
			}
			break;
		default:
			break;
		}
	}

	override void draw() {
		window.clear(Color3.White);
		final switch (_state) with (GameState) {
		case FasterAnnounceShow:
			matrixStack.push();
			matrixStack.top = matrixStack.top.translate2d(
				(WindowWidth - _faster.texture.width) * 0.5f, (WindowHeight + 100) * _time - 50);
			_colorTexture.bind();
			_colorTexture.set("color", vec3(0, 0, 0));
			window.draw(_faster, _colorTexture);
			matrixStack.pop();
			matrixStack.push();
			matrixStack.top = matrixStack.top.translate2d(0, 20);
			window.draw(_healthBar);
			matrixStack.pop();
			break;
		case ControlsShow:
			matrixStack.push();
			//dfmt off
			matrixStack.top = matrixStack.top.translate2d(-49, -24).scale2d(cubicin(
				4, 0, min(_time * 2, 1)), cubicin(4, 0, min(_time * 1.9f, 1))).translate2d(WindowWidth * 0.5f, 20 + WindowHeight * 0.5f);
			//dfmt on
			indicatorA.position = vec2(0, 0);
			window.draw(indicatorA);
			indicatorB.position = vec2(50, 0);
			window.draw(indicatorB);
			matrixStack.pop();
			matrixStack.push();
			matrixStack.top = matrixStack.top.translate2d(0, cubicin(84, -64,
				1 - max(0, (_time - 2) * 2)));
			window.draw(_healthBar);
			matrixStack.pop();
			break;
		case Game:
			window.clear(Color3.SkyBlue);
			_currentMinigame.draw();
			break;
		case GameEnd:
			_renderTex.bind();
			_renderTex.clear(Color3.SkyBlue);
			_currentMinigame.draw();
			window.bind();
			matrixStack.push();
			matrixStack.top = matrixStack.top.translate2d(cubicin(WindowWidth, 0, _time * 2),
				0);
			window.draw(_renderQuad);
			matrixStack.pop();
			matrixStack.push();
			matrixStack.top = matrixStack.top.translate2d(0, cubicin(84, -64, _time * 2));
			window.draw(_healthBar);
			matrixStack.pop();
			break;
		case GameOverStart:
			_renderTex.bind();
			_renderTex.clear(Color3.SkyBlue);
			_currentMinigame.draw();
			window.bind();
			window.clear(Color3.Black);
			matrixStack.push();
			matrixStack.top = matrixStack.top.rotate2d(circularin(0.35f, 0, min(1, _time)));
			matrixStack.top = matrixStack.top.translate2d(0,
				cubicin(WindowHeight, 0, max(0, _time - 1)));
			window.draw(_renderQuad);
			matrixStack.pop();
			break;
		case GameOver:
			window.clear(Color3.Black);
			float offset = 0;
			float offsetDescription = 0;
			if(_time > 2)
				offset = -min(1, _time - 2) * 50;
			if(_time > 2)
				offsetDescription = min(1, _time - 2) * 30;
			matrixStack.push();
			matrixStack.top = matrixStack.top.translate2d(
				(WindowWidth - _gameOverDescription.texture.width) * 0.5f, (WindowHeight - 50) * 0.5f + offsetDescription);
			_colorTexture.bind();
			_colorTexture.set("color", vec3(0.5f, 0.5f, 0.5f));
			window.draw(_gameOverDescription, _colorTexture);
			matrixStack.pop();
			matrixStack.push();
			matrixStack.top = matrixStack.top.translate2d(
				(WindowWidth - _gameOverText.texture.width) * 0.5f, (WindowHeight - 50) * 0.5f + offset);
			_colorTexture.bind();
			_colorTexture.set("color", vec3(Color3.Black));
			window.draw(_blankShape, _colorTexture);
			_colorTexture.set("color", vec3(0.8f, 0.8f, 0.8f));
			_colorTexture.set("color", vec3(1, 1, 1));
			window.draw(_gameOverText, _colorTexture);
			matrixStack.pop();
			break;
		case MenuStart:
			float opacity = circularin(-1, 1, _time * 2);
			drawMenu();
			_colorTexture.bind();
			_colorTexture.set("color", vec3(Color3.Black));
			_colorTexture.set("opacity", opacity);
			window.draw(_blendShape, _colorTexture);
			_colorTexture.set("opacity", 1.0f);
			_colorTexture.set("color", vec3(1, 1, 1));
			break;
		case Menu:
			drawMenu();
			break;
		}
	}
	
	void drawMenu() {
		matrixStack.push();
		matrixStack.top = matrixStack.top.translate2d(
			(WindowWidth - _startDescription.texture.width) * 0.5f, (WindowHeight - 50) * 0.5f);
		_colorTexture.bind();
		_colorTexture.set("color", vec3(0, 0, 0));
		_colorTexture.set("opacity", (cast(int)(_time * 2) % 2) == 0 ? 0.0f : 1.0f);
		window.draw(_startDescription, _colorTexture);
		_colorTexture.set("color", vec3(1, 1, 1));
		_colorTexture.set("opacity", 1.0f);
		matrixStack.pop();
	}
	
	@property int totalScore() const {
		return cast(int) round(game * 1000 * pow(1.15, _speed));
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
		_currentMinigame = minigame;

		game++;

		if (_currentMinigame) {
			_currentMinigame.start(game / 5);
			_gameTimer.start();
		}
		return _currentMinigame;
	}

	@property IRenderTarget target() {
		final switch (_state) with (GameState) {
		case FasterAnnounceShow:
			return _renderTex;
		case ControlsShow:
			return _renderTex;
		case Game:
			return window;
		case GameEnd:
			return _renderTex;
		case GameOverStart:
			return _renderTex;
		case GameOver:
			return window;
		case MenuStart:
			return window;
		case Menu:
			return window;
		}
	}

	@property auto colorTextureShader() {
		return _colorTexture;
	}

	void reduceLife() {
		_sHPDown.play(0, 1);
		_health--;
		updateHealth();
	}

	void updateHealth() {
		if (_health <= 0)
			_state = GameState.GameOverStart;
		if (_health > 4)
			_health = 4;

		_healthBar.size = vec2(64 * _health, 64);
		_healthBar.texCoords = vec4(0, 0, 0.25f * _health, 1);
		_healthBar.create();
	}

	@property TTFFont font() {
		return _font;
	}

	@property KeyIndicator indicatorA() {
		return _indicatorA;
	}

	@property KeyIndicator indicatorB() {
		return _indicatorB;
	}

	void increaseSpeed() {
		_speed *= 1.05f;
		_state = GameState.FasterAnnounceShow;
		_sFaster.play(0, 2);
	}

	void randomizeKeys() {
		auto key1 = uniform(0, 36);
		auto key2 = (uniform(0, 35) + key1 + 1) % 36;

		_buttonADown = false;
		_buttonBDown = false;
		_indicatorA.pressed = false;
		_indicatorB.pressed = false;

		if (key1 > 25) {
			_buttonA = SDLK_0 + key1 - 26;
		} else {
			_buttonA = SDLK_a + key1;
		}

		if (key2 > 25) {
			_buttonB = SDLK_0 + key2 - 26;
		} else {
			_buttonB = SDLK_a + key2;
		}

		_indicatorA.setKey([cast(char) _buttonA]);
		_indicatorB.setKey([cast(char) _buttonB]);
	}

private:
	float _delta;
	int _health = 4;
	int _buttonA;
	int _buttonB;
	bool _buttonADown;
	bool _buttonBDown;
	TTFFont _font;
	TTFText _faster, _gameOverText, _gameOverDescription, _startDescription;
	KeyIndicator _indicatorA;
	KeyIndicator _indicatorB;
	Minigame[] _minigames;
	Minigame _currentMinigame;
	ulong _currentMinigameIdx;
	int game = 0;
	ShaderProgram _colorTexture;
	StopWatch _gameTimer;
	RenderTexture _renderTex;
	RectangleShape _renderQuad;
	RectangleShape _healthBar;
	float _time = 0;
	float _speed = 1;
	GameState _state = GameState.MenuStart;
	Sound _sAdvance, _sFaster, _sHPDown, _sHPUp;
	Texture _blank;
	RectangleShape _blankShape, _blendShape;

	void newGame() {
		_currentMinigameIdx++;

		if (_currentMinigameIdx >= _minigames.length) {
			randomShuffle(_minigames);
			_currentMinigameIdx = 0;
		}

		currentMinigame = _minigames[_currentMinigameIdx];
	}

	void registerMinigame() {
		import ld34.minigame.testgame : TestGame;
		import ld34.minigame.alignandpull : AlignAndPull;
		import ld34.minigame.claw : Claw;
		import ld34.minigame.climb : Climb;
		import ld34.minigame.dance : Dance;
		import ld34.minigame.dontreact : DontReact;
		import ld34.minigame.dontsimon : DontSimon;
		import ld34.minigame.fish : Fish;
		import ld34.minigame.flappy : Flappy;
		import ld34.minigame.floppyavoid : FloppyAvoid;
		import ld34.minigame.missingpiece : MissingPiece;
		import ld34.minigame.qwop : QWOP;
		import ld34.minigame.racer : Racer;
		import ld34.minigame.reactquickly : ReactQuickly;
		import ld34.minigame.rescue : Rescue;
		import ld34.minigame.selfie : Selfie;
		import ld34.minigame.simon : Simon;
		import ld34.minigame.spamalt : SpamAlternating;

		//_minigames ~= new TestGame(this);
		///_minigames ~= new AlignAndPull(this);
		_minigames ~= new Claw(this);
		//_minigames ~= new Climb(this);
		_minigames ~= new Dance(this);
		_minigames ~= new DontReact(this);
		//_minigames ~= new DontSimon(this);
		//_minigames ~= new Fish(this);
		//_minigames ~= new Flappy(this);
		_minigames ~= new FloppyAvoid(this);
		_minigames ~= new MissingPiece(this);
		//_minigames ~= new QWOP(this);
		//_minigames ~= new Racer(this);
		_minigames ~= new ReactQuickly(this);
		//_minigames ~= new Rescue(this);
		//_minigames ~= new Selfie(this);
		//_minigames ~= new Simon(this);
		//_minigames ~= new SpamAlternating(this);

		randomShuffle(_minigames);
	}
}
