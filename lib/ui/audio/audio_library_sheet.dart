import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class AudioLibrarySheet extends StatefulWidget {
  final ProjectModel project;

  const AudioLibrarySheet({super.key, required this.project});

  static void show(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181920),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AudioLibrarySheet(project: project),
    );
  }

  @override
  State<AudioLibrarySheet> createState() => _AudioLibrarySheetState();
}

class _AudioLibrarySheetState extends State<AudioLibrarySheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_SoundItem> _bgmList = const [
    _SoundItem("Cyberpunk Neon Drive", "Synthwave • High Energy", "03:15", Color(0xFF00E5FF)),
    _SoundItem("Lofi Midnight Coffee", "Chill Beats • Relaxing", "02:40", Color(0xFFFF9100)),
    _SoundItem("Epic Cinematic Horizon", "Orchestral • Dramatic", "02:10", Color(0xFFD500F9)),
    _SoundItem("Acoustic Sunrise", "Indie Folk • Gentle", "01:55", Color(0xFF00E676)),
  ];

  final List<_SoundItem> _sfxList = const [
    _SoundItem("Cinematic Whip Whoosh", "Transition SFX", "00:01", Color(0xFF00E5FF)),
    _SoundItem("Cyberpunk Digital Glitch", "Glitch Distortion", "00:02", Color(0xFFFF1744)),
    _SoundItem("Deep Sub Bass Drop", "Impact & Boom", "00:03", Color(0xFFD500F9)),
    _SoundItem("Vintage Camera Shutter", "Mechanical Click", "00:01", Color(0xFFFFD600)),
    _SoundItem("Pop Notification Ping", "UI Sound Effect", "00:01", Color(0xFF00E676)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.audiotrack, color: Color(0xFF00E676), size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Audio & Sound Effects Library",
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

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF00E676),
            labelColor: const Color(0xFF00E676),
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: "Music (BGM)"),
              Tab(text: "Sound Effects (SFX)"),
            ],
          ),
          const SizedBox(height: 12),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSoundList(_bgmList, isMusic: true),
                _buildSoundList(_sfxList, isMusic: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundList(List<_SoundItem> list, {required bool isMusic}) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF22232C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(isMusic ? Icons.music_note : Icons.graphic_eq, color: item.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${item.subtitle} • ${item.duration}",
                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Use", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final newAudio = LayerItem(
                    id: "audio_${DateTime.now().millisecondsSinceEpoch}",
                    name: item.title,
                    type: LayerType.audio,
                    startTime: widget.project.playheadTime,
                    duration: isMusic ? 8.0 : 2.0,
                    trackIndex: 1,
                    layerColor: item.color,
                  );
                  widget.project.addLayer(newAudio);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF00E676),
                      content: Text("Added '${item.title}' to audio track!"),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SoundItem {
  final String title;
  final String subtitle;
  final String duration;
  final Color color;

  const _SoundItem(this.title, this.subtitle, this.duration, this.color);
}
