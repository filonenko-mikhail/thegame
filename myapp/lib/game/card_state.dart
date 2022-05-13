
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';

import 'utils.dart';

import 'package:json_annotation/json_annotation.dart' as js;
part 'card_state.g.dart';

@js.JsonSerializable()
class CardModel {
  final String id;
  final String text;
  final double x, y;
  final int color;
  final bool flipable;
  final bool flip;
  final String fliptext;
  final int prio;
  final double sizex, sizey;

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

abstract class CardEvent {}
class CardList extends CardEvent {
    Map<String, CardModel> card = {};
    CardList(List<Object?> data) {
      data.forEach(addElement);
    }
    void addElement(element) {
      CardModel item = CardModel.fromJson(element);
      card[item.id] = item;
    }
} 

class CardBloc extends Bloc<CardEvent,CardState> {
  final HttpLink link;
  final String clientId;
  final GraphQLClient client;
  int lastSend;
  final Duration pollInterval;
  final Duration sendInterval;
  late final Completer<bool> task;
  late final Completer<bool> task2;
  Map<String, Vector2> toSendXY;

  static final policies = Policies(
    fetch: FetchPolicy.networkOnly,
  );

  CardBloc(this.clientId, this.link, this.pollInterval, this.sendInterval)
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                            ),),
      lastSend = DateTime.now().millisecondsSinceEpoch,
      toSendXY = {},
      super(CardState({})) {


    on<CardList>((event, emit) {
      CardState newstate = CardState(event.card);
      emit(newstate);
    });

    task = periodic(pollInterval, poll);
    task2 = periodic(sendInterval, send);
  }

  // timer
  void poll(event) async {
    const String cardQuery = r'''
      { card { list { id text x y color flipable flip fliptext prio sizex sizey} } }
    ''';
    final QueryOptions options = QueryOptions(
        document: gql(cardQuery)
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    add(CardList(result.data?['card']['list']));
  }

  // timer
  void send(event) async {
    const String mutation = r'''
        mutation ($id: ID! $x: Float! $y: Float!
        ){
          card {
            move(payload:{id:$id x:$x y:$y}) {
              id
            }
          }
        }
      ''';

    toSendXY.forEach((key, value) async {
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: <String, dynamic>{
          'id': key,
          'x':  value.x,
          'y': value.y,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }
    });
    toSendXY = {};
  }

  void addCard(CardModel model) async {

    const String mutation = r'''
      mutation ($payload: CardAddPayload!){
        card {
          add(payload:$payload) {
            id
          }
        }
      }
    ''';

    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastSend > 200) {      
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          "payload": model.toJson()
        }
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }

      lastSend = now;
    }
  }

  void moveCard(String id, double x, double y) async {
    toSendXY[id] = Vector2(x, y);
  }


  void flipCard(String id, bool flip) async {

    const String mutation = r'''
      mutation ($id: ID! $flip: Boolean!){
        card {
          flip(payload: {id:$id flip:$flip}) {
            id
          }
        }
      }
    ''';

    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastSend > 200) {      
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          "id": id,
          "flip": flip,
        }
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }

      lastSend = now;
    }
  }

  void removeCard(String id) async {
    const String mutation = r'''
      mutation ($id: ID!){
        card {
          remove(payload:{id:$id}) {
            id
          }
        }
      }
    ''';

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastSend > 20) {      
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: <String, dynamic>{
          'id': id,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }

      lastSend = now;
    }
  }

  @override
  Future<void> close() {
    task.complete(true);
    task2.complete(true);
    return super.close();
  }
}
