import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/effects.dart';
import 'package:flame/components.dart' as components;
import 'close_button.dart' as close_button;

import 'package:flame_bloc/flame_bloc.dart';

import '../game/chip_state.dart';

var logger = Logger();

class Chip extends PositionComponent
  with components.Draggable, Tappable, Hoverable,
  HasGameRef<FlameBlocGame> {
  
  ChipModel model;

  Chip(this.model,
  {
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }):
  super(
    position: position,
    size: Vector2(20, 20),
    scale: scale,
    angle: angle,
    anchor: anchor,
    priority: priority
  );

  void setModel(ChipModel newModel) {
    Vector2 pos = Vector2(newModel.x, newModel.y);
    if (position != pos && !isDragged) {
      var moveEffect = MoveEffect.to(pos, EffectController(duration: 0.1));
      add(moveEffect);
    }

    model = newModel;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    var sizeEffect = SizeEffect.to(size, EffectController(duration: 0.1));
    add(sizeEffect);
    Vector2 pos = Vector2(model.x, model.y);
    var moveEffect = MoveEffect.to(pos, EffectController(duration: 0.1));
    add(moveEffect);
  }

  bool logged = false;
  @override
  void render(Canvas canvas) {
    Color backgroundColor = Color(model.color);
    canvas.drawCircle( (size/2).toOffset(), 10, Paint()..color = backgroundColor);
    
    //super.render(canvas);
  }

  // Dragging
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
    gameRef.read<ChipBloc>().moveChip(model.id, position.x, position.y);
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
    gameRef.read<ChipBloc>().removeChip(model.id);
    super.onRemove();
  }

}
