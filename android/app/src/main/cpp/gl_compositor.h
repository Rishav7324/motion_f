#pragma once

#include <GLES3/gl3.h>
#include <EGL/egl.h>
#include <android/log.h>
#include <vector>
#include <utility>
#include <algorithm>
#include "motion_math.h"
#include "gl_shaders.h"

#define LOG_TAG "MotionF_GL"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace motionf {

class GlCompositor {
public:
    GLuint fbo[2]{0, 0};
    GLuint fboTextures[2]{0, 0};
    int width{1080};
    int height{1920};

    GLuint blendProgram{0};
    GLuint transitionProgram{0};
    GLuint chromaProgram{0};
    GLuint quadVbo{0};

    bool initialized{false};

    GlCompositor() = default;
    ~GlCompositor() { cleanup(); }

    bool init(int w, int h) {
        width = w;
        height = h;

        initShaders();
        initQuad();
        initFramebuffers();

        initialized = true;
        LOGI("MotionF GlCompositor initialized: %dx%d", width, height);
        return true;
    }

    void resize(int w, int h) {
        if (width == w && height == h) return;
        width = w;
        height = h;
        initFramebuffers();
    }

    void beginFrame() {
        glBindFramebuffer(GL_FRAMEBUFFER, fbo[0]);
        glViewport(0, 0, width, height);
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }

    void compositeLayer(GLuint layerTexture, const Mat4& mvpMatrix, int blendMode, float opacity) {
        // Swap FBO ping-pong: read from fbo[0] texture, write to fbo[1]
        glBindFramebuffer(GL_FRAMEBUFFER, fbo[1]);
        glViewport(0, 0, width, height);

        glUseProgram(blendProgram);

        // Bind Base (current composition accumulated so far)
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, fboTextures[0]);
        glUniform1i(glGetUniformLocation(blendProgram, "uBaseTexture"), 0);

        // Bind Source (new layer to blend)
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, layerTexture);
        glUniform1i(glGetUniformLocation(blendProgram, "uSourceTexture"), 1);

        glUniformMatrix4fv(glGetUniformLocation(blendProgram, "uMVPMatrix"), 1, GL_FALSE, mvpMatrix.m);
        glUniform1i(glGetUniformLocation(blendProgram, "uBlendMode"), blendMode);
        glUniform1f(glGetUniformLocation(blendProgram, "uOpacity"), opacity);

        drawQuad();

        // Swap ping-pong indices
        std::swap(fbo[0], fbo[1]);
        std::swap(fboTextures[0], fboTextures[1]);
    }

    GLuint getOutputTexture() const {
        return fboTextures[0];
    }

    void cleanup() {
        if (!initialized) return;
        glDeleteFramebuffers(2, fbo);
        glDeleteTextures(2, fboTextures);
        if (blendProgram) glDeleteProgram(blendProgram);
        if (transitionProgram) glDeleteProgram(transitionProgram);
        if (chromaProgram) glDeleteProgram(chromaProgram);
        if (quadVbo) glDeleteBuffers(1, &quadVbo);
        initialized = false;
    }

private:
    void initFramebuffers() {
        if (fbo[0]) glDeleteFramebuffers(2, fbo);
        if (fboTextures[0]) glDeleteTextures(2, fboTextures);

        glGenFramebuffers(2, fbo);
        glGenTextures(2, fboTextures);

        for (int i = 0; i < 2; ++i) {
            glBindTexture(GL_TEXTURE_2D, fboTextures[i]);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

            glBindFramebuffer(GL_FRAMEBUFFER, fbo[i]);
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, fboTextures[i], 0);

            GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
            if (status != GL_FRAMEBUFFER_COMPLETE) {
                LOGE("FBO %d incomplete: 0x%x", i, status);
            }
        }
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    void initQuad() {
        // Full screen quad: X, Y, Z, W, U, V
        static const float quadData[] = {
            -1.0f, -1.0f, 0.0f, 1.0f,  0.0f, 0.0f,
             1.0f, -1.0f, 0.0f, 1.0f,  1.0f, 0.0f,
            -1.0f,  1.0f, 0.0f, 1.0f,  0.0f, 1.0f,
             1.0f,  1.0f, 0.0f, 1.0f,  1.0f, 1.0f,
        };
        glGenBuffers(1, &quadVbo);
        glBindBuffer(GL_ARRAY_BUFFER, quadVbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(quadData), quadData, GL_STATIC_DRAW);
    }

    void drawQuad() {
        glBindBuffer(GL_ARRAY_BUFFER, quadVbo);
        glEnableVertexAttribArray(0); // Position
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);

        glEnableVertexAttribArray(1); // TexCoord
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(4 * sizeof(float)));

        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
    }

    void initShaders() {
        blendProgram = createProgram(VERTEX_SHADER_MVP, FRAGMENT_SHADER_BLEND);
        transitionProgram = createProgram(VERTEX_SHADER_MVP, FRAGMENT_SHADER_TRANSITION);
        chromaProgram = createProgram(VERTEX_SHADER_MVP, FRAGMENT_SHADER_CHROMA_KEY);
    }

    GLuint createProgram(const char* vertSrc, const char* fragSrc) {
        GLuint vShader = compileShader(GL_VERTEX_SHADER, vertSrc);
        GLuint fShader = compileShader(GL_FRAGMENT_SHADER, fragSrc);
        GLuint prog = glCreateProgram();
        glAttachShader(prog, vShader);
        glAttachShader(prog, fShader);
        glLinkProgram(prog);

        glDeleteShader(vShader);
        glDeleteShader(fShader);
        return prog;
    }

    GLuint compileShader(GLenum type, const char* src) {
        GLuint s = glCreateShader(type);
        glShaderSource(s, 1, &src, nullptr);
        glCompileShader(s);
        return s;
    }
};

} // namespace motionf
