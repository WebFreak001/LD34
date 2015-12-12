module ld34.render.keyindicator;

import d2d;
import std.string;

class KeyIndicator : Transformable, IDrawable {
public:
	this(string key, TTFFont font, Texture base, Texture down) {
		up = base;
		this.down = down;
		background = RectangleShape.create(base, vec2(0, 0), vec2(48, 48));
		this.font = font;
		text = new TTFText(font);
		setKey(key);
		text.multiline = true;
		text.scale = 0.5f;
		setKey(key);
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null) {
		matrixStack.push();
		matrixStack.top = matrixStack.top * transform;
		background.texture = _pressed ? down : up;
		background.draw(target, shader);
		matrixStack.top = matrixStack.top * mat4.translation(24, 20 + (_pressed ? 6 : 0), 0);
		text.draw(target, shader);
		matrixStack.pop();
	}

	void setKey(string key) {
		text.text = key.toUpper;
		text.position = vec2(-font.measureText(key).x * 0.5f, -font.lineHeight * 0.5f);
	}
	
	@property ref bool pressed() { return _pressed; }

private:
	bool _pressed;
	RectangleShape background;
	Texture up, down;
	TTFText text;
	TTFFont font;
}
