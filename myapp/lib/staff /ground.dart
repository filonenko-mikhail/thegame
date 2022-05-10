import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

class Ground extends PositionComponent {
  double _fieldSize;
  int _fieldNums;
  Color _backColor;

  Ground(double fieldSize, int fieldNums, Color backColor, {Vector2? position})
      : _fieldSize = fieldSize,
        _fieldNums = fieldNums,
        _backColor = backColor,
        super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
        Rect.fromCircle(center: Offset(0, 0), radius: _fieldSize / 2),
        Paint()..color = Color(0xFF00BB00));
  }
}
