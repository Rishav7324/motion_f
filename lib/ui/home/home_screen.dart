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
      backgroundColor: const Color(0xFF0D0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13151C),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1E28),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF2C3142)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E5FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "MOTION F",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "STUDIO",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            tooltip: "Settings",
            onPressed: () => AppSettingsSheet.show(context),
          ),
        ],
      ),
      body: _buildCurrentTab(context, manager),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF13151C),
          border: Border(top: BorderSide(color: Color(0xFF20232E))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.white38,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.movie_filter_outlined), label: "Projects"),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: "VFX Elements"),
            BottomNavigationBarItem(icon: Icon(Icons.audiotrack), label: "Audio & SFX"),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab(BuildContext context, ProjectManager manager) {
    if (_currentNavIndex == 1) {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E2230),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.auto_awesome, color: Color(0xFF00E5FF)),
          label: const Text("Open Stock VFX Library"),
          onPressed: () => AssetLibrarySheet.show(context, manager.activeProject),
        ),
      );
    }
    if (_currentNavIndex == 2) {
      return Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E2230),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.audiotrack, color: Color(0xFF00E5FF)),
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
        // 1. Sleek Matte Hero Card: "+ New Project" & "Import Media"
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151720),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF242735)),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Primary "+ New Project" button
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () => ProjectSetupModal.show(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2330),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2E3448)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00E5FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.black, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "New Project",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Blank timeline & canvas",
                                    style: TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Direct Gallery / Media Import button
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        final proj = await manager.createProjectFromMedia();
                        if (proj != null && mounted) {
                          _openEditor(context, manager, proj);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1E28),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2C3244)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF00E5FF), size: 24),
                            SizedBox(height: 4),
                            Text(
                              "Import Media",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Subtle quick tools row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAction(
                    icon: Icons.aspect_ratio,
                    label: "Canvas Setup",
                    onTap: () => ProjectSetupModal.show(context),
                  ),
                  _buildQuickAction(
                    icon: Icons.video_library_outlined,
                    label: "Add Video/Photo",
                    onTap: () async {
                      final proj = await manager.createProjectFromMedia();
                      if (proj != null && mounted) {
                        _openEditor(context, manager, proj);
                      }
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.auto_awesome_outlined,
                    label: "VFX Elements",
                    onTap: () => AssetLibrarySheet.show(context, manager.activeProject),
                  ),
                  _buildQuickAction(
                    icon: Icons.audiotrack_outlined,
                    label: "Music & SFX",
                    onTap: () => AudioLibrarySheet.show(context, manager.activeProject),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. Recent Projects Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Recent Projects",
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1E28),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2B3040)),
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

        // 3. Project Cards or Clean Empty State
        if (manager.projects.isEmpty)
          _buildEmptyState(context, manager)
        else
          ...manager.projects.map((proj) => _buildProjectCard(context, manager, proj)),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ProjectManager manager) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF20232E)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1E28),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2C3244)),
              ),
              child: const Icon(Icons.movie_creation_outlined, color: Colors.white38, size: 28),
            ),
            const SizedBox(height: 14),
            const Text(
              "No Projects Yet",
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Import videos and photos or create a blank canvas to begin editing.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text(
                "Import Media to Start",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () async {
                final proj = await manager.createProjectFromMedia();
                if (proj != null && mounted) {
                  _openEditor(context, manager, proj);
                } else if (mounted) {
                  // If picker was cancelled, open project setup
                  ProjectSetupModal.show(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectManager manager, ProjectModel proj) {
    final aspectString = _formatAspect(proj.aspectRatio);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151720),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF222634)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () => _openEditor(context, manager, proj),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1E28),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2C3244)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie_outlined, color: Color(0xFF00E5FF), size: 18),
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
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
          icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
          color: const Color(0xFF1E2230),
          onSelected: (val) {
            if (val == "open") {
              _openEditor(context, manager, proj);
            } else if (val == "rename") {
              _showRenameDialog(context, manager, proj);
            } else if (val == "duplicate") {
              manager.duplicateProject(proj.id);
            } else if (val == "delete") {
              manager.deleteProject(proj.id);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: "open",
              child: Text("Open in Editor", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const PopupMenuItem(
              value: "rename",
              child: Text("Rename", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const PopupMenuItem(
              value: "duplicate",
              child: Text("Duplicate", style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const PopupMenuItem(
              value: "delete",
              child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ProjectManager manager, ProjectModel proj) {
    final controller = TextEditingController(text: proj.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF181B24),
        title: const Text("Rename Project", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Project name",
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), foregroundColor: Colors.black),
            child: const Text("Save"),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                manager.renameProject(proj.id, newName);
              }
              Navigator.pop(context);
            },
          ),
        ],
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
