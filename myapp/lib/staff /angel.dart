import 'dart:ui';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/src/painting/text_style.dart';

import '../components/close_button.dart';
import 'rotate_button.dart';

class Angel extends PositionComponent with Draggable, Tappable {
  double _fieldSize;
  double _width;
  double _height;
  RRect _frame;
  TextPaint _text;
  String _content;
  bool _upside;
  double _upsideAngle;
  double _upsideAngleVelocity;
  double _upsideAngleRadius;

  Angel(double fieldSize, {Vector2? position})
      : _fieldSize = fieldSize,
        _width = 300,
        _height = 200,
        _frame = RRect.zero,
        _text = TextPaint(),
        _content = "Радость",
        _upside = false,
        _upsideAngle = 0,
        _upsideAngleVelocity = 0,
        _upsideAngleRadius = 100,
        super(
          position: position,
          anchor: Anchor.center,
        ) {
    _frame = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: _width, height: _height),
        Radius.circular(6));
    _text = TextPaint(style: TextStyle(color: Color(0xFF000000), fontSize: 32));
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CloseButton(_width / 30)
      ..position = Vector2(-5 * _width / 12, -5 * _height / 12));
    add(RotateButton(_width / 30)
      ..position = Vector2(5 * _width / 12, -5 * _height / 12));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(_frame, Paint()..color = Color(0xFFFFFFFF));
    canvas.drawRRect(
        _frame,
        Paint()
          ..color = Color(0xFF000000)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke);

    if (_upside) {
      _text.render(canvas, _content, Vector2(0, 0));
    } else {
      _text.render(canvas, "Ангел", Vector2(0, 0));
    }

    if (_upsideAngle > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: Offset(0, 0), radius: _upsideAngleRadius),
          0,
          _upsideAngle,
          true,
          Paint()..style = PaintingStyle.fill);
    }
  }

  @override
  void update(double dt) {
    _upsideAngle += _upsideAngleVelocity;
    if (_upsideAngle > 2 * pi) {
      _upside = !_upside;
      _upsideAngle = 0;
    }
    super.update(dt);
  }

  @override
  bool containsPoint(Vector2 point) {
    final Vector2 local = absoluteToLocal(point);
    return _frame.contains(local.toOffset());
  }

  Vector2 _draganchor = Vector2.zero();
  Vector2 _startDrag = Vector2.zero();

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    _draganchor = info.eventPosition.game - position;
    _startDrag = info.eventPosition.game;
    return false;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    position = info.eventPosition.game - _draganchor;
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    _draganchor = Vector2.zero();
    return false;
  }

  @override
  bool onDragCancel(int pointerId) {
    position = _startDrag;
    return false;
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (!isDragged) {
      _upsideAngleVelocity = pi / 90;
    }
    return false;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    _upsideAngleVelocity = 0;
    _upsideAngle = 0;
    return false;
  }

  @override
  bool onTapCancel() {
    _upsideAngleVelocity = 0;
    _upsideAngle = 0;
    return false;
  }
}

class AngelBornPlace extends PositionComponent with Tappable {
  double _fieldSize;
  double _width;
  double _height;
  RRect _frame;
  TextPaint _text;

  AngelBornPlace(double fieldSize, {Vector2? position})
      : _fieldSize = fieldSize,
        _width = 300,
        _height = 200,
        _frame = RRect.zero,
        _text = TextPaint(),
        super(
          position: position,
          anchor: Anchor.center,
        ) {
    _frame = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: _width, height: _height),
        Radius.circular(6));
    _text = TextPaint(style: TextStyle(color: Color(0xFF000000), fontSize: 32));
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(_frame, Paint()..color = Color(0xFFFFFFFF));
    canvas.drawRRect(
        _frame,
        Paint()
          ..color = Color(0xFF000000)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    _text.render(canvas, "Ангелы", Vector2(0, 0));
  }

  @override
  bool containsPoint(Vector2 point) {
    final Vector2 local = absoluteToLocal(point);
    return _frame.contains(local.toOffset());
  }

  @override
  bool onTapDown(TapDownInfo info) {
    parent?.add(Angel(_fieldSize)
      ..position = info.eventPosition.game + Vector2(20, 20));
    return super.onTapDown(info);
  }
}
