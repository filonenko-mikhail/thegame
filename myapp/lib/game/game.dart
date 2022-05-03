import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import "package:flame_bloc/flame_bloc.dart";
import 'package:myapp/components/card_layer.dart';

import '../components/coin.dart';
import '../components/heaven.dart';
import '../components/ground.dart';
import '../components/life.dart';
import '../components/angel.dart';
import '../components/pointer_layer.dart';
import '../components/button.dart';

import 'state.dart';

final logger = Logger();

Vector2 cameraVelocity = Vector2.zero();

class MyGame extends FlameBlocGame
    with
        KeyboardEvents,
        ScrollDetector,
        MouseMovementDetector,
        HasTappables,
        HasDraggables,
        HasHoverables {

  late final PointerLayer pointerLayer = PointerLayer();
  late final RectangleComponent buttonPanel = RectangleComponent(size: Vector2(400, 60));
  late final PushButton newLetterButton; 
  late final CardLayer cardLayer;
          
  static const int defaultFieldNums = 4;
  static const double defaultSize = 2000;
  Vector2 worldSize = Vector2(defaultSize, defaultSize);
  Vector2 cameraPosition = Vector2.zero();

  /// Round [val] up to [places] decimal places.
  static double _roundDouble(double val, int places) {
    final mod = pow(10.0, places);
    return (val * mod).round().toDouble() / mod;
  }

  @override
  Color backgroundColor() {
    return Colors.blueGrey;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();    

    cameraPosition = worldSize / 2;
    camera.followVector2(cameraPosition, relativeOffset: Anchor.center);

    add(Ground(defaultSize, defaultFieldNums, backgroundColor())
      ..position = worldSize / 2);

    for (var i = 0; i < defaultFieldNums; i++) {
      double angle = i * (2 * pi / defaultFieldNums) - (pi / defaultFieldNums);

      Vector2 offset = Vector2(4 * defaultSize / 12, 0);
      offset.rotate(angle);

      add(LifePlace(defaultSize, defaultFieldNums, backgroundColor())
        ..position = worldSize / 2
        ..angle = angle);
    }

    add(Coin(defaultSize)..position = worldSize / 2);
    add(Heaven(defaultSize, defaultFieldNums)..position = worldSize / 2);

    for (var i = 0; i < defaultFieldNums; i++) {
      double angle = i * (2 * pi / defaultFieldNums) - (pi / defaultFieldNums);

      Vector2 pos = worldSize / 2;
      Vector2 offset = Vector2(4 * defaultSize / 12, 0);
      offset.rotate(angle);

      add(Life(defaultSize)
        ..position = pos + offset
        ..angle = angle);
    }

    add(AngelBornPlace(defaultSize)
      ..position = Vector2(defaultSize / 2, defaultSize / 10));

    camera.zoom = 0.4;

    add(pointerLayer);
    // HUD
    newLetterButton = PushButton("Конверт");

    buttonPanel..position=Vector2(worldSize.x/2, 40)..anchor=Anchor.center
      ..positionType=PositionType.viewport;

    newLetterButton.size = Vector2(120, 40);
    newLetterButton.callback = () {
      read<GameBloc>().sendNewCard();
    };
    buttonPanel.add(newLetterButton);
    add(buttonPanel);

    cardLayer = CardLayer();
    add(cardLayer);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    return KeyEventResult.handled;
  }

  @override
  void onScroll(PointerScrollInfo info) {
    double zoomStep = -info.scrollDelta.game.y / 100;
    double zoom = camera.zoom + zoomStep;
    if (zoomStep > 0) {
      if (zoom < 3) {
        Vector2 direction = info.eventPosition.game - cameraPosition;
        camera.zoom = zoom;
        cameraPosition.add((direction * zoomStep) / camera.zoom);
      }
    } else {
      if (zoom >= 0.2) {
        camera.zoom = zoom;
        Vector2 direction = info.eventPosition.game - cameraPosition;
        cameraPosition.add((direction * zoomStep) / camera.zoom);
      } else {
        cameraPosition.setFrom(worldSize / 2);
      }
    }

    super.onScroll(info);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    super.onMouseMove(info);
    
    read<GameBloc>().sendMouseMove(
      info.eventPosition.game.x, 
      info.eventPosition.game.y);
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    buttonPanel.position=Vector2(canvasSize.x/2, 40);
    super.onGameResize(canvasSize);
  }


  @override
  void onAttach() {
    read<GameBloc>().sendGetCards();
    super.onAttach();
  }
}
