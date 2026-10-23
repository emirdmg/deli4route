import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RouteBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color foreground;
  final Color background;
  const RouteBadge(
    this.label, {
    super.key,
    this.icon,
    this.foreground = RouteColors.muted,
    this.background = RouteColors.background,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ),
      ],
    ),
  );
}

/// A small, code-drawn route illustration; no network or image asset needed.
class RouteIllustration extends StatelessWidget {
  const RouteIllustration({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 172,
    width: 260,
    child: CustomPaint(painter: _RoutePainter()),
  );
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(area.deflate(5), const Radius.circular(28)),
      Paint()..color = const Color(0xFFE9EEE8),
    );
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(area.deflate(5), const Radius.circular(28)),
    );
    final street = Paint()
      ..color = Colors.white
      ..strokeWidth = 12;
    for (final x in [.15, .48, .8]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x + .15), size.height),
        street,
      );
    }
    for (final y in [.3, .7]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y - .14)),
        street,
      );
    }
    final points = [
      Offset(size.width * .18, size.height * .75),
      Offset(size.width * .38, size.height * .38),
      Offset(size.width * .67, size.height * .59),
      Offset(size.width * .83, size.height * .22),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = RouteColors.orange
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 16, Paint()..color = Colors.white);
      canvas.drawCircle(
        points[i],
        12,
        Paint()..color = i == 0 ? RouteColors.ink : RouteColors.orange,
      );
      final text = TextPainter(
        text: TextSpan(
          text: i == 0 ? '•' : '$i',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, points[i] - Offset(text.width / 2, text.height / 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
