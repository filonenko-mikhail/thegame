import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../game/state.dart';
import '../game/game.dart';

var logger = Logger();

class CardLayer extends PositionComponent
  with BlocComponent<GameBloc, GameState>, 
  HasGameRef<MyGame> {

  Map<String, PositionComponent> cards = {};

  @override
  void onNewState(GameState state) {
    logger.i('NEW STATE FROM LAYER');
    state.cards.forEach((k, v) {
      
        if (!cards.containsKey(k)) {
          cards[k] = RectangleComponent(size: Vector2(100, 100));
          logger.i('New card ${cards[k]}');
          add(cards[k]!);
        }

        position = Vector2(v['x'], v['y']);
        final effect = MoveEffect.to(position, EffectController(duration: 0.1));
        effect.target = cards[k]!;
        cards[k]!.add(effect);
      }
    );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
