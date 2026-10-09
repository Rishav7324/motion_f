import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../models/layer.dart';
import 'layer_properties_sheet.dart';

class ActionDock extends StatelessWidget {
  const ActionDock({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectModel>();
    final selectedLayer = project.selectedLayer;

    return Container(
      height: 64,
      color: const Color(0xFF141519),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: selectedLayer != null
          ? _buildSelectedLayerTools(context, project, selectedLayer)
          : _buildGlobalTools(context, project),
    );
  }

  Widget _buildSelectedLayerTools(BuildContext context, ProjectModel project, LayerItem layer) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _buildToolBtn(
          icon: Icons.call_split,
          label: "Split",
          onTap: () => project.splitSelectedLayer(),
        ),
        _buildToolBtn(
          icon: Icons.tune,
          label: "Properties",
          onTap: () => LayerPropertiesSheet.show(context, layer),
        ),
        _buildToolBtn(
          icon: Icons.view_in_ar,
          label: layer.is3D ? "3D (On)" : "3D (Off)",
          color: layer.is3D ? const Color(0xFFD500F9) : Colors.white70,
          onTap: () {
            layer.is3D = !layer.is3D;
            project.notifyListeners();
          },
        ),
        _buildToolBtn(
          icon: Icons.copy,
          label: "Duplicate",
          onTap: () {
            final clone = LayerItem(
              id: "layer_${DateTime.now().millisecondsSinceEpoch}",
              name: "${layer.name} (Copy)",
              type: layer.type,
              startTime: layer.startTime + 0.5,
              duration: layer.duration,
              trackIndex: (layer.trackIndex + 1) % 4,
              is3D: layer.is3D,
              parentId: layer.parentId,
              textContent: layer.textContent,
              layerColor: layer.layerColor,
            );
            project.addLayer(clone);
          },
        ),
        _buildToolBtn(
          icon: Icons.delete_outline,
          label: "Delete",
          color: Colors.redAccent,
          onTap: () => project.removeLayer(layer.id),
        ),
        _buildToolBtn(
          icon: Icons.check,
          label: "Deselect",
          onTap: () => project.selectLayer(null),
        ),
      ],
    );
  }

  Widget _buildGlobalTools(BuildContext context, ProjectModel project) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _buildToolBtn(
          icon: Icons.video_call,
          label: "+ Video",
          onTap: () {
            project.addLayer(LayerItem(
              id: "video_${DateTime.now().millisecondsSinceEpoch}",
              name: "Video Clip ${project.layers.length + 1}",
              type: LayerType.video,
              startTime: project.playheadTime,
              duration: 5.0,
              trackIndex: 0,
            ));
          },
        ),
        _buildToolBtn(
          icon: Icons.title,
          label: "+ Text",
          onTap: () {
            project.addLayer(LayerItem(
              id: "text_${DateTime.now().millisecondsSinceEpoch}",
              name: "Text Layer",
              type: LayerType.text,
              startTime: project.playheadTime,
              duration: 4.0,
              trackIndex: 2,
              textContent: "NEW TITLE",
            ));
          },
        ),
        _buildToolBtn(
          icon: Icons.control_camera,
          label: "+ Null Object",
          color: const Color(0xFFFF1744),
          onTap: () {
            project.addLayer(LayerItem(
              id: "null_${DateTime.now().millisecondsSinceEpoch}",
              name: "Null ${project.layers.where((l) => l.type == LayerType.nullObject).length + 1}",
              type: LayerType.nullObject,
              startTime: project.playheadTime,
              duration: 8.0,
              trackIndex: 1,
              is3D: true,
            ));
          },
        ),
        _buildToolBtn(
          icon: Icons.videocam,
          label: "+ 3D Camera",
          color: const Color(0xFFD500F9),
          onTap: () {
            project.addLayer(LayerItem(
              id: "camera_${DateTime.now().millisecondsSinceEpoch}",
              name: "3D Camera",
              type: LayerType.camera,
              startTime: 0.0,
              duration: project.duration,
              trackIndex: 3,
              is3D: true,
            ));
          },
        ),
        _buildToolBtn(
          icon: Icons.aspect_ratio,
          label: "Ratio",
          onTap: () {
            if (project.aspectRatio == CanvasAspectRatio.vertical9_16) {
              project.aspectRatio = CanvasAspectRatio.landscape16_9;
            } else if (project.aspectRatio == CanvasAspectRatio.landscape16_9) {
              project.aspectRatio = CanvasAspectRatio.square1_1;
            } else {
              project.aspectRatio = CanvasAspectRatio.vertical9_16;
            }
            project.notifyListeners();
          },
        ),
      ],
    );
  }

  Widget _buildToolBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
