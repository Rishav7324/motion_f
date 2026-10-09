import 'package:flutter/material.dart';

class PlayheadLine extends StatelessWidget {
  final double positionX;
  final double height;
  final double time;

  const PlayheadLine({
    super.key,
    required this.positionX,
    required this.height,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: positionX - 10,
      top: 0,
      bottom: 0,
      width: 20,
      child: IgnorePointer(
        child: Column(
          children: [
            // Pointer head
            Container(
              width: 12,
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD600), // CapCut signature amber yellow
                borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ),
            // Needle Line
            Expanded(
              child: Container(
                width: 2,
                color: const Color(0xFFFFD600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
