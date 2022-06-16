
import 'package:logger/logger.dart';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';

import '../game/game.dart';
import '../game/card_state.dart';
import 'card.dart';


var logger = Logger();

class CardLayer extends PositionComponent
  with FlameBlocListenable<CardBloc, CardState>,
  HasGameRef<MyGame> {

  Map<String, Card> cards = {};

  @override
  void onNewState(CardState state) {
    state.clientCards.forEach(handleCardState);
  }

  void handleCardState(String k, CardModel v) {
    Card card;
    if (cards.containsKey(k)) {
      card = cards[k]!;
      card.setModel(v);
    } else {
      card = Card(v);
      cards[k] = card;
      add(card);
    }
    reorderChildren();
  }
  
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
