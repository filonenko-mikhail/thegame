import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

import '../game/intuition_state.dart';

var logger = Logger();

class Intuition extends HudMarginComponent<FlameBlocGame> 
  with Tappable, Hoverable,
       BlocComponent<IntuitionBloc, IntuitionState>
  {

  static final Paint circlePaint = Paint()
    ..color=Colors.black87
    ..style=PaintingStyle.stroke
    ..strokeWidth=3;

  static final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.bold,
    ),
  );
  static final TextPaint redTextPaint = TextPaint(
    style: const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    ),
  );

  static final random = Random.secure();

  bool tapdown = false;
  bool inProcess = false;
  double buttonAngle = 2*pi;

  Intuition({
    EdgeInsets? margin,
    Vector2? size,
  }):super(margin:margin, size:size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // outter paints
    double radius = min(size.x/2, size.y/2) - 3;
    if (buttonAngle < 2*pi) {
      canvas.drawArc(Rect.fromCircle(center: (size/2).toOffset(), radius: radius),0, buttonAngle, true, circlePaint);
    } else {
      canvas.drawCircle((size/2).toOffset(), radius, circlePaint);
    }

    if (state!.val) {
      textPaint.render(canvas, "Молния", size/2, anchor: Anchor.center);
    } else {
      redTextPaint.render(canvas, "Слезинка", size/2, anchor: Anchor.center);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (buttonAngle < 2*pi) {
      buttonAngle += (2*pi)/180;
    }
  }

  /**
   * Generates a positive random integer uniformly distributed on the range
   * from [min], inclusive, to [max], exclusive.
   */
  int nextRandom(int min, int max) {
    return min + random.nextInt(max - min);
  }

  @override
  bool onTapDown(TapDownInfo event) {
    tapdown = true;
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    tapdown = false;

    // move back on state change
    inProcess = true;

    buttonAngle = 0;

    var limit = nextRandom(5, 30);
    var val = nextRandom(1, 7);
    for (var i = 1; i < limit; i++) {
      val = nextRandom(1, 7);
    }

    gameRef.read<IntuitionBloc>().sendIntuitionVal(val%2 == 0);

    return false;
  }

  @override
  bool onTapCancel() {
    tapdown = false;
    return false;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    
    super.onGameResize(gameSize);
  }

  @override
  void onNewState(IntuitionState state) {
    super.onNewState(state);

    // Move back after click
    if (inProcess) {
      inProcess = false;
    }
  }

  
}
