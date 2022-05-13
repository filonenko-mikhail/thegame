
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';

import 'utils.dart';

import 'package:json_annotation/json_annotation.dart' as js;

part 'chip_state.g.dart';

@js.JsonSerializable()
class ChipModel {
  final String id;
  final double x, y;
  final int color;
  
  ChipModel(this.id,  this.x, this.y, this.color);
  
  factory ChipModel.fromJson(Map<String, dynamic> json) => _$ChipModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChipModelToJson(this);
}

class ChipState {
  Map<String, ChipModel> clientChips = {};

  ChipState(this.clientChips);

  ChipState.clone(ChipState other) {
    clientChips.addAll(other.clientChips);
  } 
}


abstract class ChipEvent {}
class ChipList extends ChipEvent {
    Map<String, ChipModel> chip = {};
    ChipList(List<Object?> data) {
      data.forEach(addElement);
    }
    void addElement(element) {
      ChipModel item = ChipModel.fromJson(element);
      chip[item.id] = item;
    }
} 

class ChipBloc extends Bloc<ChipEvent,ChipState> {
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

  ChipBloc(this.clientId, this.link, this.pollInterval, this.sendInterval)
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                            ),),
      lastSend = DateTime.now().millisecondsSinceEpoch,
      toSendXY = {},
      super(ChipState({})) {


    on<ChipList>((event, emit) {
      ChipState newstate = ChipState(event.chip);
      emit(newstate);
    });

    task = periodic(pollInterval, poll);
    task2 = periodic(sendInterval, send);
  }

  // timer
  void poll(event) async {
    const String chipQuery = r'''
      { chip { list { id x y color} } }
    ''';
    final QueryOptions options = QueryOptions(
        document: gql(chipQuery)
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    add(ChipList(result.data?['chip']['list']));
  }

  // timer
  void send(event) async {
    const String mutation = r'''
        mutation ($id: ID! $x: Float! $y: Float!
        ){
          chip {
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

  void addChip(ChipModel model) async {
    const String mutation = r'''
      mutation ($payload: ChipAddPayload!){
        chip {
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

  void moveChip(String id, double x, double y) async {
    toSendXY[id] = Vector2(x, y);
  }

  void removeChip(String id) async {
    const String mutation = r'''
      mutation ($id: ID!){
        chip {
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
