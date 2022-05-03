
import 'package:logger/logger.dart';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flame_bloc/flame_bloc.dart';

import '../game/state.dart';
import '../game/game.dart';


var logger = Logger();

class PointerLayer extends PositionComponent
  with BlocComponent<GameBloc, GameState>, 
  HasGameRef<MyGame> {

  Map<String, PositionComponent> pointers = {};

  @override
  void onNewState(GameState state) {
    state.clientPointers.forEach((k, v) {
        if (!pointers.containsKey(k)) {
          pointers[k] = CircleComponent(radius: 4);
          add(pointers[k]!);
        }

        final effect = MoveEffect.to(v, EffectController(duration: 0.1));
        effect.target = pointers[k]!;
        pointers[k]!.add(effect);
      }
    );
  }
  
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
