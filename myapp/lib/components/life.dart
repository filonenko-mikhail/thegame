import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

import 'heaven.dart';

class Life extends PositionComponent {
  double _fieldSize;

  Life(double fieldSize, {Vector2? position})
      : _fieldSize = fieldSize,
        super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    double radius = _fieldSize / 6;

    canvas.drawCircle(
        Offset(0, 0),
        radius,
        Paint()
          ..color = Color(0xFFFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = Heaven.defaultWidth);
  }
}

class LifePlace extends PositionComponent {
  double _fieldSize;
  int _fieldNums;
  Color _backColor;

  LifePlace(double fieldSize, int fieldNums, Color backColor,
      {Vector2? position})
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

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(3 * _fieldSize / 6, _fieldSize / 5)
      ..arcToPoint(Offset(3 * _fieldSize / 6, -_fieldSize / 5),
          radius: Radius.circular(-_fieldSize / 2))
      ..close();
    canvas.drawPath(path, Paint()..color = _backColor);
  }
}
