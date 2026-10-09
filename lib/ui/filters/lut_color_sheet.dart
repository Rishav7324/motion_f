import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class LutColorSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const LutColorSheet({
    super.key,
    required this.layer,
    required this.project,
  });

  static void show(BuildContext context, LayerItem layer, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141519),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LutColorSheet(layer: layer, project: project),
    );
  }

  @override
  State<LutColorSheet> createState() => _LutColorSheetState();
}

class _LutColorSheetState extends State<LutColorSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _lutPresets = [
    {"name": "Original", "id": "None", "color": Colors.grey, "desc": "Neutral standard"},
    {"name": "Teal & Orange", "id": "Teal & Orange", "color": const Color(0xFF00E5FF), "desc": "Hollywood blockbuster"},
    {"name": "Cyberpunk", "id": "Cyberpunk", "color": const Color(0xFFD500F9), "desc": "Neon high-saturation glow"},
    {"name": "Kodachrome", "id": "Kodachrome", "color": const Color(0xFFFF6D00), "desc": "Vintage 35mm film warm"},
    {"name": "Golden Hour", "id": "Golden Hour", "color": const Color(0xFFFFD600), "desc": "Warm sunlight amber"},
    {"name": "Moody Noir", "id": "Moody Noir", "color": const Color(0xFF9E9E9E), "desc": "High contrast B&W film"},
    {"name": "Warm Sunset", "id": "Warm Sunset", "color": const Color(0xFFFF3D00), "desc": "Deep dusk hues"},
    {"name": "Pastel Dream", "id": "Pastel Dream", "color": const Color(0xFFF48FB1), "desc": "Soft lifted shadows"},
    {"name": "Matrix Emerald", "id": "Matrix Emerald", "color": const Color(0xFF00E676), "desc": "Futuristic greenish tint"},
    {"name": "Retro VHS", "id": "Retro VHS", "color": const Color(0xFF7C4DFF), "desc": "80s analog nostalgia"},
    {"name": "Clean Portrait", "id": "Clean Portrait", "color": const Color(0xFFFFAB91), "desc": "Flattering skin tones"},
    {"name": "Bleach Bypass", "id": "Bleach Bypass", "color": const Color(0xFFB0BEC5), "desc": "Desaturated gritty film"},
  ];

  final List<String> _hslColors = ["Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Purple", "Magenta"];
  String _selectedHslColor = "Red";

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
      height: 520,
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
                Row(
                  children: [
                    const Icon(Icons.palette_outlined, color: Color(0xFF00E5FF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Color Grading & LUTs • ${widget.layer.name}",
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      widget.layer.lutPreset = "None";
                      widget.layer.lutIntensity = 1.0;
                      widget.layer.exposure = 0.0;
                      widget.layer.brightness = 0.0;
                      widget.layer.contrast = 1.0;
                      widget.layer.saturation = 1.0;
                      widget.layer.vibrance = 0.0;
                      widget.layer.temperature = 0.0;
                      widget.layer.tint = 0.0;
                      widget.layer.vignette = 0.0;
                      widget.layer.sharpen = 0.0;
                    });
                    widget.project.notifyListeners();
                  },
                  child: const Text("Reset All", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF00E5FF),
            labelColor: const Color(0xFF00E5FF),
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: "3D LUT Filters"),
              Tab(text: "Master Adjust"),
              Tab(text: "HSL Selective"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLutTab(),
                _buildAdjustTab(),
                _buildHslTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLutTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Intensity Slider if LUT selected
        if (widget.layer.lutPreset != "None") ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("LUT Strength", style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  "${(widget.layer.lutIntensity * 100).toInt()}%",
                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Slider(
            value: widget.layer.lutIntensity,
            min: 0.0,
            max: 1.0,
            activeColor: const Color(0xFF00E5FF),
            onChanged: (val) {
              setState(() => widget.layer.lutIntensity = val);
              widget.project.notifyListeners();
            },
          ),
        ],

        // 3D LUT Presets Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
            ),
            itemCount: _lutPresets.length,
            itemBuilder: (context, idx) {
              final lut = _lutPresets[idx];
              final isSelected = widget.layer.lutPreset == lut["id"];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.layer.lutPreset = lut["id"];
                  });
                  widget.project.notifyListeners();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2028),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00E5FF) : Colors.white10,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: (lut["color"] as Color).withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lut["name"] as String,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF00E5FF) : Colors.white,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        _buildSlider(
          label: "Exposure",
          value: widget.layer.exposure,
          min: -2.0,
          max: 2.0,
          displayValue: widget.layer.exposure.toStringAsFixed(2),
          onChanged: (v) => setState(() => widget.layer.exposure = v),
        ),
        _buildSlider(
          label: "Contrast",
          value: widget.layer.contrast,
          min: 0.2,
          max: 2.0,
          displayValue: "${(widget.layer.contrast * 100).toInt()}%",
          onChanged: (v) => setState(() => widget.layer.contrast = v),
        ),
        _buildSlider(
          label: "Highlights",
          value: widget.layer.highlights,
          min: -1.0,
          max: 1.0,
          displayValue: widget.layer.highlights.toStringAsFixed(2),
          onChanged: (v) => setState(() => widget.layer.highlights = v),
        ),
        _buildSlider(
          label: "Shadows",
          value: widget.layer.shadows,
          min: -1.0,
          max: 1.0,
          displayValue: widget.layer.shadows.toStringAsFixed(2),
          onChanged: (v) => setState(() => widget.layer.shadows = v),
        ),
        _buildSlider(
          label: "Saturation",
          value: widget.layer.saturation,
          min: 0.0,
          max: 2.0,
          displayValue: "${(widget.layer.saturation * 100).toInt()}%",
          onChanged: (v) => setState(() => widget.layer.saturation = v),
        ),
        _buildSlider(
          label: "Vibrance",
          value: widget.layer.vibrance,
          min: -1.0,
          max: 1.0,
          displayValue: widget.layer.vibrance.toStringAsFixed(2),
          onChanged: (v) => setState(() => widget.layer.vibrance = v),
        ),
        _buildSlider(
          label: "Temperature (Warm/Cool)",
          value: widget.layer.temperature,
          min: -1.0,
          max: 1.0,
          displayValue: widget.layer.temperature.toStringAsFixed(2),
          onChanged: (v) => setState(() => widget.layer.temperature = v),
        ),
        _buildSlider(
          label: "Tint (Green/Magenta)",
          value: widget.layer.tint,
          min: -1.0,
          max: 1.0,
          displayValue: widget.layer.tint.toStringAsFixed(2),
          onChanged: (v) => setState(() => widget.layer.tint = v),
        ),
        _buildSlider(
          label: "Sharpen",
          value: widget.layer.sharpen,
          min: 0.0,
          max: 1.0,
          displayValue: "${(widget.layer.sharpen * 100).toInt()}%",
          onChanged: (v) => setState(() => widget.layer.sharpen = v),
        ),
        _buildSlider(
          label: "Vignette",
          value: widget.layer.vignette,
          min: 0.0,
          max: 1.0,
          displayValue: "${(widget.layer.vignette * 100).toInt()}%",
          onChanged: (v) => setState(() => widget.layer.vignette = v),
        ),
      ],
    );
  }

  Widget _buildHslTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Color Swatches Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _hslColors.map((colorName) {
              final isSel = _selectedHslColor == colorName;
              final col = _getSwatchColor(colorName);

              return GestureDetector(
                onTap: () => setState(() => _selectedHslColor = colorName),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? col.withOpacity(0.3) : const Color(0xFF1E2028),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel ? col : Colors.white12,
                      width: isSel ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        colorName,
                        style: TextStyle(
                          color: isSel ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // HSL 3 Tuning Sliders
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildSlider(
                label: "$_selectedHslColor Hue Shift",
                value: 0.0,
                min: -180.0,
                max: 180.0,
                displayValue: "0°",
                onChanged: (_) {},
              ),
              _buildSlider(
                label: "$_selectedHslColor Saturation",
                value: 1.0,
                min: 0.0,
                max: 2.0,
                displayValue: "100%",
                onChanged: (_) {},
              ),
              _buildSlider(
                label: "$_selectedHslColor Luminance",
                value: 0.0,
                min: -1.0,
                max: 1.0,
                displayValue: "0.00",
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(
              displayValue,
              style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: const Color(0xFF00E5FF),
          inactiveColor: Colors.white12,
          onChanged: (v) {
            onChanged(v);
            widget.project.notifyListeners();
          },
        ),
      ],
    );
  }

  Color _getSwatchColor(String name) {
    switch (name) {
      case "Red":
        return const Color(0xFFFF1744);
      case "Orange":
        return const Color(0xFFFF9100);
      case "Yellow":
        return const Color(0xFFFFEA00);
      case "Green":
        return const Color(0xFF00E676);
      case "Cyan":
        return const Color(0xFF00E5FF);
      case "Blue":
        return const Color(0xFF2979FF);
      case "Purple":
        return const Color(0xFFD500F9);
      case "Magenta":
        return const Color(0xFFFF4081);
      default:
        return Colors.white;
    }
  }
}
