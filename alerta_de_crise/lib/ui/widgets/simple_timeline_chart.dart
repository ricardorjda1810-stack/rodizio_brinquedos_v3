import 'package:flutter/material.dart';

import '../theme/ui_tokens.dart';

final class SimpleTimelineChart extends StatelessWidget {
  const SimpleTimelineChart({
    required this.values,
    required this.color,
    required this.label,
    super.key,
  });

  final List<num> values;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: UiTokens.bg,
          borderRadius: BorderRadius.circular(UiTokens.radiusButton),
          border: Border.all(color: UiTokens.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(UiTokens.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: UiTokens.textSoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: UiTokens.s),
              Expanded(
                child: CustomPaint(
                  painter: SimpleTimelinePainter(values: values, color: color),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class SimpleTimelinePainter extends CustomPainter {
  const SimpleTimelinePainter({required this.values, required this.color});

  final List<num> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = UiTokens.border
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    if (values.isEmpty) {
      return;
    }

    if (values.length == 1) {
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 4, pointPaint);
      return;
    }

    var minValue = values.first.toDouble();
    var maxValue = minValue;
    for (final value in values.skip(1)) {
      final doubleValue = value.toDouble();
      if (doubleValue < minValue) {
        minValue = doubleValue;
      }
      if (doubleValue > maxValue) {
        maxValue = doubleValue;
      }
    }
    final range = maxValue - minValue;
    final xStep = size.width / (values.length - 1);
    final path = Path();

    for (var index = 0; index < values.length; index++) {
      final normalized = range == 0
          ? 0.5
          : (values[index].toDouble() - minValue) / range;
      final point = Offset(
        xStep * index,
        size.height - (normalized * size.height),
      );

      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant SimpleTimelinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
