#pragma once

#include <cmath>
#include <algorithm>

namespace motionf {

class BezierSolver {
public:
    // Solves for Y progress given X progress (time t in [0.0, 1.0])
    // using control points P1(x1, y1) and P2(x2, y2)
    static float evaluate(float x1, float y1, float x2, float y2, float t) {
        if (t <= 0.0f) return 0.0f;
        if (t >= 1.0f) return 1.0f;

        float u = solveUForX(x1, x2, t);
        return sampleCurve(u, y1, y2);
    }

    // Velocity (dy/dt) at time t
    static float evaluateVelocity(float x1, float y1, float x2, float y2, float t) {
        if (t <= 0.0f || t >= 1.0f) return 0.0f;
        float u = solveUForX(x1, x2, t);
        float dx = sampleDerivative(u, x1, x2);
        float dy = sampleDerivative(u, y1, y2);
        return (std::abs(dx) > 1e-6f) ? (dy / dx) : 0.0f;
    }

private:
    static float sampleCurve(float u, float p1, float p2) {
        // B(u) = 3(1-u)^2 u p1 + 3(1-u) u^2 p2 + u^3
        float oneMinusU = 1.0f - u;
        return 3.0f * oneMinusU * oneMinusU * u * p1 +
               3.0f * oneMinusU * u * u * p2 +
               u * u * u;
    }

    static float sampleDerivative(float u, float p1, float p2) {
        // B'(u) = 3(1-3u+3u^2) p1 + 3(2u-3u^2) p2 + 3u^2
        return 3.0f * (1.0f - 3.0f * u + 3.0f * u * u) * p1 +
               3.0f * (2.0f * u - 3.0f * u * u) * p2 +
               3.0f * u * u;
    }

    static float solveUForX(float x1, float x2, float targetX) {
        float u = targetX;

        // Try Newton-Raphson (up to 8 iterations)
        for (int i = 0; i < 8; ++i) {
            float currentX = sampleCurve(u, x1, x2) - targetX;
            if (std::abs(currentX) < 1e-6f) {
                return u;
            }
            float dX = sampleDerivative(u, x1, x2);
            if (std::abs(dX) < 1e-6f) {
                break;
            }
            u -= currentX / dX;
            if (u < 0.0f || u > 1.0f) {
                break;
            }
        }

        // Fallback to robust binary bisection
        float lo = 0.0f, hi = 1.0f;
        u = targetX;
        while (lo < hi) {
            float currentX = sampleCurve(u, x1, x2);
            if (std::abs(currentX - targetX) < 1e-5f) {
                return u;
            }
            if (targetX > currentX) {
                lo = u;
            } else {
                hi = u;
            }
            u = (hi + lo) * 0.5f;
        }

        return u;
    }
};

} // namespace motionf
