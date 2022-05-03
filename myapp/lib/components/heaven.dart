import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

class Heaven extends PositionComponent {
  static const double defaultWidth = 60;
  double _sectors = 12;
  double _fieldSize;
  double _radius;

  Heaven(double fieldSize, int lifeNums, {Vector2? position})
      : _fieldSize = fieldSize,
        _radius = 160,
        _sectors = 12,
        super(
          position: position,
          anchor: Anchor.center,
        ) {
    _radius = fieldSize / 10;
    _sectors = lifeNums * 3;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawCircle(
        Offset(0, 0),
        _radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = defaultWidth
          ..color = Color(0xFFFFFFFF));

    // Draw sectors
    Paint paint = Paint();
    for (var i = 0; i < _sectors; i++) {
      double angle = i * (2 * pi / _sectors);

      canvas.save();
      canvas.rotate(angle);

      paint.style = PaintingStyle.fill;
      if ((_sectors - 1) % 3 == 0) {
        if (i == _sectors - 2) {
          paint.style = PaintingStyle.stroke;
        }
      }

      if (i % 3 == 0 && i != _sectors - 1) {
        paint.style = PaintingStyle.stroke;
      }
      canvas.drawCircle(Offset(_radius, 0), defaultWidth / 10, paint);
      canvas.restore();
    }
  }
}
