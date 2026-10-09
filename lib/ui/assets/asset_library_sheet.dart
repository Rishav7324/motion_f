import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class AssetLibrarySheet extends StatelessWidget {
  final ProjectModel project;

  const AssetLibrarySheet({super.key, required this.project});

  static void show(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181920),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AssetLibrarySheet(project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_AssetElement> elements = const [
      _AssetElement("YouTube Subscribe Button", "Green Screen Element", Icons.play_circle_fill, Color(0xFFFF1744), true),
      _AssetElement("Cinematic Fire Explosion", "Green Screen VFX", Icons.local_fire_department, Color(0xFFFF9100), true),
      _AssetElement("Neon Cyberpunk Arrows", "Motion Graphic Overlay", Icons.navigation, Color(0xFF00E5FF), true),
      _AssetElement("Vintage 8mm Film Grain", "Texture Overlay (Blend Mode)", Icons.movie_filter, Color(0xFFFFD600), false),
      _AssetElement("VHS Tape Glitch Distortion", "Screen Blend Overlay", Icons.tv, Color(0xFFD500F9), false),
      _AssetElement("Prism Light Leak", "Screen Blend Glow", Icons.wb_sunny, Color(0xFF00E676), false),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Color(0xFFD500F9), size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Stock Elements & VFX Library",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: elements.length,
              itemBuilder: (context, index) {
                final item = elements[index];
                return GestureDetector(
                  onTap: () {
                    final layer = LayerItem(
                      id: "elem_${DateTime.now().millisecondsSinceEpoch}",
                      name: item.title,
                      type: LayerType.video,
                      startTime: project.playheadTime,
                      duration: 5.0,
                      trackIndex: 0,
                      layerColor: item.color,
                      chromaKeyEnabled: item.isGreenScreen,
                      chromaKeyColor: const Color(0xFF00FF00),
                      blendMode: item.isGreenScreen ? LayerBlendMode.normal : LayerBlendMode.screen,
                    );
                    project.addLayer(layer);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFFD500F9),
                        content: Text("Added '${item.title}' element to timeline!"),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22232C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item.icon, color: item.color, size: 22),
                            ),
                            if (item.isGreenScreen)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text("CHROMA", style: TextStyle(color: Color(0xFF00E676), fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.category,
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AssetElement {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final bool isGreenScreen;

  const _AssetElement(this.title, this.category, this.icon, this.color, this.isGreenScreen);
}
