import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

enum CoinState { lightning, teardrop }

class Coin extends PositionComponent with Tappable {
  double _radius;

  CoinState _state;

  Coin(double fieldSize, {Vector2? position})
      : _state = CoinState.lightning,
        _radius = 10,
        super(
          position: position,
          anchor: Anchor.center,
        ) {
    _radius = fieldSize / 40;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawCircle(
        Offset(0, 0), _radius, Paint()..color = Color(0xFFFFD700));

    double lightningWidth = _radius / 4;
    if (_state == CoinState.lightning) {
      Path lightningPath = Path()
        ..moveTo(-5 * lightningWidth / 6, 0)
        ..lineTo(lightningWidth, 0)
        ..lineTo(2 * lightningWidth / 4, 2 * lightningWidth)
        ..lineTo(6 * lightningWidth / 4, 2 * lightningWidth)
        // Bottom
        ..lineTo(0, 6 * lightningWidth)
        ..lineTo(1 * lightningWidth / 6, 14 * lightningWidth / 5)
        ..lineTo(-4 * lightningWidth / 6, 14 * lightningWidth / 5)
        ..close();

      canvas.save();
      canvas.translate(0, -6 * lightningWidth / 2);
      canvas.drawPath(
          lightningPath,
          Paint()
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
      canvas.restore();
    } else if (_state == CoinState.teardrop) {
      final paint = Paint()
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = new Path()
        ..cubicTo(
            _radius, 6 * lightningWidth, -_radius, 6 * lightningWidth, 0, 0)
        ..close();
      canvas.save();
      canvas.translate(0, -5 * lightningWidth / 2);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    final Vector2 local = absoluteToLocal(point);
    return local.x * local.x + local.y * local.y < _radius * _radius;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (_state == CoinState.lightning) {
      _state = CoinState.teardrop;
    } else {
      _state = CoinState.lightning;
    }
    return super.onTapDown(info);
  }
}
