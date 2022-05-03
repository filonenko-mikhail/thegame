import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

import 'close_button.dart';

class Avatar extends SpriteComponent with Draggable, Tappable {
  Avatar() : super(size: Vector2.all(64));

  var buttonPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = Color(0xFF80C080);

  Future<void> onLoad() async {
    sprite = await Sprite.load("crate.jpeg");
    anchor = Anchor.center;

    add(CloseButton(64 / 10)..position = Vector2(64 / 10, 64 / 10));
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
    return false;
  }
}
