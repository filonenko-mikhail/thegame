import 'dart:ui';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import '../game/game.dart';

var logger = Logger();

class PushButton extends PositionComponent 
  with Tappable, Hoverable,
  HasGameRef<MyGame> {

  static final TextPaint regularTextPaint = TextPaint(
    style: const TextStyle(color: Colors.black87)
  );

  static final TextPaint hoverTextPaint = TextPaint(
    style: const TextStyle(
      color: Colors.black87,
      decoration: TextDecoration.underline)
  );

  bool tapdown = false;
  String title;
  Function? callback;

  PushButton(this.title):super();

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(Rect.fromPoints(Offset.zero, size.toOffset()), Paint()..color=Colors.black38);
    if (!isHovered || tapdown) {
      regularTextPaint.render(canvas, title, size/2, 
      anchor: Anchor.center);
    } else {
      hoverTextPaint.render(canvas, title, size/2, 
      anchor: Anchor.center);
    }
  }

  @override
  bool containsPoint(Vector2 point) {
    var local = gameRef.camera.worldToScreen(point) - absoluteTopLeftPosition;
    return (local.x >= 0) &&
        (local.y >= 0) &&
        (local.x < size.x) &&
        (local.y < size.y);
  }

  @override
  bool onTapDown(TapDownInfo event) {
    tapdown = true;
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    tapdown = false;
    if (callback != null) {
      callback!();
    }
    return false;
  }

  @override
  bool onTapCancel() {
    tapdown = false;
    return false;
  }
}
