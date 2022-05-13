import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/effects.dart';
import 'package:flame/components.dart' as components;
import 'close_button.dart' as close_button;

import 'package:flame_bloc/flame_bloc.dart';

import '../game/card_state.dart';

var logger = Logger();

class Card extends PositionComponent
  with components.Draggable, Tappable, Hoverable,
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

  Card(this.model,
  {
    Vector2? position,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }):text = "",
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
      var moveEffect = MoveEffect.to(pos, EffectController(duration: 0.1));
      add(moveEffect);
    }

    Vector2 size = Vector2(newModel.sizex, newModel.sizey);
    if (size != size) {
      var sizeEffect = SizeEffect.to(size, EffectController(duration: 0.1));
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
      changePriorityWithoutResorting(priority);
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
    

    close_button.CloseButton closeButton = close_button.CloseButton()
      ..size=Vector2(20, 20)
      ..position;
    
    add(closeButton);
  }

  bool logged = false;
  @override
  void render(Canvas canvas) {
    Color backgroundColor = Color(model.color);
    canvas.drawRect(Rect.fromPoints(Offset.zero, size.toOffset()), Paint()..color = backgroundColor);
    
    super.render(canvas);

    TextSpan span = TextSpan(text: text);
    TextPainter textPainter = TextPainter(text: span,
                                          textWidthBasis: TextWidthBasis.longestLine,
                                          textDirection: TextDirection.ltr,
                                          );
    textPainter.layout(minWidth: 0, maxWidth: size.x);
    textPainter.paint(canvas, Offset.zero);

    if (_upsideAngle > 0) {
      canvas.drawArc(
          Rect.fromCircle(center: (size/2).toOffset(), radius: _upsideAngleRadius),
          0,
          _upsideAngle,
          true,
          Paint()..style = PaintingStyle.fill);
    }
  }


  // Flipable
  double _upsideAngle = 0;
  double _upsideAngleVelocity = 0;
  double _upsideAngleRadius = 10;
  @override
  void update(double dt) {
    _upsideAngle += _upsideAngleVelocity;
    if (_upsideAngle > 2 * pi) {
      gameRef.read<CardBloc>().flipCard(model.id, !model.flip);
      _upsideAngle = 0;
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
    
    _upsideAngleVelocity = pi / 90;
    return false;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (!model.flipable) {
      return false;
    }
    _upsideAngleVelocity = 0;
    _upsideAngle = 0;
    return false;
  }

  @override
  bool onTapCancel() {
    if (!model.flipable) {
      return false;
    }
    _upsideAngleVelocity = 0;
    _upsideAngle = 0;
    return false;
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
    gameRef.read<CardBloc>().moveCard(model.id, position.x, position.y);
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
    gameRef.read<CardBloc>().removeCard(model.id);
    super.onRemove();
  }

}
