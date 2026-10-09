import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/keyframe.dart';
import '../../models/project.dart';

class StickersSheet extends StatefulWidget {
  final ProjectModel project;

  const StickersSheet({super.key, required this.project});

  static void show(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141519),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StickersSheet(project: project),
    );
  }

  @override
  State<StickersSheet> createState() => _StickersSheetState();
}

class _StickersSheetState extends State<StickersSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _socialStickers = [
    {"label": "🔴 SUBSCRIBE", "color": const Color(0xFFFF1744), "bg": Colors.black87, "icon": Icons.subscriptions},
    {"label": "👍 LIKE & SHARE", "color": const Color(0xFF00E5FF), "bg": const Color(0xFF003344), "icon": Icons.thumb_up},
    {"label": "🔔 NOTIFY ON", "color": const Color(0xFFFFD600), "bg": const Color(0xFF332B00), "icon": Icons.notifications_active},
    {"label": "⭐ FOLLOW", "color": const Color(0xFFD500F9), "bg": const Color(0xFF2C0036), "icon": Icons.person_add},
    {"label": "🔥 TRENDING", "color": const Color(0xFFFF6D00), "bg": const Color(0xFF331600), "icon": Icons.local_fire_department},
    {"label": "💬 COMMENT BELOW", "color": const Color(0xFF00E676), "bg": const Color(0xFF003314), "icon": Icons.chat_bubble},
  ];

  final List<Map<String, dynamic>> _vfxBadges = [
    {"label": "[CYBER HUD 2077]", "color": const Color(0xFF00E5FF), "bg": Colors.black, "icon": Icons.track_changes},
    {"label": "⚡ ENERGY OVERLOAD", "color": const Color(0xFFFFD600), "bg": Colors.black, "icon": Icons.bolt},
    {"label": "⚠️ SYSTEM ERROR", "color": const Color(0xFFFF1744), "bg": Colors.black, "icon": Icons.warning_amber},
    {"label": "✨ 4K CINEMATIC", "color": Colors.white, "bg": const Color(0xFF1B1C22), "icon": Icons.hd},
    {"label": "✦ RETRO 80s VIBE ✦", "color": const Color(0xFFFF4081), "bg": const Color(0xFF33001A), "icon": Icons.stars},
    {"label": "RECORDING ● REC", "color": const Color(0xFFFF1744), "bg": Colors.black87, "icon": Icons.fiber_manual_record},
  ];

  final List<Map<String, dynamic>> _arrowPointers = [
    {"label": "➔ LOOK HERE", "color": const Color(0xFFFFEA00), "bg": Colors.black, "icon": Icons.arrow_forward},
    {"label": "⬇ DOWNLOAD LINK", "color": const Color(0xFF00E5FF), "bg": Colors.black, "icon": Icons.arrow_downward},
    {"label": "⭐ TOP PICK", "color": const Color(0xFFFFD600), "bg": Colors.black, "icon": Icons.star},
    {"label": "✔ VERIFIED", "color": const Color(0xFF00E676), "bg": const Color(0xFF003314), "icon": Icons.check_circle},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_emotions_outlined, color: Color(0xFFFFEA00), size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Stickers & Motion Badges",
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFFEA00),
            labelColor: const Color(0xFFFFEA00),
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: "Social CTA"),
              Tab(text: "VFX Badges"),
              Tab(text: "Pointers"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(_socialStickers),
                _buildGrid(_vfxBadges),
                _buildGrid(_arrowPointers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        final col = item["color"] as Color;
        final bg = item["bg"] as Color;

        return GestureDetector(
          onTap: () {
            _addStickerLayer(item);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Added \"${item['label']}\" to timeline!"),
                backgroundColor: const Color(0xFF1B1C22),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: col.withOpacity(0.6), width: 1.5),
              boxShadow: [
                BoxShadow(color: col.withOpacity(0.15), blurRadius: 8),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item["icon"] as IconData, size: 18, color: col),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item["label"] as String,
                    style: TextStyle(
                      color: col,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addStickerLayer(Map<String, dynamic> item) {
    final startTime = widget.project.playheadTime;
    final stickerLayer = LayerItem(
      id: "sticker_${DateTime.now().millisecondsSinceEpoch}",
      name: item["label"] as String,
      type: LayerType.text,
      startTime: startTime,
      duration: 3.5,
      trackIndex: 2,
      textContent: item["label"] as String,
      fontSize: 26.0,
      textColor: item["color"] as Color,
      hasTextBackground: true,
      textBackgroundColor: (item["bg"] as Color).withOpacity(0.85),
      hasTextShadow: true,
      textShadowColor: item["color"] as Color,
      textShadowBlur: 15.0,
      layerColor: item["color"] as Color,
    );

    // Add pop-in bounce animation
    stickerLayer.scaleX.addKeyframe(Keyframe(time: startTime, value: 0.2, easeType: KeyframeEase.easeOut));
    stickerLayer.scaleX.addKeyframe(Keyframe(time: startTime + 0.35, value: 1.15, easeType: KeyframeEase.easeInOut));
    stickerLayer.scaleX.addKeyframe(Keyframe(time: startTime + 0.5, value: 1.0, easeType: KeyframeEase.easeInOut));

    stickerLayer.scaleY.addKeyframe(Keyframe(time: startTime, value: 0.2, easeType: KeyframeEase.easeOut));
    stickerLayer.scaleY.addKeyframe(Keyframe(time: startTime + 0.35, value: 1.15, easeType: KeyframeEase.easeInOut));
    stickerLayer.scaleY.addKeyframe(Keyframe(time: startTime + 0.5, value: 1.0, easeType: KeyframeEase.easeInOut));

    widget.project.addLayer(stickerLayer);
  }
}
