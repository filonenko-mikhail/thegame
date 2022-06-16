import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart' show
  Color,
  Colors,
  TextStyle,
  TextDecoration,
  Paint,
  PaintingStyle,
  TextPainter,
  TextSpan,
  TextWidthBasis,
  TextDirection,
  Canvas,
  Offset,
  Rect;

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/effects.dart';
//import 'package:flame/components.dart' as components;
import 'close_button.dart' as close_button;

import 'package:flame_bloc/flame_bloc.dart';

import '../game/card_state.dart';
import 'updown_button.dart';

var logger = Logger();

class Card extends PositionComponent
  with Draggable, Tappable, Hoverable,
  HasGameRef<FlameBlocGame> {
  
  static final TextPaint regularTextPaint = TextPaint(
    style: const TextStyle(color: Colors.black87)
  );

  static final TextPaint hoverTextPaint = TextPaint(
    style: const TextStyle(
      color: Colors.black87,
      decoration: TextDecoration.underline)
  );

  String text;
  CardModel model;
  close_button.CloseButton closeButton;
  final flipPaint = Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.fill;
  Paint backPaint = Paint();

  Card(this.model,
  {
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }):text = "",
    closeButton = close_button.CloseButton()
      ..size=Vector2(20, 20),
    super(
      position: position,
      size: Vector2(model.sizex, model.sizey),
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority
    ) {
    text = model.text;
    if (model.flipable) {
      if (model.flip) {
        text = model.fliptext;
      }
    }
  }

  void setModel(CardModel newModel) {
    Vector2 pos = Vector2(newModel.x, newModel.y);
    if (position != pos && !isDragged) {
      var moveEffect = MoveEffect.to(pos, EffectController(duration: 0.3));
      add(moveEffect);
    }

    Vector2 size = Vector2(newModel.sizex, newModel.sizey);
    if (size != size) {
      var sizeEffect = SizeEffect.to(size, EffectController(duration: 0.2));
      add(sizeEffect);
    }

    if (newModel.flip != model.flip) {
      if (newModel.flip) {
        text = newModel.fliptext;
      } else {
        text = newModel.text;
      }
    }
    
    if (newModel.prio != model.prio) {
      changePriorityWithoutResorting(newModel.prio);
      parent?.reorderChildren();
    }
    model = newModel;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Vector2 size = Vector2(model.sizex, model.sizey);
    var sizeEffect = SizeEffect.to(size, EffectController(duration: 0.1));
    add(sizeEffect);
    Vector2 pos = Vector2(model.x, model.y);
    var moveEffect = MoveEffect.to(pos, EffectController(duration: 0.1));
    add(moveEffect);
    
    changePriorityWithoutResorting(model.prio);
    parent?.reorderChildren();
    
    add(closeButton);

    UpButton upButton = UpButton()..size=Vector2(20, 10);
    add(upButton);
    DownButton downButton = DownButton()..size=Vector2(20, 10);
    add(downButton);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    canvas.save();
    Color backgroundColor = Color(model.color);
    canvas.drawRect(Rect.fromPoints(Offset.zero, size.toOffset()), 
      backPaint..color = backgroundColor);
    canvas.restore();
    
    TextSpan span = TextSpan(text: text);
    TextPainter textPainter = TextPainter(text: span,
                                          textWidthBasis: TextWidthBasis.longestLine,
                                          textDirection: TextDirection.ltr,
                                          );
    textPainter.layout(minWidth: 0, maxWidth: size.x - closeButton.size.x);
    textPainter.paint(canvas, Offset.zero);

    if (flipAngle > 0) {
      double radius = min(size.x, size.y)/2 - 1;
      canvas.drawArc(Rect.fromCircle(center: (size/2).toOffset(),
             radius: radius),
          0, flipAngle, true, flipPaint);
    }
  }

  // Flipable
  double flipAngle = 0;
  double flipAngleVelocity = 0;
  @override
  void update(double dt) {
    flipAngle += flipAngleVelocity;
    if (flipAngle > 2 * pi) {
      gameRef.read<CardBloc>().flipCard(model.id, !model.flip);
      flipAngle = 0;
    }
    super.update(dt);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (!model.flipable) {
      return false;
    }
    if (isDragged) {
      return false;
    }
    
    flipAngleVelocity = pi / 30;
    return false;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (!model.flipable) {
      return false;
    }
    flipAngleVelocity = 0;
    flipAngle = 0;
    return false;
  }

  @override
  bool onTapCancel() {
    if (!model.flipable) {
      return false;
    }
    flipAngleVelocity = 0;
    flipAngle = 0;
    return false;
  }

  // Dragging
  Vector2 _draganchor = Vector2.zero();
  Vector2 _startDrag = Vector2.zero();

  @override
  bool onDragStart(DragStartInfo info) {
    _draganchor = info.eventPosition.game - position;
    _startDrag = info.eventPosition.game;
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    position = info.eventPosition.game - _draganchor;
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    _draganchor = Vector2.zero();
    gameRef.read<CardBloc>().moveCard(model.id, position.x, position.y);
    return false;
  }

  @override
  bool onDragCancel() {
    position = _startDrag;
    return false;
  }

  // Child control handlers
  @override
  void onRemove() {
    gameRef.read<CardBloc>().removeCard(model.id);
    super.onRemove();
  }

  void changePrio(int newprio) {
    changePriorityWithoutResorting(newprio);
    parent?.reorderChildren();
    gameRef.read<CardBloc>().changePrio(model.id, newprio);
  }

}
