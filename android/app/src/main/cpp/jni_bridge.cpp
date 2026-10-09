#include <jni.h>
#include <string>
#include <memory>
#include "motion_math.h"
#include "bezier_solver.h"
#include "scene_graph.h"
#include "camera3d.h"
#include "gl_compositor.h"

using namespace motionf;

static std::unique_ptr<SceneGraph> gSceneGraph;
static std::unique_ptr<GlCompositor> gCompositor;

// ============================================================================
// C API for direct Dart FFI (Zero Overhead, 60fps)
// ============================================================================
extern "C" {

__attribute__((visibility("default")))
float motionf_evaluate_bezier(float x1, float y1, float x2, float y2, float t) {
    return BezierSolver::evaluate(x1, y1, x2, y2, t);
}

__attribute__((visibility("default")))
float motionf_evaluate_bezier_velocity(float x1, float y1, float x2, float y2, float t) {
    return BezierSolver::evaluateVelocity(x1, y1, x2, y2, t);
}

__attribute__((visibility("default")))
void motionf_compute_transform_matrix(
    float px, float py, float pz,
    float pitch, float yaw, float roll,
    float sx, float sy, float sz,
    float ax, float ay, float az,
    float* outMatrix16) {
    
    Mat4 t = Mat4::translation(px, py, pz);
    Mat4 r = Mat4::rotationEuler(pitch, yaw, roll);
    Mat4 s = Mat4::scale(sx, sy, sz);
    Mat4 a = Mat4::translation(-ax, -ay, -az);

    Mat4 m = Mat4::multiply(t, Mat4::multiply(r, Mat4::multiply(s, a)));
    std::memcpy(outMatrix16, m.m, sizeof(float) * 16);
}

__attribute__((visibility("default")))
void motionf_compute_camera_matrices(
    float camX, float camY, float camZ,
    float targetX, float targetY, float targetZ,
    float fovDeg, float aspect, float nearZ, float farZ,
    float* outView16, float* outProj16) {

    Camera3D cam;
    cam.position = {camX, camY, camZ};
    cam.target = {targetX, targetY, targetZ};
    cam.fovDegrees = fovDeg;
    cam.nearClip = nearZ;
    cam.farClip = farZ;

    Mat4 view = cam.computeViewMatrix();
    Mat4 proj = cam.computeProjectionMatrix(aspect);

    std::memcpy(outView16, view.m, sizeof(float) * 16);
    std::memcpy(outProj16, proj.m, sizeof(float) * 16);
}

} // extern "C"

// ============================================================================
// JNI API for Android Kotlin / Java Bridge
// ============================================================================
extern "C" {

JNIEXPORT void JNICALL
Java_com_motionf_app_MotionFPlugin_nativeInitEngine(JNIEnv*, jobject, jint width, jint height) {
    gSceneGraph = std::make_unique<SceneGraph>();
    gCompositor = std::make_unique<GlCompositor>();
    gCompositor->init(width, height);
}

JNIEXPORT void JNICALL
Java_com_motionf_app_MotionFPlugin_nativeDestroyEngine(JNIEnv*, jobject) {
    if (gCompositor) gCompositor->cleanup();
    gCompositor.reset();
    gSceneGraph.reset();
}

JNIEXPORT jfloat JNICALL
Java_com_motionf_app_MotionFPlugin_nativeEvaluateBezier(
    JNIEnv*, jobject, jfloat x1, jfloat y1, jfloat x2, jfloat y2, jfloat t) {
    return BezierSolver::evaluate(x1, y1, x2, y2, t);
}

JNIEXPORT void JNICALL
Java_com_motionf_app_MotionFPlugin_nativeSetParent(
    JNIEnv* env, jobject, jstring childId, jstring parentId) {
    if (!gSceneGraph) return;

    const char* cId = env->GetStringUTFChars(childId, nullptr);
    const char* pId = env->GetStringUTFChars(parentId, nullptr);

    gSceneGraph->setParent(cId, pId);

    env->ReleaseStringUTFChars(childId, cId);
    env->ReleaseStringUTFChars(parentId, pId);
}

JNIEXPORT void JNICALL
Java_com_motionf_app_MotionFPlugin_nativeUpdateCamera(
    JNIEnv*, jobject,
    jfloat posX, jfloat posY, jfloat posZ,
    jfloat tgtX, jfloat tgtY, jfloat tgtZ,
    jfloat fovDeg, jfloat zoom) {
    if (!gSceneGraph) return;

    gSceneGraph->activeCamera.position = {posX, posY, posZ};
    gSceneGraph->activeCamera.target = {tgtX, tgtY, tgtZ};
    gSceneGraph->activeCamera.fovDegrees = fovDeg;
    gSceneGraph->activeCamera.zoom = zoom;
}

} // extern "C"
