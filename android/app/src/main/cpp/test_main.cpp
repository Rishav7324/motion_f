#include <iostream>
#include <cassert>
#include "motion_math.h"
#include "bezier_solver.h"
#include "scene_graph.h"
#include "camera3d.h"

using namespace motionf;

int main() {
    std::cout << "[Test 1] Testing BezierSolver..." << std::endl;
    // Linear
    float lin = BezierSolver::evaluate(0.0f, 0.0f, 1.0f, 1.0f, 0.5f);
    assert(std::abs(lin - 0.5f) < 0.01f);
    std::cout << "  Linear at 0.5: " << lin << " (PASSED)" << std::endl;

    // Ease In (0.42, 0.0, 1.0, 1.0)
    float easeInVal = BezierSolver::evaluate(0.42f, 0.0f, 1.0f, 1.0f, 0.5f);
    assert(easeInVal < 0.5f);
    std::cout << "  Ease In at 0.5: " << easeInVal << " (PASSED)" << std::endl;

    // Ease Out (0.0, 0.0, 0.58, 1.0)
    float easeOutVal = BezierSolver::evaluate(0.0f, 0.0f, 0.58f, 1.0f, 0.5f);
    assert(easeOutVal > 0.5f);
    std::cout << "  Ease Out at 0.5: " << easeOutVal << " (PASSED)" << std::endl;

    std::cout << "[Test 2] Testing Mat4 and Parenting..." << std::endl;
    SceneGraph graph;
    LayerNode nullLayer;
    nullLayer.id = "null_1";
    nullLayer.name = "Null Controller";
    nullLayer.type = LayerType::NullObject;
    nullLayer.position = {100.0f, 200.0f, 0.0f};
    graph.addOrUpdateLayer(nullLayer);

    LayerNode textLayer;
    textLayer.id = "text_1";
    textLayer.name = "Title";
    textLayer.type = LayerType::Text;
    textLayer.parentId = "null_1"; // PARENTED!
    textLayer.position = {50.0f, 30.0f, 0.0f};
    graph.addOrUpdateLayer(textLayer);

    Mat4 worldM = graph.computeWorldMatrix("text_1");
    Vec3 origin{0.0f, 0.0f, 0.0f};
    Vec3 transformed = Mat4::transformPoint(worldM, origin);

    assert(std::abs(transformed.x - 150.0f) < 0.01f);
    assert(std::abs(transformed.y - 230.0f) < 0.01f);
    std::cout << "  Child world position: (" << transformed.x << ", " << transformed.y << ") (PASSED)" << std::endl;

    std::cout << "[Test 3] Testing 3D Camera..." << std::endl;
    Camera3D cam;
    cam.position = {0.0f, 0.0f, 1000.0f};
    cam.target = {0.0f, 0.0f, 0.0f};
    Mat4 viewM = cam.computeViewMatrix();
    Vec3 camTrans = Mat4::transformPoint(viewM, origin);
    assert(std::abs(camTrans.z - (-1000.0f)) < 1.0f);
    std::cout << "  Camera view space Z: " << camTrans.z << " (PASSED)" << std::endl;

    std::cout << "\n>>> ALL C++ CORE ENGINE TESTS PASSED SUCCESSFULLY! <<<\n" << std::endl;
    return 0;
}
