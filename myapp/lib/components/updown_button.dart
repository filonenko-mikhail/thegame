import 'dart:ui';
import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

import 'card.dart' as card;

var logger = Logger();

class UpdownButton extends PositionComponent 
  with Tappable, Hoverable,
    HasGameRef<FlameBlocGame> {
  static final paint = Paint();
  static final hoverPaint = Paint()
    ..strokeWidth=3;
  static final textPaint = TextPaint();
  

  UpdownButton({Vector2? position})
      : super(
          position: position,
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Paint currentPaint = paint;
    if (isHovered) {
      currentPaint = hoverPaint;
    }

    canvas.drawLine(Offset(0, size.y/3), Offset(size.x/2, 0), currentPaint);
    canvas.drawLine(Offset(size.x/2, 0),Offset(size.x, size.y/3), currentPaint);

  }

  @override
  void update(double dt) {
    super.update(dt);
    
  }

  @override
  bool onTapDown(TapDownInfo event) {
         
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {

    Vector2 local = absoluteToLocal(event.eventPosition.game);
    var parentCard = parent as card.Card;
    if (parentCard != null) {
      if (local.y < size.y/2) {
        parentCard.changePrio(parentCard.priority + 1);
      } else {
        parentCard.changePrio(parentCard.priority - 1);
      }
    } else {
      assert(false, "updown parent not found");
    }
      
    return false;
  }

  @override
  bool onTapCancel() {
    return false;
  }

  @override
  void onMount() {
    // TODO: implement onMount
    onParentResize();
    var positionParent = parent as PositionComponent;
    positionParent.size.addListener(onParentResize);
    super.onMount();
  }

  void onParentResize() {
    var positionParent = parent as PositionComponent;
    // right side middle
    position = Vector2(positionParent.size.x - size.x, 
      (positionParent.size.y - size.y)/2);
  }
}


class UpButton extends PositionComponent 
  with Tappable, Hoverable,
    HasGameRef<FlameBlocGame> {
  static final paint = Paint();
  static final hoverPaint = Paint()
    ..strokeWidth=3;
  static final textPaint = TextPaint();
  

  UpButton({Vector2? position})
    :super(position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Paint currentPaint = paint;
    if (isHovered) {
      currentPaint = hoverPaint;
    }

    // Fix for hover
    canvas.drawLine(Offset(1, size.y-1), Offset(size.x/2, 1), currentPaint);
    canvas.drawLine(Offset(size.x/2, 1),Offset(size.x-1, size.y-1), currentPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
  }

  @override
  bool onTapDown(TapDownInfo event) {
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    var parentCard = parent as card.Card;
    if (parentCard != null) {
      parentCard.changePrio(parentCard.priority + 1);
    } else {
      assert(false, "updown parent not found");
    }
    return false;
  }

  @override
  bool onTapCancel() {
    return false;
  }

  @override
  void onMount() {
    onParentResize();
    var positionParent = parent as PositionComponent;
    positionParent.size.addListener(onParentResize);
    super.onMount();
  }

  void onParentResize() {
    var positionParent = parent as PositionComponent;
    position = Vector2(positionParent.size.x - size.x, 
      positionParent.size.y/2 - size.y);
  }
}


class DownButton extends PositionComponent 
  with Tappable, Hoverable,
    HasGameRef<FlameBlocGame> {
  static final paint = Paint();
  static final hoverPaint = Paint()
    ..strokeWidth=3;
  static final textPaint = TextPaint();
  
  DownButton({Vector2? position})
    :super(position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    Paint currentPaint = paint;
    if (isHovered) {
      currentPaint = hoverPaint;
    }

    canvas.drawLine(Offset(1, 1), Offset(size.x/2, size.y-1), currentPaint);
    canvas.drawLine(Offset(size.x/2, size.y-1),Offset(size.x-1, 1),currentPaint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
  }

  @override
  bool onTapDown(TapDownInfo event) {
    return false;
  }

  @override
  bool onTapUp(TapUpInfo event) {
    var parentCard = parent as card.Card;
    if (parentCard != null) {
      parentCard.changePrio(parentCard.priority - 1);
    } else {
      assert(false, "updown parent not found");
    }
    return false;
  }

  @override
  bool onTapCancel() {
    return false;
  }

  @override
  void onMount() {
    onParentResize();
    var positionParent = parent as PositionComponent;
    positionParent.size.addListener(onParentResize);
    super.onMount();
  }

  void onParentResize() {
    var positionParent = parent as PositionComponent;
    position = Vector2(positionParent.size.x - size.x, 
      positionParent.size.y/2);
  }
}
