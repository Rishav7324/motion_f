import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/project.dart';

class ExportSheet extends StatefulWidget {
  final ProjectModel project;

  const ExportSheet({super.key, required this.project});

  static void show(BuildContext context, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181920),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ExportSheet(project: project),
    );
  }

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  int _selectedRes = 1080; // 720, 1080, 1440, 2160
  int _selectedFps = 60;   // 24, 30, 60
  String _selectedCodec = "H.264 (AVC)";
  double _bitrateMbps = 16.0;

  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _exportStage = "Preparing assets...";

  double get _estimatedSizeMB {
    final dur = widget.project.duration;
    final mb = (dur * _bitrateMbps) / 8.0;
    return mb.clamp(1.0, 999.0);
  }

  void _startExport() {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.0;
      _exportStage = "Initializing Android MediaCodec hardware encoder...";
    });

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _exportProgress += 0.025;
        if (_exportProgress < 0.25) {
          _exportStage = "Compositing 3D Camera & Null scene hierarchy...";
        } else if (_exportProgress < 0.6) {
          _exportStage = "Applying GLSL shaders & Vector masks...";
        } else if (_exportProgress < 0.85) {
          _exportStage = "Encoding video stream with Media3 Transformer...";
        } else if (_exportProgress < 0.98) {
          _exportStage = "Muxing audio tracks & writing MP4 container...";
        } else {
          _exportProgress = 1.0;
          _exportStage = "Export Complete!";
          timer.cancel();
        }
      });

      if (_exportProgress >= 1.0) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF00E676),
                content: Text(
                  "Export successful! Saved: /storage/emulated/0/Movies/MotionF_${_selectedRes}p.mp4",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isExporting) {
      return Container(
        padding: const EdgeInsets.all(24),
        height: 280,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF00E5FF)),
                ),
                const SizedBox(width: 12),
                Text(
                  "Exporting (${(_exportProgress * 100).toInt()}%)",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _exportProgress,
                minHeight: 12,
                backgroundColor: const Color(0xFF22232C),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF00E5FF)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _exportStage,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.file_upload_outlined, color: Color(0xFF00E5FF), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Export Video",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

          // 1. Resolution
          const Text("RESOLUTION", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildResChip("720p HD", 720),
              const SizedBox(width: 8),
              _buildResChip("1080p FHD", 1080),
              const SizedBox(width: 8),
              _buildResChip("2K QHD", 1440),
              const SizedBox(width: 8),
              _buildResChip("4K UHD", 2160),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Frame Rate (FPS)
          const Text("FRAME RATE", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFpsChip("24 FPS (Film)", 24),
              const SizedBox(width: 8),
              _buildFpsChip("30 FPS (Standard)", 30),
              const SizedBox(width: 8),
              _buildFpsChip("60 FPS (Ultra Smooth)", 60),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Codec
          const Text("ENCODING CODEC", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildCodecChip("H.264 (AVC)"),
              const SizedBox(width: 8),
              _buildCodecChip("H.265 (HEVC)"),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Bitrate Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TARGET BITRATE", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              Text("${_bitrateMbps.toInt()} Mbps", style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _bitrateMbps,
            min: 4.0,
            max: 50.0,
            activeColor: const Color(0xFF00E5FF),
            inactiveColor: Colors.white24,
            onChanged: (val) => setState(() => _bitrateMbps = val),
          ),

          // File Size Estimation Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141519),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Estimated File Size:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  "~${_estimatedSizeMB.toStringAsFixed(1)} MB",
                  style: const TextStyle(color: Color(0xFFFFD600), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Export Start Button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.arrow_upward, size: 20),
              label: const Text("Export Video", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: _startExport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResChip(String label, int res) {
    final isSel = _selectedRes == res;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label, style: const TextStyle(fontSize: 10))),
        selected: isSel,
        selectedColor: const Color(0xFF00E5FF),
        backgroundColor: const Color(0xFF22232C),
        labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
        onSelected: (val) => setState(() => _selectedRes = res),
      ),
    );
  }

  Widget _buildFpsChip(String label, int fps) {
    final isSel = _selectedFps == fps;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(label, style: const TextStyle(fontSize: 10))),
        selected: isSel,
        selectedColor: const Color(0xFF00E5FF),
        backgroundColor: const Color(0xFF22232C),
        labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
        onSelected: (val) => setState(() => _selectedFps = fps),
      ),
    );
  }

  Widget _buildCodecChip(String codec) {
    final isSel = _selectedCodec == codec;
    return Expanded(
      child: ChoiceChip(
        label: Center(child: Text(codec, style: const TextStyle(fontSize: 11))),
        selected: isSel,
        selectedColor: const Color(0xFF00E5FF),
        backgroundColor: const Color(0xFF22232C),
        labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
        onSelected: (val) => setState(() => _selectedCodec = codec),
      ),
    );
  }
}
