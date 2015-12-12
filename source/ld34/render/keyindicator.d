module ld34.render.keyindicator;

import d2d;
import std.string;

class KeyIndicator : Transformable, IDrawable {
public:
	this(string key, TTFFont font, Texture base) {
		background = RectangleShape.create(base, vec2(0, 0), vec2(48, 48));
		this.font = font;
		text = new TTFText(font);
		text.scale = 0.5f;
		text.text = key.toUpper;
		text.position = vec2(24, (48 - font.lineHeight * 0.5f) * 0.5f);
	}

	override void draw(IRenderTarget target, ShaderProgram shader = null) {
		matrixStack.push();
		matrixStack.top = matrixStack.top * transform;
		background.draw(target, shader);
		text.draw(target, shader);
		matrixStack.pop();
	}
	
	void setKey(string key) {
		text.text = key.toUpper;
		text.position = vec2((48 - text.texture.width) * 0.5f, (48 - font.lineHeight) * 0.5f);
	}

private:
	RectangleShape background;
	TTFText text;
	TTFFont font;
}
