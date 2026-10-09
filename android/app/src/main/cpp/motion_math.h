#pragma once

#include <cmath>
#include <cstring>
#include <algorithm>

namespace motionf {

constexpr float PI = 3.14159265358979323846f;
constexpr float DEG2RAD = PI / 180.0f;
constexpr float RAD2DEG = 180.0f / PI;

struct Vec3 {
    float x{0.0f}, y{0.0f}, z{0.0f};

    constexpr Vec3() = default;
    constexpr Vec3(float x, float y, float z) : x(x), y(y), z(z) {}

    Vec3 operator+(const Vec3& o) const { return {x + o.x, y + o.y, z + o.z}; }
    Vec3 operator-(const Vec3& o) const { return {x - o.x, y - o.y, z - o.z}; }
    Vec3 operator*(float s) const { return {x * s, y * s, z * s}; }
    Vec3 operator/(float s) const { return {x / s, y / s, z / s}; }

    float lengthSq() const { return x * x + y * y + z * z; }
    float length() const { return std::sqrt(lengthSq()); }

    Vec3 normalized() const {
        float l = length();
        return l > 1e-6f ? (*this) / l : Vec3(0, 0, 0);
    }

    float dot(const Vec3& o) const { return x * o.x + y * o.y + z * o.z; }

    Vec3 cross(const Vec3& o) const {
        return {
            y * o.z - z * o.y,
            z * o.x - x * o.z,
            x * o.y - y * o.x
        };
    }
};

struct Vec4 {
    float x{0.0f}, y{0.0f}, z{0.0f}, w{1.0f};
    constexpr Vec4() = default;
    constexpr Vec4(float x, float y, float z, float w = 1.0f) : x(x), y(y), z(z), w(w) {}
};

// 4x4 Matrix stored in column-major order for standard OpenGL ES / Vulkan
struct Mat4 {
    float m[16];

    Mat4() { identity(); }

    void identity() {
        std::memset(m, 0, sizeof(m));
        m[0] = m[5] = m[10] = m[15] = 1.0f;
    }

    static Mat4 makeIdentity() {
        Mat4 r;
        return r;
    }

    static Mat4 multiply(const Mat4& a, const Mat4& b) {
        Mat4 r;
        for (int col = 0; col < 4; ++col) {
            for (int row = 0; row < 4; ++row) {
                r.m[col * 4 + row] =
                    a.m[0 * 4 + row] * b.m[col * 4 + 0] +
                    a.m[1 * 4 + row] * b.m[col * 4 + 1] +
                    a.m[2 * 4 + row] * b.m[col * 4 + 2] +
                    a.m[3 * 4 + row] * b.m[col * 4 + 3];
            }
        }
        return r;
    }

    static Mat4 translation(float tx, float ty, float tz) {
        Mat4 r;
        r.m[12] = tx;
        r.m[13] = ty;
        r.m[14] = tz;
        return r;
    }

    static Mat4 scale(float sx, float sy, float sz) {
        Mat4 r;
        r.m[0] = sx;
        r.m[5] = sy;
        r.m[10] = sz;
        return r;
    }

    static Mat4 rotationX(float rad) {
        Mat4 r;
        float c = std::cos(rad);
        float s = std::sin(rad);
        r.m[5] = c;
        r.m[6] = s;
        r.m[9] = -s;
        r.m[10] = c;
        return r;
    }

    static Mat4 rotationY(float rad) {
        Mat4 r;
        float c = std::cos(rad);
        float s = std::sin(rad);
        r.m[0] = c;
        r.m[2] = -s;
        r.m[8] = s;
        r.m[10] = c;
        return r;
    }

    static Mat4 rotationZ(float rad) {
        Mat4 r;
        float c = std::cos(rad);
        float s = std::sin(rad);
        r.m[0] = c;
        r.m[1] = s;
        r.m[4] = -s;
        r.m[5] = c;
        return r;
    }

    static Mat4 rotationEuler(float pitchDeg, float yawDeg, float rollDeg) {
        Mat4 rx = rotationX(pitchDeg * DEG2RAD);
        Mat4 ry = rotationY(yawDeg * DEG2RAD);
        Mat4 rz = rotationZ(rollDeg * DEG2RAD);
        // Order: Roll (Z) * Yaw (Y) * Pitch (X)
        return multiply(rz, multiply(ry, rx));
    }

    static Mat4 lookAt(const Vec3& eye, const Vec3& target, const Vec3& up) {
        Vec3 f = (target - eye).normalized();
        Vec3 s = f.cross(up).normalized();
        Vec3 u = s.cross(f);

        Mat4 r;
        r.m[0] = s.x;
        r.m[4] = s.y;
        r.m[8] = s.z;

        r.m[1] = u.x;
        r.m[5] = u.y;
        r.m[9] = u.z;

        r.m[2] = -f.x;
        r.m[6] = -f.y;
        r.m[10] = -f.z;

        r.m[12] = -s.dot(eye);
        r.m[13] = -u.dot(eye);
        r.m[14] = f.dot(eye);
        return r;
    }

    static Mat4 perspective(float fovRad, float aspect, float nearZ, float farZ) {
        Mat4 r;
        std::memset(r.m, 0, sizeof(r.m));
        float tanHalfFov = std::tan(fovRad / 2.0f);
        r.m[0] = 1.0f / (aspect * tanHalfFov);
        r.m[5] = 1.0f / tanHalfFov;
        r.m[10] = -(farZ + nearZ) / (farZ - nearZ);
        r.m[11] = -1.0f;
        r.m[14] = -(2.0f * farZ * nearZ) / (farZ - nearZ);
        return r;
    }

    static Vec3 transformPoint(const Mat4& m, const Vec3& p) {
        float x = m.m[0] * p.x + m.m[4] * p.y + m.m[8] * p.z + m.m[12];
        float y = m.m[1] * p.x + m.m[5] * p.y + m.m[9] * p.z + m.m[13];
        float z = m.m[2] * p.x + m.m[6] * p.y + m.m[10] * p.z + m.m[14];
        float w = m.m[3] * p.x + m.m[7] * p.y + m.m[11] * p.z + m.m[15];
        if (std::abs(w) > 1e-6f) {
            return {x / w, y / w, z / w};
        }
        return {x, y, z};
    }
};

// Procedural physics and dynamics shake solver matching After Effects wiggle(freq, amp)
struct WiggleGenerator {
    static Vec3 evaluate(float time, float freq, float amp, int seed = 42) {
        float t = time * freq;
        float x = std::sin(t * 1.0f + seed * 1.3f) * 0.6f + std::sin(t * 2.3f + seed * 0.7f) * 0.4f;
        float y = std::cos(t * 1.1f + seed * 2.1f) * 0.6f + std::cos(t * 2.7f + seed * 1.1f) * 0.4f;
        float z = std::sin(t * 0.9f + seed * 3.4f) * 0.5f;
        return {x * amp, y * amp, z * amp};
    }
};

} // namespace motionf

