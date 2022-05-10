
import 'package:logger/logger.dart';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_bloc/flame_bloc.dart';

import '../game/game.dart';
import '../game/card_state.dart';
import 'card.dart';


var logger = Logger();

class CardLayer extends PositionComponent
  with BlocComponent<CardBloc, CardState>,
  HasGameRef<MyGame> {

  Map<String, Card> cards = {};

  @override
  void onNewState(CardState state) {
    state.clientCards.forEach(handleCardState);
  }

  void handleCardState(String k, CardModel v) {
    Card card;
    if (!cards.containsKey(k)) {
      card = Card(k, v.color, text: v.text);
      cards[k] = card;
      add(card);
    } else {
      card = cards[k]!;
    }

    Vector2 pos = Vector2(v.x, v.y);
    if (card.position != pos && !card.isDragged) {
      final effect = MoveEffect.to(pos, EffectController(duration: 0.1));  
      card.add(effect);
    }
  }
  
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
