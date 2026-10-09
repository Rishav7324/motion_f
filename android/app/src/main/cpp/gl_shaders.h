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

// Track Matte (Alpha & Luma Matte like After Effects)
inline const char* FRAGMENT_SHADER_TRACK_MATTE = R"glsl(#version 300 es
precision mediump float;

in vec2 vTexCoord;
uniform sampler2D uSourceTexture;
uniform sampler2D uMatteTexture;
uniform int uMatteType; // 1: Alpha, 2: Alpha Inverted, 3: Luma, 4: Luma Inverted

out vec4 fragColor;

void main() {
    vec4 src = texture(uSourceTexture, vTexCoord);
    vec4 matte = texture(uMatteTexture, vTexCoord);

    float matteFactor = 1.0;
    if (uMatteType == 1) {
        matteFactor = matte.a;
    } else if (uMatteType == 2) {
        matteFactor = 1.0 - matte.a;
    } else if (uMatteType == 3) {
        matteFactor = dot(matte.rgb, vec3(0.299, 0.587, 0.114));
    } else if (uMatteType == 4) {
        matteFactor = 1.0 - dot(matte.rgb, vec3(0.299, 0.587, 0.114));
    }

    fragColor = vec4(src.rgb, src.a * matteFactor);
}
)glsl";

// Vector Mask (Rectangular & Elliptical Mask with Feathering)
inline const char* FRAGMENT_SHADER_VECTOR_MASK = R"glsl(#version 300 es
precision mediump float;

in vec2 vTexCoord;
uniform sampler2D uTexture;
uniform int uMaskType;       // 1: Rectangle, 2: Ellipse, 3: Linear
uniform vec2 uMaskCenter;    // Normalized (0..1)
uniform vec2 uMaskSize;      // Normalized half-extents
uniform float uFeather;      // Feather radius (0.001..0.2)
uniform int uInvert;         // 1 if inverted

out vec4 fragColor;

void main() {
    vec4 col = texture(uTexture, vTexCoord);
    vec2 d = abs(vTexCoord - uMaskCenter);
    float maskVal = 1.0;

    if (uMaskType == 1) {
        // Rectangle Mask
        vec2 edgeDist = d - uMaskSize;
        float dist = max(edgeDist.x, edgeDist.y);
        maskVal = 1.0 - smoothstep(-uFeather, 0.0, dist);
    } else if (uMaskType == 2) {
        // Ellipse Mask
        vec2 norm = d / max(uMaskSize, vec2(1e-4));
        float dist = length(norm) - 1.0;
        maskVal = 1.0 - smoothstep(-uFeather, 0.0, dist);
    } else if (uMaskType == 3) {
        // Linear Gradient Mask
        float dist = vTexCoord.x - uMaskCenter.x;
        maskVal = smoothstep(-uFeather, uFeather, dist);
    }

    if (uInvert == 1) {
        maskVal = 1.0 - maskVal;
    }

    fragColor = vec4(col.rgb, col.a * maskVal);
}
)glsl";

// Color Grading, Chromatic Aberration & Glow Filter
inline const char* FRAGMENT_SHADER_COLOR_AND_EFFECTS = R"glsl(#version 300 es
precision mediump float;

in vec2 vTexCoord;
uniform sampler2D uTexture;

// Effects Uniforms
uniform float uChromaticAberration; // 0.0 to 0.05
uniform float uBrightness;           // -1.0 to 1.0 (default 0.0)
uniform float uContrast;             // 0.0 to 2.0 (default 1.0)
uniform float uSaturation;           // 0.0 to 2.0 (default 1.0)
uniform float uTemperature;          // -1.0 (cold) to 1.0 (warm)
uniform float uVignette;             // 0.0 to 1.0 (default 0.0)

out vec4 fragColor;

void main() {
    vec2 p = vTexCoord;

    // 1. Chromatic Aberration (RGB Channel Split)
    float r = texture(uTexture, p + vec2(uChromaticAberration, 0.0)).r;
    float g = texture(uTexture, p).g;
    float b = texture(uTexture, p - vec2(uChromaticAberration, 0.0)).b;
    float a = texture(uTexture, p).a;
    vec3 color = vec3(r, g, b);

    // 2. Brightness & Contrast
    color = (color - 0.5) * uContrast + 0.5 + uBrightness;

    // 3. Saturation
    float luma = dot(color, vec3(0.299, 0.587, 0.114));
    color = mix(vec3(luma), color, uSaturation);

    // 4. Color Temperature (Warm / Cold shift)
    if (uTemperature > 0.0) {
        color.r += uTemperature * 0.1;
        color.b -= uTemperature * 0.05;
    } else {
        color.b -= uTemperature * 0.1;
        color.r += uTemperature * 0.05;
    }

    // 5. Vignette (Falloff towards screen borders)
    float dist = distance(p, vec2(0.5));
    float vig = smoothstep(0.8, 0.8 - uVignette * 0.45, dist * 1.414);
    color *= vig;

    fragColor = vec4(clamp(color, 0.0, 1.0), a);
}
)glsl";

// Velocity-Based Directional Motion Blur
inline const char* FRAGMENT_SHADER_MOTION_BLUR = R"glsl(#version 300 es
precision mediump float;

in vec2 vTexCoord;
uniform sampler2D uTexture;
uniform vec2 uVelocity; // Calculated from Bezier derivative (dx, dy)
uniform int uSamples;   // e.g. 8 or 16 samples

out vec4 fragColor;

void main() {
    if (length(uVelocity) < 1e-4) {
        fragColor = texture(uTexture, vTexCoord);
        return;
    }

    vec4 accum = vec4(0.0);
    float totalWeight = 0.0;
    int samples = clamp(uSamples, 1, 16);

    for (int i = 0; i < 16; i++) {
        if (i >= samples) break;
        float t = float(i) / float(samples - 1) - 0.5;
        vec2 offset = uVelocity * t;
        accum += texture(uTexture, vTexCoord + offset);
        totalWeight += 1.0;
    }

    fragColor = accum / totalWeight;
}
)glsl";

} // namespace motionf
