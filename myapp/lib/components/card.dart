
import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart' as components;
import 'close_button.dart' as close_button;

import 'package:flame_bloc/flame_bloc.dart';

import '../game/card_state.dart';

var logger = Logger();

class Card extends TextBoxComponent
  with components.Draggable, Tappable, Hoverable,
  HasGameRef<FlameBlocGame> {
  
  static final Paint backPaint = Paint()
    ..color=Colors.black26;

  static final TextPaint regularTextPaint = TextPaint(
    style: const TextStyle(color: Colors.black87)
  );

  static final TextPaint hoverTextPaint = TextPaint(
    style: const TextStyle(
      color: Colors.black87,
      decoration: TextDecoration.underline)
  );

  String id;
  int? color;

  Card(this.id, this.color,
  {
    String? text,
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }):super(
    text: text,
    position: position,
    scale: scale,
    angle: angle,
    anchor: anchor,
    priority: priority
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(close_button.CloseButton()..size=Vector2(20, 20));
  }

  @override
  void render(Canvas c) {
    if (color != null) {
      Color backgroundColor = Color(color!);
      c.drawRect(Rect.fromPoints(Offset.zero, size.toOffset()), Paint()..color = backgroundColor);
    }
    super.render(c);
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
    gameRef.read<CardBloc>().moveCard(id, position.x, position.y);
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
  void onRemove() {
    gameRef.read<CardBloc>().deleteCard(id);
    super.onRemove();
  }

}
