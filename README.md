# 🎬 MotionF (Mobile Motion Graphics & Video Compositor)

**MotionF** is an advanced mobile video editing and motion graphics application for Android. It fuses the rapid, tactile, gesture-driven UI/UX of **CapCut** with the professional compositing capabilities of **Adobe After Effects** (3D Camera, Null Objects, Hierarchical Parenting, Bezier Speed/Value Curve Graph Editor, Shaders, and Blend Modes).

---

## 🏗️ Multi-Tier Architecture

To achieve silky-smooth 60fps mobile timeline scrubbing with complex compositing math, MotionF divides responsibilities across three specialized layers:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   1. FLUTTER (UI / UX & Presentation)                  │
│  CapCut Dark Theme • Pinch-to-Zoom Magnetic Timeline • 3D Gizmo       │
│  Interactive Bezier Curve Graph Editor • Keyframe Diamond (+◇ / -◇)   │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Dart FFI & MethodChannel)
┌───────────────────────────────────▼────────────────────────────────────┐
│              2. KOTLIN / JAVA (Hardware & Android Media Layer)         │
│  MediaCodec Zero-Copy Decoders • Media3 ExoPlayer Surface Sync         │
│  EGL 1.4 Context & SurfaceTexture • FFmpeg-Kit Export Pipeline        │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (JNI Native Bridge)
┌───────────────────────────────────▼────────────────────────────────────┐
│               3. C++ NDK (Complex Math & Graphics Engine)              │
│  SIMD 4x4 Matrix Transformations • 3D Camera View & Projection         │
│  Parenting Hierarchy & Null Object Solver • Newton-Raphson Bezier Solver│
│  OpenGL ES 3.0 Multi-Layer Compositor (FBO) • GLSL Shaders & Blends    │
└────────────────────────────────────────────────────────────────────────┘
```

---

## ⚡ Core Features

### 1. After Effects Features on Mobile
* **Null Objects & Parenting**: Group and transform multiple layers together using dummy Null layers. When a layer is parented, its transformation updates in real time:
  $$\text{World Matrix} = \text{Matrix}_{\text{parent}} \times \text{Matrix}_{\text{child}}$$
* **3D Camera System**: Full 3D camera layer with Perspective Projection, View Matrix (`lookAt`), Orbit, Pan, and Dolly controls.
* **Bezier Speed & Value Curve Graph Editor**: Drag interactive tangent control handles ($P_1, P_2$) directly on a graph canvas to sculpt acceleration and deceleration, or choose from presets (*Ease In, Ease Out, Easy Ease, Flash In, Bullet*).
* **Multi-Property Keyframing**: Keyframe Position (X, Y, Z), Scale (X, Y, Z), Rotation (Pitch, Yaw, Roll), Opacity, and Camera FOV.
* **GLSL Shaders & Blend Modes**: Real-time Screen, Multiply, Overlay, Add, and Soft Light blend modes alongside GL-Transitions (Dissolve, Wipe, Zoom, Glitch) and Green Screen Chroma Key.

### 2. CapCut-Style UI / UX
* **Magnetic Pinch-to-Zoom Timeline**: Smooth horizontal pinch gestures to inspect milliseconds or overview minutes.
* **On-Screen Transform Gizmo**: Direct viewport manipulation with bounding box handles for scale, rotation knob, and 3D XYZ coordinate arrows.
* **Keyframe Diamond Controller (`+◇` / `-◇`)**: Instant visual feedback when the playhead sits on a keyframe, with jump buttons (`◀◇` / `◇▶`).
* **Contextual Bottom Dock**: Dynamic tool switching for rapid mobile editing (Split, Speed, Properties, 3D Toggle, Duplicate, Delete).

---

## 🚀 Cloud Compilation via GitHub Actions CI/CD

As configured in `.github/workflows/build-apk.yml`, you do not need local Android SDK or Flutter installed to build the APK.

### Steps to compile your APK:
1. **Push your repository to GitHub**:
   ```bash
   git add .
   git commit -m "Initial commit for MotionF"
   git remote add origin https://github.com/YOUR_USERNAME/motion_f.git
   git push -u origin main
   ```
2. **GitHub Actions automatically starts building**:
   - Spins up `ubuntu-latest` with Java 21, Android NDK r26d, CMake 3.22, and Flutter 3.24.x.
   - Compiles C++ NDK native binaries for `arm64-v8a` and `armeabi-v7a`.
   - Runs all unit tests (`flutter test`).
   - Builds release APKs.
3. **Download your APK**:
   - Go to your GitHub repository -> **Actions** tab.
   - Click on the latest workflow run: **Build MotionF Android APK**.
   - Under **Artifacts**, download:
     - `MotionF-arm64-v8a-release` (Optimized for modern Android devices)
     - `MotionF-universal-release` (Universal compatibility)
   - Install directly on your Android phone!

---

## 🧪 Local Testing

To run the Dart math and hierarchy test suite:
```bash
flutter test
```

### Verified Test Cases:
- `test/bezier_solver_test.dart`: Validates Newton-Raphson convergence, boundary clamping, and velocity curve slopes.
- `test/scene_hierarchy_test.dart`: Validates 4x4 matrix transforms, Null Object parenting, and 3D camera view matrices.
- `test/keyframe_test.dart`: Validates multi-property keyframing and interpolation.

---

## 📜 Open-Source Acknowledgments & Foundations
- **OpenEditz (formerly DoubleClips)**: Flutter timeline and cross-platform structure.
- **Olive Video Editor**: Graph Editor and Bezier interpolation architecture.
- **gl-transitions**: High-performance GLSL transition shaders.
- **AndroidX Media3**: Google's hardware-accelerated video framework.
- **FFmpeg-Kit**: Audio/Video transcoding pipeline.
