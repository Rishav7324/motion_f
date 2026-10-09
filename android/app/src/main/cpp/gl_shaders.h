#pragma once

namespace motionf {

// Standard Quad Vertex Shader taking 4x4 MVP Matrix
inline const char* VERTEX_SHADER_MVP = R"glsl(#version 300 es
layout(location = 0) in vec4 aPosition;
layout(location = 1) in vec2 aTexCoord;

uniform mat4 uMVPMatrix;
out vec2 vTexCoord;

void main() {
    gl_Position = uMVPMatrix * aPosition;
    vTexCoord = aTexCoord;
}
)glsl";

// Multi-Blend Mode Fragment Shader
inline const char* FRAGMENT_SHADER_BLEND = R"glsl(#version 300 es
precision mediump float;

in vec2 vTexCoord;
uniform sampler2D uBaseTexture;    // Background layer
uniform sampler2D uSourceTexture;  // Foreground / active layer
uniform int uBlendMode;            // 0: Normal, 1: Screen, 2: Multiply, 3: Overlay, 4: Add, 5: SoftLight
uniform float uOpacity;

out vec4 fragColor;

vec3 blendScreen(vec3 base, vec3 src) {
    return 1.0 - (1.0 - base) * (1.0 - src);
}

vec3 blendMultiply(vec3 base, vec3 src) {
    return base * src;
}

vec3 blendOverlay(vec3 base, vec3 src) {
    return mix(
        2.0 * base * src,
        1.0 - 2.0 * (1.0 - base) * (1.0 - src),
        step(0.5, base)
    );
}

vec3 blendAdd(vec3 base, vec3 src) {
    return min(base + src, vec3(1.0));
}

vec3 blendSoftLight(vec3 base, vec3 src) {
    return mix(
        2.0 * base * src + base * base * (1.0 - 2.0 * src),
        sqrt(base) * (2.0 * src - 1.0) + 2.0 * base * (1.0 - src),
        step(0.5, src)
    );
}

void main() {
    vec4 baseColor = texture(uBaseTexture, vTexCoord);
    vec4 srcColor = texture(uSourceTexture, vTexCoord);

    vec3 blendedRgb = srcColor.rgb;
    if (uBlendMode == 1) {
        blendedRgb = blendScreen(baseColor.rgb, srcColor.rgb);
    } else if (uBlendMode == 2) {
        blendedRgb = blendMultiply(baseColor.rgb, srcColor.rgb);
    } else if (uBlendMode == 3) {
        blendedRgb = blendOverlay(baseColor.rgb, srcColor.rgb);
    } else if (uBlendMode == 4) {
        blendedRgb = blendAdd(baseColor.rgb, srcColor.rgb);
    } else if (uBlendMode == 5) {
        blendedRgb = blendSoftLight(baseColor.rgb, srcColor.rgb);
    }

    float finalAlpha = srcColor.a * uOpacity;
    vec3 composite = mix(baseColor.rgb, blendedRgb, finalAlpha);
    fragColor = vec4(composite, max(baseColor.a, finalAlpha));
}
)glsl";

// GL-Transition Shaders (Dissolve, Wipe, Zoom, Glitch)
inline const char* FRAGMENT_SHADER_TRANSITION = R"glsl(#version 300 es
precision mediump float;

in vec2 vTexCoord;
uniform sampler2D uTextureFrom;
uniform sampler2D uTextureTo;
uniform float uProgress;
uniform int uTransitionType; // 0: Dissolve, 1: Wipe, 2: Zoom, 3: Glitch

out vec4 fragColor;

void main() {
    vec2 p = vTexCoord;
    vec4 fromColor = texture(uTextureFrom, p);
    vec4 toColor = texture(uTextureTo, p);

    if (uTransitionType == 0) {
        // Cross Dissolve
        fragColor = mix(fromColor, toColor, uProgress);
    } else if (uTransitionType == 1) {
        // Linear Wipe
        float pr = smoothstep(-0.05, 0.05, p.x - uProgress);
        fragColor = mix(toColor, fromColor, pr);
    } else if (uTransitionType == 2) {
        // Zoom transition
        vec2 zoomFrom = (p - 0.5) * (1.0 + uProgress * 0.8) + 0.5;
        vec2 zoomTo = (p - 0.5) * (1.0 - (1.0 - uProgress) * 0.8) + 0.5;
        vec4 zFrom = texture(uTextureFrom, zoomFrom);
        vec4 zTo = texture(uTextureTo, zoomTo);
        fragColor = mix(zFrom, zTo, smoothstep(0.0, 1.0, uProgress));
    } else if (uTransitionType == 3) {
        // Glitch Transition
        float slice = step(0.5, sin(p.y * 30.0 + uProgress * 20.0));
        vec2 offset = vec2(slice * (1.0 - uProgress) * 0.05, 0.0);
        vec4 gFrom = texture(uTextureFrom, p + offset);
        vec4 gTo = texture(uTextureTo, p - offset);
        fragColor = mix(gFrom, gTo, uProgress);
    } else {
        fragColor = mix(fromColor, toColor, uProgress);
    }
}
)glsl";

// Chroma Key (Green Screen Removal)
inline const char* FRAGMENT_SHADER_CHROMA_KEY = R"glsl(#version 300 es
precision mediump float;

in vec2 vTexCoord;
uniform sampler2D uTexture;
uniform vec3 uKeyColor; // Default green: vec3(0.0, 1.0, 0.0)
uniform float uSimilarity; // Threshold
uniform float uSmoothness;

out vec4 fragColor;

void main() {
    vec4 col = texture(uTexture, vTexCoord);
    float diff = distance(col.rgb, uKeyColor);
    float mask = smoothstep(uSimilarity, uSimilarity + uSmoothness, diff);
    fragColor = vec4(col.rgb, col.a * mask);
}
)glsl";

} // namespace motionf
