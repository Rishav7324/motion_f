import 'package:flutter/material.dart';
import '../../models/layer.dart';
import '../../models/project.dart';

class TransitionSheet extends StatefulWidget {
  final LayerItem layer;
  final ProjectModel project;

  const TransitionSheet({
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
      builder: (context) => TransitionSheet(layer: layer, project: project),
    );
  }

  @override
  State<TransitionSheet> createState() => _TransitionSheetState();
}

class _TransitionSheetState extends State<TransitionSheet> {
  bool _editingIn = true; // true = transition in, false = transition out

  final List<_TransitionOption> _options = [
    _TransitionOption("None", TransitionType.none, Icons.block),
    _TransitionOption("Dissolve", TransitionType.dissolve, Icons.gradient),
    _TransitionOption("Fade", TransitionType.fade, Icons.opacity),
    _TransitionOption("Cross Zoom", TransitionType.crossZoom, Icons.zoom_in),
    _TransitionOption("Glitch", TransitionType.glitch, Icons.broken_image),
    _TransitionOption("Flash White", TransitionType.flashWhite, Icons.flash_on),
    _TransitionOption("Flash Black", TransitionType.flashBlack, Icons.flash_off),
    _TransitionOption("Wipe Left", TransitionType.wipeLeft, Icons.arrow_back),
    _TransitionOption("Wipe Right", TransitionType.wipeRight, Icons.arrow_forward),
    _TransitionOption("Whip Pan", TransitionType.whipPan, Icons.swipe),
  ];

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final project = widget.project;
    final currentType = _editingIn ? layer.transitionIn : layer.transitionOut;
    final currentDuration = _editingIn ? layer.transitionInDuration : layer.transitionOutDuration;

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
                  const Icon(Icons.auto_awesome_motion, color: Color(0xFF00E5FF), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Transitions: ${layer.name}",
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

          // In / Out Mode Selector
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("In-Transition")),
                  selected: _editingIn,
                  selectedColor: const Color(0xFF00E5FF),
                  backgroundColor: const Color(0xFF22232C),
                  labelStyle: TextStyle(
                    color: _editingIn ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) => setState(() => _editingIn = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("Out-Transition")),
                  selected: !_editingIn,
                  selectedColor: const Color(0xFF00E5FF),
                  backgroundColor: const Color(0xFF22232C),
                  labelStyle: TextStyle(
                    color: !_editingIn ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) => setState(() => _editingIn = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transition Duration Slider
          Row(
            children: [
              const SizedBox(
                width: 70,
                child: Text("Duration", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
              Expanded(
                child: Slider(
                  value: currentDuration.clamp(0.1, 2.0),
                  min: 0.1,
                  max: 2.0,
                  activeColor: const Color(0xFF00E5FF),
                  inactiveColor: Colors.white24,
                  onChanged: (val) {
                    setState(() {
                      if (_editingIn) {
                        layer.transitionInDuration = val;
                      } else {
                        layer.transitionOutDuration = val;
                      }
                    });
                    project.notifyListeners();
                  },
                ),
              ),
              SizedBox(
                width: 45,
                child: Text(
                  "${currentDuration.toStringAsFixed(1)}s",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Transition Cards Grid
          const Text(
            "SELECT TRANSITION STYLE",
            style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _options.length,
            itemBuilder: (context, index) {
              final opt = _options[index];
              final isSelected = opt.type == currentType;

              return InkWell(
                onTap: () {
                  setState(() {
                    if (_editingIn) {
                      layer.transitionIn = opt.type;
                    } else {
                      layer.transitionOut = opt.type;
                    }
                  });
                  project.notifyListeners();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00E5FF).withOpacity(0.15) : const Color(0xFF22232C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        opt.icon,
                        color: isSelected ? const Color(0xFF00E5FF) : Colors.white70,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        opt.name,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF00E5FF) : Colors.white70,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransitionOption {
  final String name;
  final TransitionType type;
  final IconData icon;

  const _TransitionOption(this.name, this.type, this.icon);
}
