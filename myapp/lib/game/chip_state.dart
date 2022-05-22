
import 'dart:async';

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
  final Link link;
  final String clientId;
  final GraphQLClient client;
  int lastSend;
  int lastPoll;
  final Duration pollInterval;
  final Duration sendInterval;
  late final Completer<bool> task;
  late final Completer<bool> task2;
  Map<String, Vector2> toSendXY;
  late final Stream subscription;

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
      lastPoll = DateTime.now().millisecondsSinceEpoch,
      toSendXY = {},
      super(ChipState({})) {


    on<ChipList>((event, emit) {
      ChipState newstate = ChipState(event.chip);
      emit(newstate);
    });

    final subscriptionRequest = gql(
      r'''
        subscription {
          updates {
            id
          }
        }
      ''',
    );
    subscription = client.subscribe(
      SubscriptionOptions(
        document: subscriptionRequest
      ),
    );
    subscription.listen(onMessage);

    task = periodic(pollInterval, poll);
    task2 = periodic(sendInterval, send);
  }

  void onMessage(event) {
    poll(event);
  }

  // timer
  void poll(event) async {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastPoll < 200) {
      return ;
    }

    final chipQuery = gql(r'''
      { chip { list { id x y color} } }
    ''');
    final QueryOptions options = QueryOptions(
        document: chipQuery
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    add(ChipList(result.data?['chip']['list']));
    lastPoll = DateTime.now().millisecondsSinceEpoch;
  }

  // timer
  void send(event) async {
    final mutation = gql(r'''
        mutation ($id: ID! $x: Float! $y: Float!){
          chip {
            move(payload:{id:$id x:$x y:$y}) {
              id
            }
          }
        }
      ''');

    toSendXY.forEach((key, value) async {
      final MutationOptions options = MutationOptions(
        document: mutation,
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
    final mutation = gql(r'''
      mutation ($payload: ChipAddPayload!){
        chip {
          add(payload:$payload) {
            id
          }
        }
      }
    ''');

    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastSend < 200) {
      return;
    }
    final MutationOptions options = MutationOptions(
      document: mutation,
      variables: {
        "payload": model.toJson(),
        "client": clientId,
      }
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    lastSend = now;
  }

  void moveChip(String id, double x, double y) async {
    toSendXY[id] = Vector2(x, y);
  }

  void removeChip(String id) async {
    final mutation = gql(r'''
      mutation ($id: ID!){
        chip {
          remove(payload:{id:$id}) {
            id
          }
        }
      }
    ''');

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastSend < 200) {
      return;
    }      
    final MutationOptions options = MutationOptions(
      document: mutation,
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

  @override
  Future<void> close() {
    task.complete(true);
    task2.complete(true);
    return super.close();
  }
}
