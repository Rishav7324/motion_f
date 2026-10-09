#pragma once

#include "motion_math.h"

namespace motionf {

class Camera3D {
public:
    Vec3 position{0.0f, 0.0f, 1000.0f};
    Vec3 target{0.0f, 0.0f, 0.0f};
    Vec3 up{0.0f, 1.0f, 0.0f};
    float fovDegrees{45.0f};
    float nearClip{1.0f};
    float farClip{5000.0f};
    float zoom{1.0f};

    Camera3D() = default;

    Mat4 computeViewMatrix() const {
        return Mat4::lookAt(position, target, up);
    }

    Mat4 computeProjectionMatrix(float aspect) const {
        float effectiveFovRad = (fovDegrees / zoom) * DEG2RAD;
        return Mat4::perspective(effectiveFovRad, aspect, nearClip, farClip);
    }

    // Camera orbit around target
    void orbit(float deltaAzimuthDeg, float deltaElevationDeg) {
        Vec3 diff = position - target;
        float radius = diff.length();
        if (radius < 1e-4f) radius = 1000.0f;

        float azimuth = std::atan2(diff.x, diff.z) * RAD2DEG;
        float elevation = std::asin(std::clamp(diff.y / radius, -1.0f, 1.0f)) * RAD2DEG;

        azimuth += deltaAzimuthDeg;
        elevation = std::clamp(elevation + deltaElevationDeg, -89.0f, 89.0f);

        float azRad = azimuth * DEG2RAD;
        float elRad = elevation * DEG2RAD;

        position.x = target.x + radius * std::cos(elRad) * std::sin(azRad);
        position.y = target.y + radius * std::sin(elRad);
        position.z = target.z + radius * std::cos(elRad) * std::cos(azRad);
    }

    // Camera pan in view space
    void pan(float deltaX, float deltaY) {
        Vec3 f = (target - position).normalized();
        Vec3 right = f.cross(up).normalized();
        Vec3 actualUp = right.cross(f);

        Vec3 shift = right * deltaX + actualUp * deltaY;
        position = position + shift;
        target = target + shift;
    }

    // Dolly / zoom along view direction
    void dolly(float deltaDistance) {
        Vec3 dir = (target - position).normalized();
        position = position + dir * deltaDistance;
    }
};

} // namespace motionf
