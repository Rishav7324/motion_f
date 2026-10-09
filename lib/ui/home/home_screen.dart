import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../editor_screen.dart';
import 'project_setup_modal.dart';
import '../settings/app_settings_sheet.dart';
import '../assets/asset_library_sheet.dart';
import '../audio/audio_library_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<ProjectManager>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D11),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14151B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "MOTION F",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFFFD600), width: 0.8),
              ),
              child: const Text(
                "STUDIO PRO",
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => AppSettingsSheet.show(context),
          ),
        ],
      ),
      body: _buildCurrentTab(context, manager),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF14151B),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.white54,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: "Edit"),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: "VFX Elements"),
            BottomNavigationBarItem(icon: Icon(Icons.audiotrack), label: "Audio & SFX"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab(BuildContext context, ProjectManager manager) {
    if (_currentNavIndex == 1) {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD500F9)),
          icon: const Icon(Icons.auto_awesome),
          label: const Text("Open Stock VFX Library"),
          onPressed: () => AssetLibrarySheet.show(context, manager.activeProject),
        ),
      );
    }
    if (_currentNavIndex == 2) {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
          icon: const Icon(Icons.audiotrack),
          label: const Text("Open Audio & SFX Library"),
          onPressed: () => AudioLibrarySheet.show(context, manager.activeProject),
        ),
      );
    }
    if (_currentNavIndex == 3) {
      return const Center(
        child: AppSettingsSheet(),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // 1. Big Hero "New Project" Button
        GestureDetector(
          onTap: () => ProjectSetupModal.show(context),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B4D8), Color(0xFF7209B7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -15,
                  child: Icon(Icons.add_circle, size: 130, color: Colors.white.withOpacity(0.12)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            "New Project",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Start editing with 3D Camera, Null layers, and Bezier curves",
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // 2. Quick Tools Strip
        const Text(
          "STUDIO SUITE",
          style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildToolCard("3D Camera", Icons.videocam, const Color(0xFFD500F9), () {
                ProjectSetupModal.show(context);
              }),
              const SizedBox(width: 10),
              _buildToolCard("Chroma Key", Icons.palette, const Color(0xFF00E676), () {
                _openEditor(context, manager, manager.activeProject);
              }),
              const SizedBox(width: 10),
              _buildToolCard("Speed Ramp", Icons.speed, const Color(0xFFFFD600), () {
                _openEditor(context, manager, manager.activeProject);
              }),
              const SizedBox(width: 10),
              _buildToolCard("Stock Elements", Icons.auto_awesome, const Color(0xFF00E5FF), () {
                AssetLibrarySheet.show(context, manager.activeProject);
              }),
              const SizedBox(width: 10),
              _buildToolCard("Music & SFX", Icons.audiotrack, const Color(0xFFFF9100), () {
                AudioLibrarySheet.show(context, manager.activeProject);
              }),
            ],
          ),
        ),
        const SizedBox(height: 26),

        // 3. Recent Projects Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Recent Projects",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22232C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${manager.projects.length}",
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 4. Project Cards Grid
        ...manager.projects.map((proj) => _buildProjectCard(context, manager, proj)),
      ],
    );
  }

  Widget _buildToolCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF181920),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectManager manager, ProjectModel proj) {
    final aspectString = _formatAspect(proj.aspectRatio);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181920),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        onTap: () => _openEditor(context, manager, proj),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1F2937), Color(0xFF111827)],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24, width: 0.8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie, color: Color(0xFF00E5FF), size: 18),
                const SizedBox(height: 2),
                Text(
                  aspectString,
                  style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          proj.name,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                "${proj.duration.toInt()}s • ${proj.fps}fps",
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
              const SizedBox(width: 8),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                "${proj.layers.length} layers",
                style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: const Color(0xFF22232C),
          onSelected: (val) {
            if (val == "open") {
              _openEditor(context, manager, proj);
            } else if (val == "duplicate") {
              manager.duplicateProject(proj.id);
            } else if (val == "delete") {
              manager.deleteProject(proj.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: "open", child: Text("Open in Editor", style: TextStyle(color: Colors.white, fontSize: 12))),
            const PopupMenuItem(value: "duplicate", child: Text("Duplicate", style: TextStyle(color: Colors.white, fontSize: 12))),
            const PopupMenuItem(value: "delete", child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, ProjectManager manager, ProjectModel proj) {
    manager.openProject(proj);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditorScreen()),
    );
  }

  String _formatAspect(CanvasAspectRatio ratio) {
    switch (ratio) {
      case CanvasAspectRatio.vertical9_16:
        return "9:16";
      case CanvasAspectRatio.landscape16_9:
        return "16:9";
      case CanvasAspectRatio.square1_1:
        return "1:1";
      case CanvasAspectRatio.ratio4_5:
        return "4:5";
      case CanvasAspectRatio.ratio21_9:
        return "21:9";
    }
  }
}
