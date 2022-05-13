import 'dart:ui';
import 'dart:math';

import 'package:logger/logger.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

var logger = Logger();

class CloseButton extends PositionComponent with Tappable {
  double _angle;
  double velocity;

  final paint = Paint();
  final circlePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0x77FFFFFF);
  final fillPaint = Paint()..style = PaintingStyle.fill
          ..color = const Color(0x77FFFFFF);
  final strokePaint = Paint()..style = PaintingStyle.stroke
          ..color = const Color(0x77FFFFFF);

  CloseButton({Vector2? position})
      : _angle = 0,
        velocity = 0,
        super(
          position: position,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    double radius = min(size.x/2, size.y/2);

    canvas.drawCircle((size/2).toOffset(), radius, circlePaint);

    // Cross
    canvas.drawLine(Offset(radius / 2, radius / 2),
        Offset(radius + radius / 2 , radius + radius / 2), paint);
    canvas.drawLine(Offset(radius / 2, radius + radius / 2),
        Offset(radius + radius / 2, radius / 2), paint);

    canvas.drawArc(
      Rect.fromCircle(center: (size/2).toOffset(), radius: radius), 0, _angle, true, fillPaint);

    canvas.drawCircle(
        (size/2).toOffset(), radius, strokePaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _angle += velocity;
    if (_angle > 2 * pi) {
      parent?.removeFromParent();
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    final Vector2 local = absoluteToLocal(point);
    double radius = min(size.x, size.y);
    return local.x * local.x + local.y * local.y < radius * radius;
  }

  @override
  bool onTapDown(TapDownInfo event) {
    velocity = 3 * pi / 360;      
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    velocity = 0;
    _angle = 0;
    return false;
  }

  @override
  bool onTapCancel() {
    velocity = 0;
    _angle = 0;
    return false;
  }

  @override
  void onMount() {
    // TODO: implement onMount
    onParentResize();
    var positionParent = parent as PositionComponent;
    positionParent.size.addListener(onParentResize);
    super.onMount();
  }

  void onParentResize() {
    var positionParent = parent as PositionComponent;
    position = Vector2(positionParent.size.x - size.x, 0);
  }
}
