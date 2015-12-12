module ld34.render.rendertexture;

import d2d;

/// Render to texture
class RenderTexture : IRenderTarget {
	/// Creates a new RenderTexture with a specified size
	this(int width, int height) {
		create(width, height);
	}

	/// Set active container.
	override void bind() {
		glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
		glViewport(0, 0, _texture.width, _texture.height);
	}

	/// Resize the container texture to the new width and height.
	override void resize(int width, int height) {
		glDeleteFramebuffers(1, &_fbo);
		_texture.dispose();
		create(width, height);
	}

	/// Create a container texture in the given resolution.
	override void create(int width, int height) {
		glGenFramebuffers(1, &_fbo);
		glBindFramebuffer(GL_FRAMEBUFFER, _fbo);

		_texture = new Texture();
		_texture.minFilter = TextureFilterMode.Nearest;
		_texture.magFilter = TextureFilterMode.Nearest;
		_texture.create(width, height, GL_RGB, null);

		glGenRenderbuffers(1, &_drb);
		glBindRenderbuffer(GL_RENDERBUFFER, _drb);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER,
			_drb);

		glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, _texture.id, 0);

		glDrawBuffers(1, [GL_COLOR_ATTACHMENT0].ptr);
		projectionStack.set(mat4.orthographic(0, width, height, 0, -1, 1));
		if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
			throw new Exception("Invalid Framebuffer");
	}

	/// Returns the result of the container texture.
	override @property Texture texture() {
		return _texture;
	}

private:
	uint _fbo, _drb;
	Texture _texture;
}
