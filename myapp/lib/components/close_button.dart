import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';

class CloseButton extends PositionComponent with Tappable {
  double _radius;
  double _angle;
  double _velocity;
  CloseButton(double radius, {Vector2? position})
      : _radius = radius,
        _angle = 0,
        _velocity = 0,
        super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawCircle(
        Offset(0, 0),
        _radius,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Color(0xffFFFFFF));
    canvas.drawLine(Offset(-_radius / 2, -_radius / 2),
        Offset(_radius / 2, _radius / 2), Paint());
    canvas.drawLine(Offset(-_radius / 2, _radius / 2),
        Offset(_radius / 2, -_radius / 2), Paint());

    canvas.drawArc(Rect.fromCircle(center: Offset(0, 0), radius: _radius), 0,
        _angle, true, Paint()..style = PaintingStyle.fill);

    canvas.drawCircle(
        Offset(0, 0), _radius, Paint()..style = PaintingStyle.stroke);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _angle += _velocity;
    if (_angle > 2 * pi) {
      parent?.removeFromParent();
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    final Vector2 local = absoluteToLocal(point);
    return local.x * local.x + local.y * local.y < _radius * _radius;
  }

  @override
  bool onTapDown(TapDownInfo event) {
    _velocity = 3 * pi / 360;
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    _velocity = 0;
    _angle = 0;
    return false;
  }

  @override
  bool onTapCancel() {
    _velocity = 0;
    _angle = 0;
    return false;
  }
}
