import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class TextStylingSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const TextStylingSheet({
    super.key,
    required this.layer,
    required this.project,
  });

  static void show(BuildContext context, LayerItem layer, ProjectModel project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181920),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TextStylingSheet(layer: layer, project: project),
    );
  }

  @override
  State<TextStylingSheet> createState() => _TextStylingSheetState();
}

class _TextStylingSheetState extends State<TextStylingSheet> {
  late TextEditingController _textController;

  final List<Color> _palette = const [
    Colors.white,
    Colors.black,
    Color(0xFF00E5FF), // Cyan
    Color(0xFFFFD600), // Yellow
    Color(0xFFFF1744), // Red
    Color(0xFFD500F9), // Purple
    Color(0xFF00E676), // Green
    Color(0xFFFF9100), // Orange
  ];

  final List<String> _fonts = const [
    "sans-serif",
    "serif",
    "monospace",
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.layer.textContent);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final project = widget.project;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 28),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: ListView(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.text_fields, color: Color(0xFFFF9100), size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Text Styling & Typography",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

          // 1. Text Content Input
          TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "Text Content",
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF141519),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              setState(() => layer.textContent = val);
              project.notifyListeners();
            },
          ),
          const SizedBox(height: 16),

          // 2. Font Size Slider
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Font Size", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(
                child: Slider(
                  value: layer.fontSize.clamp(12.0, 72.0),
                  min: 12.0,
                  max: 72.0,
                  activeColor: const Color(0xFFFF9100),
                  inactiveColor: Colors.white24,
                  onChanged: (val) {
                    setState(() => layer.fontSize = val);
                    project.notifyListeners();
                  },
                ),
              ),
              SizedBox(
                width: 40,
                child: Text("${layer.fontSize.toInt()}pt", style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ),

          // 3. Font Family Selector
          Row(
            children: [
              const SizedBox(width: 80, child: Text("Font Family", style: TextStyle(color: Colors.white70, fontSize: 12))),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: _fonts.map((f) {
                    final isSel = layer.textFontFamily == f;
                    return ChoiceChip(
                      label: Text(f, style: TextStyle(fontFamily: f, fontSize: 11)),
                      selected: isSel,
                      selectedColor: const Color(0xFFFF9100),
                      backgroundColor: const Color(0xFF22232C),
                      labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white70),
                      onSelected: (sel) {
                        if (sel) {
                          setState(() => layer.textFontFamily = f);
                          project.notifyListeners();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Text Color Palette
          const Text("TEXT COLOR", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _palette.map((c) {
              final isSel = layer.textColor.value == c.value;
              return GestureDetector(
                onTap: () {
                  setState(() => layer.textColor = c);
                  project.notifyListeners();
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSel ? Colors.white : Colors.white24, width: isSel ? 3 : 1),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),

          // 5. Stroke / Outline Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Text Outline / Stroke", style: TextStyle(color: Colors.white, fontSize: 13)),
            value: layer.hasTextStroke,
            activeColor: const Color(0xFFFF9100),
            onChanged: (val) {
              setState(() => layer.hasTextStroke = val);
              project.notifyListeners();
            },
          ),
          if (layer.hasTextStroke) ...[
            Row(
              children: [
                const SizedBox(width: 80, child: Text("Width", style: TextStyle(color: Colors.white70, fontSize: 12))),
                Expanded(
                  child: Slider(
                    value: layer.textStrokeWidth.clamp(1.0, 10.0),
                    min: 1.0,
                    max: 10.0,
                    activeColor: const Color(0xFFFF9100),
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      setState(() => layer.textStrokeWidth = val);
                      project.notifyListeners();
                    },
                  ),
                ),
                Text("${layer.textStrokeWidth.toInt()}px", style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ],

          // 6. Glow / Shadow Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Text Shadow & Glow", style: TextStyle(color: Colors.white, fontSize: 13)),
            value: layer.hasTextShadow,
            activeColor: const Color(0xFF00E5FF),
            onChanged: (val) {
              setState(() => layer.hasTextShadow = val);
              project.notifyListeners();
            },
          ),
          if (layer.hasTextShadow) ...[
            Row(
              children: [
                const SizedBox(width: 80, child: Text("Blur Radius", style: TextStyle(color: Colors.white70, fontSize: 12))),
                Expanded(
                  child: Slider(
                    value: layer.textShadowBlur.clamp(2.0, 30.0),
                    min: 2.0,
                    max: 30.0,
                    activeColor: const Color(0xFF00E5FF),
                    inactiveColor: Colors.white24,
                    onChanged: (val) {
                      setState(() => layer.textShadowBlur = val);
                      project.notifyListeners();
                    },
                  ),
                ),
                Text("${layer.textShadowBlur.toInt()}px", style: const TextStyle(color: Colors.white, fontSize: 11)),
              ],
            ),
          ],

          // 7. Background Banner
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Highlight Background Box", style: TextStyle(color: Colors.white, fontSize: 13)),
            value: layer.hasTextBackground,
            activeColor: const Color(0xFFFF9100),
            onChanged: (val) {
              setState(() => layer.hasTextBackground = val);
              project.notifyListeners();
            },
          ),
        ],
      ),
    );
  }
}
