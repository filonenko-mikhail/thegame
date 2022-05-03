import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';

import 'avatar.dart';

class ChipBornPlace extends PositionComponent with Tappable {
  double _fieldSize;
  Rect _body;
  ChipBornPlace(double size, {Vector2? position})
      : _fieldSize = size,
        _body = Rect.fromLTWH(-size / 30, -size / 30, size / 30, size / 30),
        super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawOval(_body, Paint()..color = Color(0xff9f003d));
  }

  @override
  bool containsPoint(Vector2 point) {
    final Vector2 local = absoluteToLocal(point);
    return _body.contains(local.toOffset());
  }

  @override
  bool onTapDown(TapDownInfo info) {
    parent
        ?.add(Avatar()..position = info.eventPosition.game + Vector2(-10, 10));
    return super.onTapDown(info);
  }
}
