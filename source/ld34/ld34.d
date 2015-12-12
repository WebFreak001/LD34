module ld34.ld34;

import d2d;

import std.algorithm;
import std.stdio;
import std.random;
import std.datetime;

import ld34.minigame.minigame;
import ld34.render.keyindicator;
import ld34.render.rendertexture;

version = ImprovedGameplay;

public enum WindowWidth = 1280;
public enum WindowHeight = 720;

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
		_colorTexture.set("tex", 0);
		_colorTexture.set("color", vec3(1, 1, 1));

		_renderTex = new RenderTexture(WindowWidth, WindowHeight);
		_renderQuad = RectangleShape.create(_renderTex.texture, vec2(0, 0),
			vec2(WindowWidth, WindowHeight), vec4(0, 1, 1, 0));
	}

	override void update(float delta) {
		_delta = delta;
		_time += delta;
		_currentMinigame.update();

		if (_currentMinigame.isDone || _gameTimer.peek.to!Duration >= _currentMinigame.getPlayTime) {
			writeln("isWon: ", _currentMinigame.hasWon);
			if (!_currentMinigame.hasWon)
				reduceLife();
			newGame();
		}
	}

	override void onEvent(Event event) {
		switch (event.type) {
		case Event.Type.Resized:
			window.resize(event.width, event.height);
			writefln("New Size: %sx%s", event.width, event.height);
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
			break;
		default:
			break;
		}
	}

	override void draw() {
		_renderTex.bind();
		_renderTex.clear(Color3.SkyBlue);
		_currentMinigame.draw();
		window.bind();
		window.clear(Color3.SkyBlue);
		version (ImprovedGameplay) {
			matrixStack.push();
			matrixStack.top = matrixStack.top * mat4.identity.translate2d(-WindowWidth / 2,
				-WindowHeight / 2).scale2d(sin(_time) * 0.2f + 0.6f, cos(_time) * 0.1f + 0.6f).rotate2d(_time * 0.3f).translate2d(
				WindowWidth / 2, WindowHeight / 2);
			window.draw(_renderQuad);
			matrixStack.pop();
		} else
			window.draw(_renderQuad);
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
		if (_currentMinigame)
			_currentMinigame.stop();

		_currentMinigame = minigame;

		game++;

		if (_currentMinigame) {
			_currentMinigame.start(game / 5);
			_gameTimer.stop();
			_gameTimer.reset();
			_gameTimer.start();
		}
		return _currentMinigame;
	}

	@property IRenderTarget target() {
		return _renderTex;
	}

	@property auto colorTextureShader() {
		return _colorTexture;
	}

	void reduceLife() {
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

private:
	float _delta;
	int _buttonA;
	int _buttonB;
	bool _buttonADown;
	bool _buttonBDown;
	TTFFont _font;
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
	float _time = 0;

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
