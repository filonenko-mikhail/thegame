
import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/components.dart';

import '../game/game.dart';

var logger = Logger();

class BackgroundLayer extends PositionComponent
  with HasGameRef<MyGame> {

  static const dashSize = 8;
  final Paint dotPaint = Paint()
    ..color = Colors.black87
    ..strokeCap = StrokeCap.round;

  final Paint strokePaint = Paint()
    ..strokeWidth = 40
    ..color = Colors.white
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  final Paint strokePaintCell = Paint()
    ..strokeWidth = 40
    ..color = Colors.black
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  bool imageLoaded = false;
  bool heavenLoaded = false;
  late Image image;

  BackgroundLayer({priority: int})
    :super(priority: priority);

  @override
  Future<void>? onLoad() {
    gameRef.images.load('game.png').whenComplete(() => imageLoaded=true);
    gameRef.images.load('heaven.png').whenComplete(() => heavenLoaded=true);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    for (int i=1; i < size.y/dashSize; ++i) {
      if (i%2 == 1) {
        canvas.drawLine(Offset(210, (i*dashSize).toDouble()), 
          Offset(210, ((i+1)*dashSize).toDouble()), dotPaint);
        canvas.drawLine(Offset(620, (i*dashSize).toDouble()), 
          Offset(620, ((i+1)*dashSize).toDouble()), dotPaint);
      }
    };

    canvas.save();
    canvas.translate(650, 120);
    if (imageLoaded) {
      canvas.drawImage(gameRef.images.fromCache("game.png"), Offset.zero, Paint());
    }
    canvas.restore();
    canvas.save();
    canvas.translate(580+800, 350);
    if (heavenLoaded) {
      canvas.drawImage(gameRef.images.fromCache("heaven.png"), Offset.zero, Paint());
    }
    canvas.restore();
  }
  
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
