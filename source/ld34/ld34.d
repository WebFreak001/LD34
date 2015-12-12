module ld34.ld34;

import d2d;

import std.algorithm;
import std.stdio;
import std.random;

import ld34.minigame.minigame;
import ld34.render.keyindicator;

class LD34 : Game {
public:
	override void start() {
		windowWidth = 1280;
		windowHeight = 720;
		windowTitle = "LD34 Growing madness!";
		maxFPS = 0;
		flags |= WindowFlags.Resizable;
		_buttonA = SDLK_LEFT;
		_buttonB = SDLK_RIGHT;
	}

	override void load() {
		_font = new TTFFont();
		_font.load("res/font/Roboto-Regular.ttf", 64);
		
		auto key = new Texture("res/tex/generic/key.png", TextureFilterMode.Nearest, TextureFilterMode.Nearest);
		_indicatorA = new KeyIndicator("<", _font, key);
		_indicatorB = new KeyIndicator(">", _font, key);
		
		registerMinigame();
		_currentMinigameIdx = 0;
		currentMinigame = _minigames[_currentMinigameIdx];

		_colorTexture = new ShaderProgram();
		Shader vertex = new Shader();
		vertex.load(ShaderType.Vertex, "#version 330
layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_tex;
uniform mat4 transform;
uniform mat4 projection;
out vec2 texCoord;
void main()
{
	gl_Position = projection * transform * vec4(in_position, 1);
	texCoord = in_tex;
}
");
		Shader fragment = new Shader();
		fragment.load(ShaderType.Fragment, "#version 330
uniform sampler2D tex;
uniform vec3 color;
in vec2 texCoord;
layout(location = 0) out vec4 out_frag_color;
void main()
{
	out_frag_color = texture(tex, texCoord) * vec4(color, 1);
}
");
		_colorTexture.attach(vertex);
		_colorTexture.attach(fragment);
		_colorTexture.link();
		_colorTexture.bind();
		_colorTexture.registerUniform("tex");
		_colorTexture.registerUniform("color");
		_colorTexture.registerUniform("transform");
		_colorTexture.registerUniform("projection");
		_colorTexture.set("tex", 0);
		_colorTexture.set("color", vec3(1, 1, 1));
	}

	override void update(float delta) {
		_delta = delta;
		_currentMinigame.update();

		if (_currentMinigame.isDone) {
			writeln("isWon: ", _currentMinigame.hasWon);
			if(!_currentMinigame.hasWon)
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
			if (event.key == _buttonA)
				_buttonADown = true;
			else if (event.key == _buttonB)
				_buttonBDown = true;
			break;
		case Event.Type.KeyReleased:
			if (event.key == _buttonA)
				_buttonADown = false;
			else if (event.key == _buttonB)
				_buttonBDown = false;
			break;
		default:
			break;
		}
	}

	override void draw() {
		window.clear(Color3.SkyBlue);
		_currentMinigame.draw();
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

		if (_currentMinigame)
			_currentMinigame.start(game / 5);
		return _currentMinigame;
	}

	@property Window target() {
		return this.window;
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

		_minigames ~= new TestGame(this);
		_minigames ~= new AlignAndPull(this);
		_minigames ~= new Climb(this);
		_minigames ~= new Dance(this);
		_minigames ~= new DontReact(this);
		_minigames ~= new DontSimon(this);
		_minigames ~= new Fish(this);
		_minigames ~= new Flappy(this);
		_minigames ~= new FloppyAvoid(this);
		_minigames ~= new MissingPiece(this);
		_minigames ~= new QWOP(this);
		_minigames ~= new Racer(this);
		_minigames ~= new ReactQuickly(this);
		_minigames ~= new Rescue(this);
		_minigames ~= new Selfie(this);
		_minigames ~= new Simon(this);
		_minigames ~= new SpamAlternating(this);

		randomShuffle(_minigames);
	}
}
