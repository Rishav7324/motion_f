import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../editor_screen.dart';

class ProjectSetupModal extends StatefulWidget {
  const ProjectSetupModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14151B),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ProjectSetupModal(),
    );
  }

  @override
  State<ProjectSetupModal> createState() => _ProjectSetupModalState();
}

class _ProjectSetupModalState extends State<ProjectSetupModal> {
  late TextEditingController _nameController;
  CanvasAspectRatio _selectedRatio = CanvasAspectRatio.vertical9_16;
  int _selectedFps = 60;
  String _selectedRes = "1080p";

  @override
  void initState() {
    super.initState();
    final date = DateTime.now();
    _nameController = TextEditingController(text: "MotionF_${date.month}${date.day}_${date.hour}${date.minute}");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.read<ProjectManager>();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_box, color: Color(0xFF00E5FF), size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "New Project Setup",
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
          const SizedBox(height: 16),

          // Project Name Input
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Project Name",
              labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF1E2028),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Canvas Aspect Ratio
          const Text(
            "ASPECT RATIO",
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRatioCard("9:16", "TikTok / Reels", Icons.stay_current_portrait, CanvasAspectRatio.vertical9_16),
                const SizedBox(width: 10),
                _buildRatioCard("16:9", "YouTube", Icons.stay_current_landscape, CanvasAspectRatio.landscape16_9),
                const SizedBox(width: 10),
                _buildRatioCard("1:1", "Square", Icons.crop_square, CanvasAspectRatio.square1_1),
                const SizedBox(width: 10),
                _buildRatioCard("4:5", "IG Portrait", Icons.photo_size_select_actual, CanvasAspectRatio.ratio4_5),
                const SizedBox(width: 10),
                _buildRatioCard("21:9", "Cinema", Icons.movie, CanvasAspectRatio.ratio21_9),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Frame Rate & Resolution Row
          Row(
            children: [
              // Frame Rate
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("FRAME RATE", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChoiceChip("30 fps", _selectedFps == 30, () => setState(() => _selectedFps = 30)),
                        const SizedBox(width: 6),
                        _buildChoiceChip("60 fps", _selectedFps == 60, () => setState(() => _selectedFps = 60)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Resolution
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("RESOLUTION", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChoiceChip("1080p", _selectedRes == "1080p", () => setState(() => _selectedRes = "1080p")),
                        const SizedBox(width: 6),
                        _buildChoiceChip("4K UHD", _selectedRes == "4K", () => setState(() => _selectedRes = "4K")),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // CTA Create Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.movie_creation, size: 20),
              label: const Text(
                "Create Project & Open Editor",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final proj = manager.createNewProject(
                  name: _nameController.text.trim().isEmpty ? "MotionF Project" : _nameController.text.trim(),
                  aspectRatio: _selectedRatio,
                  fps: _selectedFps,
                );
                Navigator.pop(context); // close modal
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditorScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioCard(String ratio, String label, IconData icon, CanvasAspectRatio target) {
    final isSel = _selectedRatio == target;
    return GestureDetector(
      onTap: () => setState(() => _selectedRatio = target),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 90,
        height: 85,
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF00E5FF).withOpacity(0.15) : const Color(0xFF1E2028),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSel ? const Color(0xFF00E5FF) : Colors.white12,
            width: isSel ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSel ? const Color(0xFF00E5FF) : Colors.white60, size: 24),
            const SizedBox(height: 4),
            Text(
              ratio,
              style: TextStyle(color: isSel ? Colors.white : Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: isSel ? const Color(0xFF00E5FF) : Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSel, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFF00E5FF) : const Color(0xFF1E2028),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.black : Colors.white70,
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
