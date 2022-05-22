import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

var logger = Logger();

class PushButton extends HudMarginComponent<FlameBlocGame> 
  with Tappable, Hoverable {

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

  Paint paint = Paint()..color=Colors.grey;

  PushButton(this.title, {
    EdgeInsets? margin,
    Vector2? size,
  }):super(margin:margin, size:size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(Rect.fromLTRB(0, 0, size.x, size.y), paint);

    if (!isHovered || tapdown) {
      regularTextPaint.render(canvas, title, size/2, 
      anchor: Anchor.center);
    } else {
      hoverTextPaint.render(canvas, title, size/2, 
      anchor: Anchor.center);
    }
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
