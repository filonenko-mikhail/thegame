
import 'package:json_annotation/json_annotation.dart' as js;

part 'card_model.g.dart';

@js.JsonSerializable()
class CardModel {
  String id;
  String text;
  double x, y;
  int color;
  bool flipable;
  bool flip;
  String fliptext;
  int prio;
  double sizex, sizey;

  CardModel(this.id, this.text, this.x, this.y, this.color,
    this.flipable,
    this.flip,
    this.fliptext,
    this.prio,
    this.sizex,
    this.sizey);
  
  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardModelToJson(this);
}

class CardState {
  Map<String, CardModel> clientCards = {};

  CardState(this.clientCards);

  CardState.clone(CardState other) {
    clientCards.addAll(other.clientCards);
  } 
}
