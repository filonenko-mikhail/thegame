import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';

class RotateButton extends PositionComponent with Draggable {
  double _radius;
  double _angle;
  double _velocity;
  RotateButton(double radius, {Vector2? position})
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

    canvas.drawArc(
        Rect.fromCircle(center: Offset(0, 0), radius: 2 * _radius / 3),
        0,
        pi / 3,
        true,
        Paint()..style = PaintingStyle.stroke);

    canvas.drawCircle(
        Offset(0, 0), _radius, Paint()..style = PaintingStyle.stroke);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _angle += _velocity;
  }

  @override
  bool containsPoint(Vector2 point) {
    final Vector2 local = absoluteToLocal(point);
    return local.x * local.x + local.y * local.y < _radius * _radius;
  }

  Vector2 _startDrag = Vector2.zero();
  double _startDragAngle = 0;

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    _startDrag = info.eventPosition.game;
    _startDragAngle = (parent as PositionComponent).angle;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    Vector2 diff = info.eventPosition.game - _startDrag;
    (parent as PositionComponent).angle = _startDragAngle + diff.y / 100;
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    return false;
  }

  @override
  bool onDragCancel(int pointerId) {
    (parent as PositionComponent).angle = _startDragAngle;
    return false;
  }

  @override
  bool onTapDown(TapDownInfo event) {
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    return false;
  }

  @override
  bool onTapCancel() {
    return false;
  }
}
