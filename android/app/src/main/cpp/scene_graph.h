#pragma once

#include "motion_math.h"
#include "camera3d.h"
#include <string>
#include <unordered_map>
#include <vector>
#include <memory>

namespace motionf {

enum class LayerType {
    Video,
    Audio,
    Text,
    Image,
    NullObject,
    Camera,
    Adjustment
};

struct LayerNode {
    std::string id;
    std::string name;
    LayerType type{LayerType::Video};
    std::string parentId; // Empty if no parent

    Vec3 position{0.0f, 0.0f, 0.0f};
    Vec3 rotation{0.0f, 0.0f, 0.0f}; // Euler: pitch (X), yaw (Y), roll (Z) in degrees
    Vec3 scale{1.0f, 1.0f, 1.0f};
    Vec3 anchorPoint{0.0f, 0.0f, 0.0f};

    float opacity{1.0f};
    bool is3D{false};
    bool isVisible{true};

    Mat4 computeLocalMatrix() const {
        // M = T(pos) * Rz(roll) * Ry(yaw) * Rx(pitch) * S(scale) * T(-anchor)
        Mat4 t = Mat4::translation(position.x, position.y, position.z);
        Mat4 r = Mat4::rotationEuler(rotation.x, rotation.y, rotation.z);
        Mat4 s = Mat4::scale(scale.x, scale.y, scale.z);
        Mat4 a = Mat4::translation(-anchorPoint.x, -anchorPoint.y, -anchorPoint.z);

        return Mat4::multiply(t, Mat4::multiply(r, Mat4::multiply(s, a)));
    }
};

class SceneGraph {
public:
    std::unordered_map<std::string, LayerNode> layers;
    Camera3D activeCamera;

    void addOrUpdateLayer(const LayerNode& node) {
        layers[node.id] = node;
    }

    void removeLayer(const std::string& id) {
        layers.erase(id);
        // Clear any child parenting pointing to the deleted layer
        for (auto& [_, l] : layers) {
            if (l.parentId == id) {
                l.parentId.clear();
            }
        }
    }

    void setParent(const std::string& childId, const std::string& parentId) {
        if (childId == parentId) return;
        // Check for cycles
        if (wouldCreateCycle(childId, parentId)) return;

        auto it = layers.find(childId);
        if (it != layers.end()) {
            it->second.parentId = parentId;
        }
    }

    void clearParent(const std::string& childId) {
        auto it = layers.find(childId);
        if (it != layers.end()) {
            it->second.parentId.clear();
        }
    }

    // Resolves world transform matrix by chaining parent transforms
    Mat4 computeWorldMatrix(const std::string& layerId) const {
        auto it = layers.find(layerId);
        if (it == layers.end()) return Mat4::makeIdentity();

        const LayerNode& node = it->second;
        Mat4 localM = node.computeLocalMatrix();

        if (node.parentId.empty()) {
            return localM;
        }

        // Parent World * Child Local
        Mat4 parentWorld = computeWorldMatrix(node.parentId);
        return Mat4::multiply(parentWorld, localM);
    }

    // Computes complete MVP matrix (Projection * View * Model_World)
    Mat4 computeFinalRenderMatrix(const std::string& layerId, float aspect) const {
        auto it = layers.find(layerId);
        if (it == layers.end()) return Mat4::makeIdentity();

        const LayerNode& node = it->second;
        Mat4 worldM = computeWorldMatrix(layerId);

        if (node.is3D) {
            Mat4 view = activeCamera.computeViewMatrix();
            Mat4 proj = activeCamera.computeProjectionMatrix(aspect);
            return Mat4::multiply(proj, Mat4::multiply(view, worldM));
        } else {
            // Standard 2D Orthographic canvas projection (-aspect..aspect, -1..1)
            // Or coordinate space normalized to viewport
            return worldM;
        }
    }

private:
    bool wouldCreateCycle(const std::string& childId, const std::string& potentialParentId) const {
        std::string curr = potentialParentId;
        int depth = 0;
        while (!curr.empty() && depth < 64) {
            if (curr == childId) return true;
            auto it = layers.find(curr);
            if (it == layers.end()) break;
            curr = it->second.parentId;
            depth++;
        }
        return false;
    }
};

} // namespace motionf
