import 'dart:ui';
import 'dart:math';

import 'package:logger/logger.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

var logger = Logger();

class CloseButton extends PositionComponent 
  with Tappable, Hoverable {
  double closeAngle;
  double velocity;

  static final paint = Paint();
  static final hoverPaint = Paint()
          ..strokeWidth = 3;
  static final circlePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0x77AAAAAA);
  static final fillPaint = Paint()..style = PaintingStyle.fill
          ..color = const Color(0xFF333333);
  static final strokePaint = Paint()..style = PaintingStyle.stroke
          ..color = const Color(0x77000000);

  CloseButton({Vector2? position})
      :closeAngle = 0, velocity = 0,
        super(position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    double radius = min(size.x/2, size.y/2) - 1;

    canvas.drawCircle((size/2).toOffset(), radius, circlePaint);

    // Cross
    Paint currentPaint = paint;
    if (isHovered) {
      currentPaint = hoverPaint;
    }
    canvas.drawLine(Offset(size.x/4, size.y/4),
      Offset(3*size.x/4, 3*size.y/4), currentPaint);
    canvas.drawLine(Offset(size.x/4, 3*size.y/4),
      Offset(3*size.x/4, size.y/4), currentPaint);
    
    canvas.drawArc(
      Rect.fromCircle(center: (size/2).toOffset(), radius: radius), 0, closeAngle, true, fillPaint);

    canvas.drawCircle((size/2).toOffset(), radius, strokePaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    closeAngle += velocity;
    if (closeAngle > 2 * pi) {
      parent?.removeFromParent();
    }
  }

  @override
  bool onTapDown(TapDownInfo event) {
    velocity = pi / 30;      
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    velocity = 0;
    closeAngle = 0;
    return false;
  }

  @override
  bool onTapCancel() {
    velocity = 0;
    closeAngle = 0;
    return false;
  }

  @override
  void onMount() {
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
