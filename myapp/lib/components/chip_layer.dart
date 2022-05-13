
import 'package:logger/logger.dart';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';

import '../game/game.dart';
import '../game/chip_state.dart';
import 'chip.dart';


var logger = Logger();

class ChipLayer extends PositionComponent
  with BlocComponent<ChipBloc, ChipState>,
  HasGameRef<MyGame> {

  Map<String, Chip> chips = {};

  @override
  void onNewState(ChipState state) {
    state.clientChips.forEach(handleChipState);
  }

  void handleChipState(String k, ChipModel v) {
    Chip chip;
    if (chips.containsKey(k)) {
      chip = chips[k]!;
      chip.setModel(v);
    } else {
      chip = Chip(v);
      chips[k] = chip;
      add(chip);
    }
  }
  
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
