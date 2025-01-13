import 'dart:ui' show lerpDouble;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FlDotTrianglePainter extends FlDotPainter {
  final double size;
  final Color color;
  final double strokeWidth;
  final Color strokeColor;

  const FlDotTrianglePainter({
    required this.size,
    required this.color,
    this.strokeWidth = 0.0,
    this.strokeColor = Colors.transparent,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final path = Path();

    // Calculate triangle points (pointing upward)
    final halfSize = size / 2;
    path.moveTo(offsetInCanvas.dx, offsetInCanvas.dy - halfSize); // Top point
    path.lineTo(offsetInCanvas.dx - halfSize,
        offsetInCanvas.dy + halfSize); // Bottom left
    path.lineTo(offsetInCanvas.dx + halfSize,
        offsetInCanvas.dy + halfSize); // Bottom right
    path.close();

    // Draw fill
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Draw stroke
    if (strokeWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(size, size);
  }

  @override
  List<Object?> get props => [size, color, strokeWidth, strokeColor];

  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is FlDotTrianglePainter && b is FlDotTrianglePainter) {
      return FlDotTrianglePainter(
        size: lerpDouble(a.size, b.size, t)!,
        color: Color.lerp(a.color, b.color, t)!,
        strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t)!,
        strokeColor: Color.lerp(a.strokeColor, b.strokeColor, t)!,
      );
    }
    return this;
  }
}
