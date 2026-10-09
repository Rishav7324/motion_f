import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/layer.dart';

class LayerPropertiesSheet extends StatelessWidget {
  final LayerItem layer;

  const LayerPropertiesSheet({super.key, required this.layer});

  static void show(BuildContext context, LayerItem layer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141519),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LayerPropertiesSheet(layer: layer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectModel>();

    // Potential parents: All other layers except self and children
    final eligibleParents = project.layers.where((l) => l.id != layer.id).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Layer Settings: ${layer.name}",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.white12),

          // 1. Parenting Selector (After Effects core feature)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.account_tree, color: Color(0xFF00E5FF)),
            title: const Text("Parent Layer (Null / Controller)", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text(
              layer.parentId != null
                  ? "Parented to: ${_getParentName(project, layer.parentId!)}"
                  : "None (World Space)",
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: DropdownButton<String?>(
              value: layer.parentId,
              dropdownColor: const Color(0xFF20222A),
              underline: const SizedBox.shrink(),
              items: [
                const DropdownMenuItem(value: null, child: Text("None", style: TextStyle(color: Colors.white))),
                ...eligibleParents.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.name, style: const TextStyle(color: Colors.white)),
                    )),
              ],
              onChanged: (newParent) {
                project.setParent(layer.id, newParent);
              },
            ),
          ),

          // 2. 3D Layer Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("3D Layer", style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text("Enable 3D position (Z), rotation, and camera parallax", style: TextStyle(color: Colors.white54, fontSize: 12)),
            secondary: const Icon(Icons.view_in_ar, color: Color(0xFFD500F9)),
            value: layer.is3D,
            activeColor: const Color(0xFFD500F9),
            onChanged: (val) {
              layer.is3D = val;
              project.notifyListeners();
            },
          ),

          // 3. Blend Mode Selector
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.layers, color: Colors.amber),
            title: const Text("Blend Mode", style: TextStyle(color: Colors.white, fontSize: 14)),
            trailing: DropdownButton<LayerBlendMode>(
              value: layer.blendMode,
              dropdownColor: const Color(0xFF20222A),
              underline: const SizedBox.shrink(),
              items: LayerBlendMode.values.map((bm) {
                return DropdownMenuItem(
                  value: bm,
                  child: Text(
                    bm.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (newBm) {
                if (newBm != null) {
                  layer.blendMode = newBm;
                  project.notifyListeners();
                }
              },
            ),
          ),

          // 4. Opacity Slider
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.opacity, color: Colors.white54, size: 20),
              const SizedBox(width: 8),
              const Text("Opacity", style: TextStyle(color: Colors.white, fontSize: 14)),
              Expanded(
                child: Slider(
                  value: layer.opacity.defaultValue,
                  min: 0.0,
                  max: 1.0,
                  activeColor: const Color(0xFF00E5FF),
                  onChanged: (v) {
                    layer.opacity.defaultValue = v;
                    project.notifyListeners();
                  },
                ),
              ),
              Text(
                "${(layer.opacity.defaultValue * 100).toInt()}%",
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getParentName(ProjectModel project, String pId) {
    try {
      return project.layers.firstWhere((l) => l.id == pId).name;
    } catch (_) {
      return "Unknown";
    }
  }
}
