import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class MaskEditorSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const MaskEditorSheet({
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
      builder: (context) => MaskEditorSheet(layer: layer, project: project),
    );
  }

  @override
  State<MaskEditorSheet> createState() => _MaskEditorSheetState();
}

class _MaskEditorSheetState extends State<MaskEditorSheet> {
  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final project = widget.project;
    final availableMatteLayers = project.layers.where((l) => l.id != layer.id).toList();

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
                children: [
                  const Icon(Icons.masks, color: Color(0xFF00E5FF), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Masks & Track Matte: ${layer.name}",
                    style: const TextStyle(
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

          // --- SECTION 1: VECTOR MASKS ---
          const SizedBox(height: 8),
          const Text(
            "VECTOR MASK",
            style: TextStyle(
              color: Color(0xFF00E5FF),
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Mask Type Segmented Row
          Wrap(
            spacing: 8,
            children: [
              _buildTypeChip("None", MaskType.none, layer.maskType),
              _buildTypeChip("Rectangle", MaskType.rectangle, layer.maskType),
              _buildTypeChip("Ellipse", MaskType.ellipse, layer.maskType),
              _buildTypeChip("Linear", MaskType.linear, layer.maskType),
            ],
          ),

          if (layer.maskType != MaskType.none) ...[
            const SizedBox(height: 14),

            // Invert Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Invert Mask", style: TextStyle(color: Colors.white, fontSize: 13)),
              value: layer.isMaskInverted,
              activeColor: const Color(0xFF00E5FF),
              onChanged: (val) {
                setState(() => layer.isMaskInverted = val);
                project.notifyListeners();
              },
            ),

            // Feather Slider
            _buildSliderRow(
              label: "Feather",
              value: layer.maskFeather,
              min: 0.0,
              max: 0.3,
              displayValue: "${(layer.maskFeather * 100).toInt()}%",
              onChanged: (val) {
                setState(() => layer.maskFeather = val);
                project.notifyListeners();
              },
            ),

            // Mask Size X
            _buildSliderRow(
              label: "Width Scale",
              value: layer.maskSizeX,
              min: 0.1,
              max: 1.0,
              displayValue: "${(layer.maskSizeX * 100).toInt()}%",
              onChanged: (val) {
                setState(() => layer.maskSizeX = val);
                project.notifyListeners();
              },
            ),

            // Mask Size Y
            _buildSliderRow(
              label: "Height Scale",
              value: layer.maskSizeY,
              min: 0.1,
              max: 1.0,
              displayValue: "${(layer.maskSizeY * 100).toInt()}%",
              onChanged: (val) {
                setState(() => layer.maskSizeY = val);
                project.notifyListeners();
              },
            ),
          ],

          const SizedBox(height: 20),
          const Divider(color: Colors.white12),

          // --- SECTION 2: TRACK MATTE (TrkMat) ---
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.layers, color: Color(0xFFFFD600), size: 18),
              SizedBox(width: 6),
              Text(
                "TRACK MATTE (TrkMat)",
                style: TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Use another layer's alpha transparency or luminance as a matte stencil.",
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 12),

          // Matte Mode Selector
          DropdownButtonFormField<TrackMatteType>(
            value: layer.trackMatte,
            dropdownColor: const Color(0xFF22232C),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: "Matte Mode",
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF141519),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(value: TrackMatteType.none, child: Text("No Track Matte (None)")),
              DropdownMenuItem(value: TrackMatteType.alpha, child: Text("Alpha Matte")),
              DropdownMenuItem(value: TrackMatteType.alphaInverted, child: Text("Alpha Inverted Matte")),
              DropdownMenuItem(value: TrackMatteType.luma, child: Text("Luma Matte")),
              DropdownMenuItem(value: TrackMatteType.lumaInverted, child: Text("Luma Inverted Matte")),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  layer.trackMatte = val;
                  if (val == TrackMatteType.none) {
                    layer.targetMatteLayerId = null;
                  } else if (layer.targetMatteLayerId == null && availableMatteLayers.isNotEmpty) {
                    layer.targetMatteLayerId = availableMatteLayers.first.id;
                  }
                });
                project.notifyListeners();
              }
            },
          ),

          if (layer.trackMatte != TrackMatteType.none) ...[
            const SizedBox(height: 12),

            // Matte Source Layer Selector
            DropdownButtonFormField<String>(
              value: availableMatteLayers.any((l) => l.id == layer.targetMatteLayerId)
                  ? layer.targetMatteLayerId
                  : (availableMatteLayers.isNotEmpty ? availableMatteLayers.first.id : null),
              dropdownColor: const Color(0xFF22232C),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: "Matte Source Layer",
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF141519),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: availableMatteLayers.map((l) {
                return DropdownMenuItem<String>(
                  value: l.id,
                  child: Text("${l.name} (${l.type.name})"),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => layer.targetMatteLayerId = val);
                project.notifyListeners();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, MaskType type, MaskType current) {
    final isSelected = type == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF00E5FF),
      backgroundColor: const Color(0xFF22232C),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => widget.layer.maskType = type);
          widget.project.notifyListeners();
        }
      },
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              activeColor: const Color(0xFF00E5FF),
              inactiveColor: Colors.white24,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
