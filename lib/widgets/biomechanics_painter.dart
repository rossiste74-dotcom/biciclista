import 'package:flutter/material.dart';
import '../models/biomechanics_analysis.dart';

class BiomechanicsPainter extends CustomPainter {
  final List<KeyPoint> keypoints;
  final List<SkeletonLine> lines;
  final double scale;

  BiomechanicsPainter({
    required this.keypoints,
    required this.lines,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.isEmpty) return;

    final paintLine = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    // Draw lines
    for (var line in lines) {
      final from = _findPoint(line.from);
      final to = _findPoint(line.to);

      if (from != null && to != null) {
        canvas.drawLine(
          Offset(from.x * size.width, from.y * size.height),
          Offset(to.x * size.width, to.y * size.height),
          paintLine,
        );
      }
    }

    // Draw points
    for (var point in keypoints) {
      canvas.drawCircle(
        Offset(point.x * size.width, point.y * size.height),
        6.0,
        paintPoint,
      );
    }
  }

  KeyPoint? _findPoint(String label) {
    try {
      return keypoints.firstWhere((element) => element.label == label);
    } catch (e) {
      return null;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
