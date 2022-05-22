import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

import '../game/dice_state.dart';

var logger = Logger();

class Dice extends HudMarginComponent<FlameBlocGame> 
  with Tappable, Hoverable,
       BlocComponent<DiceBloc, DiceState>
  {

  static final Paint circlePaint = Paint()
    ..color=Colors.black87
    ..style=PaintingStyle.stroke
    ..strokeWidth=3;

  static final Paint buttonPaint = Paint()
    ..color=Colors.black26
    ..style=PaintingStyle.fill;

  static final Paint hoverButtonPaint = Paint()
    ..color=Colors.black87
    ..style=PaintingStyle.fill;

  static final TextPaint textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
  );
  static final TextPaint redTextPaint = TextPaint(
    style: const TextStyle(
      color: Colors.amberAccent,
      fontWeight: FontWeight.bold,
    ),
  );
  static final TextPaint hoverTextPaint = TextPaint(
    style: const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    ),
  );

  static final random = Random.secure();

  bool tapdown = false;
  double buttonAngle = 2*pi;
  int localVal = 1;

  Dice({
    EdgeInsets? margin,
    Vector2? size,
  }):super(margin:margin, size:size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // center button paint
    double radius = min(size.x/2, size.y/2) - 3;
    if (!isHovered || tapdown) {
      canvas.drawCircle((size/2).toOffset(), radius/2, buttonPaint);
    } else {
      canvas.drawCircle((size/2).toOffset(), radius/2, hoverButtonPaint);
    }
    
    // outter paints
    if (buttonAngle < 2*pi) {
      canvas.drawArc(Rect.fromCircle(center: (size/2).toOffset(), radius: radius),0, buttonAngle, true, circlePaint);
    } else {
      canvas.drawCircle((size/2).toOffset(), radius, circlePaint);
    }

    canvas.save();
    canvas.translate(size.x/2, size.y/2);
    TextPaint painter = textPaint;
    for (var i=0; i<6; ++i){
      canvas.save();
      canvas.rotate(i*(2*pi/6));
      canvas.translate(0, -radius);

      //if (state?.val == i + 1) {
      if (localVal == i + 1) {
        painter = redTextPaint;
      } else {
        if (isHovered) {
          painter = hoverTextPaint;
        } else {
          painter = textPaint;
        }
      }
      painter.render(canvas, (i+1).toString(), Vector2(0,0));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (buttonAngle < 2*pi) {
      buttonAngle += (2*pi)/180;
      localVal = nextRandom(1, 7);

      if (buttonAngle >= 2*pi) {
        gameRef.read<DiceBloc>().sendDiceVal(localVal);
      }
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

    buttonAngle = 0;

    return false;
  }

  @override
  bool onTapCancel() {
    tapdown = false;
    return false;
  }

  @override
  void onNewState(DiceState state) {
    localVal = state.val;
    super.onNewState(state);
  }
}
