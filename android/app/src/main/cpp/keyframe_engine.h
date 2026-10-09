#pragma once

#include "bezier_solver.h"
#include <vector>
#include <algorithm>
#include <string>

namespace motionf {

struct Keyframe {
    float time{0.0f};   // in seconds
    float value{0.0f};
    // Bezier curve handles normalized between this keyframe and the next
    float cp1x{0.42f};
    float cp1y{0.0f};
    float cp2x{0.58f};
    float cp2y{1.0f};

    Keyframe() = default;
    Keyframe(float t, float v, float x1 = 0.42f, float y1 = 0.0f, float x2 = 0.58f, float y2 = 1.0f)
        : time(t), value(v), cp1x(x1), cp1y(y1), cp2x(x2), cp2y(y2) {}
};

class PropertyTrack {
public:
    std::string propertyName;
    float defaultValue{0.0f};
    std::vector<Keyframe> keyframes;

    PropertyTrack() = default;
    PropertyTrack(const std::string& name, float defVal)
        : propertyName(name), defaultValue(defVal) {}

    void addOrUpdateKeyframe(const Keyframe& kf) {
        auto it = std::find_if(keyframes.begin(), keyframes.end(),
            [kf](const Keyframe& k) { return std::abs(k.time - kf.time) < 1e-4f; });

        if (it != keyframes.end()) {
            *it = kf;
        } else {
            keyframes.push_back(kf);
            std::sort(keyframes.begin(), keyframes.end(),
                [](const Keyframe& a, const Keyframe& b) { return a.time < b.time; });
        }
    }

    void removeKeyframeAt(float time) {
        keyframes.erase(
            std::remove_if(keyframes.begin(), keyframes.end(),
                [time](const Keyframe& k) { return std::abs(k.time - time) < 1e-3f; }),
            keyframes.end()
        );
    }

    bool hasKeyframeAt(float time) const {
        return std::any_of(keyframes.begin(), keyframes.end(),
            [time](const Keyframe& k) { return std::abs(k.time - time) < 0.05f; });
    }

    float evaluate(float time) const {
        if (keyframes.empty()) {
            return defaultValue;
        }
        if (keyframes.size() == 1 || time <= keyframes.front().time) {
            return keyframes.front().value;
        }
        if (time >= keyframes.back().time) {
            return keyframes.back().value;
        }

        // Binary search for surrounding keyframes
        auto it = std::upper_bound(keyframes.begin(), keyframes.end(), time,
            [](float t, const Keyframe& k) { return t < k.time; });

        const Keyframe& k2 = *it;
        const Keyframe& k1 = *(it - 1);

        float duration = k2.time - k1.time;
        if (duration < 1e-6f) return k1.value;

        float normalizedT = (time - k1.time) / duration;
        float progress = BezierSolver::evaluate(k1.cp1x, k1.cp1y, k1.cp2x, k1.cp2y, normalizedT);

        return k1.value + progress * (k2.value - k1.value);
    }
};

} // namespace motionf
