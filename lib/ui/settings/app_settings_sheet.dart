import 'package:flutter/material.dart';

class AppSettingsSheet extends StatelessWidget {
  const AppSettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14151B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AppSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.settings, color: Color(0xFF00E5FF), size: 24),
                  SizedBox(width: 10),
                  Text(
                    "Preferences & Engine Settings",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),

          // 1. Rendering Engine
          const Text("CORE ENGINE", style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("C++ SIMD / Neon Math Acceleration", style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text("Uses ARM NEON vector instructions for 4x4 matrix calculations", style: TextStyle(color: Colors.white54, fontSize: 10)),
            value: true,
            activeColor: const Color(0xFF00E5FF),
            onChanged: (val) {},
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("MediaCodec Zero-Copy Hardware Decoding", style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text("Direct GPU SurfaceTexture streaming without CPU memory copies", style: TextStyle(color: Colors.white54, fontSize: 10)),
            value: true,
            activeColor: const Color(0xFF00E5FF),
            onChanged: (val) {},
          ),
          const Divider(color: Colors.white12),

          // 2. Timeline Experience
          const Text("TIMELINE & EDITING", style: TextStyle(color: Color(0xFFFFD600), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Magnetic Snapping", style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text("Snap playhead and clip boundaries to adjacent cuts automatically", style: TextStyle(color: Colors.white54, fontSize: 10)),
            value: true,
            activeColor: const Color(0xFFFFD600),
            onChanged: (val) {},
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Haptic Feedback on Cuts & Snaps", style: TextStyle(color: Colors.white, fontSize: 13)),
            value: true,
            activeColor: const Color(0xFFFFD600),
            onChanged: (val) {},
          ),
          const Divider(color: Colors.white12),

          // 3. About MotionF
          const Text("ABOUT MOTION F", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2028),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("MotionF v1.0.1 (Release Build)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 4),
                Text(
                  "Next-generation mobile motion graphics & video compositor combining CapCut UI/UX with Adobe After Effects 3D Camera, Null Layer, Bezier Speed Curves, and GLSL Compositor.",
                  style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.4),
                ),
                SizedBox(height: 8),
                Text("Architecture: C++17 NDK • Kotlin Media3 • Flutter 3.24.x", style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontFamily: 'monospace')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
