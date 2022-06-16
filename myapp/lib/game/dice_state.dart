import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';

import 'utils.dart';

abstract class DiceEvent {}

@immutable
class DiceMove implements DiceEvent {
  final int val;
  const DiceMove(this.val);
}

@immutable
class DiceState {
  final int val;

  const DiceState(this.val);

  DiceState.clone(DiceState other):val = other.val;
}


class DiceBloc extends Bloc<DiceEvent,DiceState> {
  final Link link;
  final String clientId;
  final GraphQLClient client;
  final Duration pollInterval;
  late final Completer<bool> task;
  late final Stream subscription;

  static final policies = Policies(
    fetch: FetchPolicy.noCache,
  );

  DiceBloc(this.clientId, this.link, this.pollInterval)
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                              subscribe: policies,
                            ),),
      super(const DiceState(1)) {

    on<DiceMove>((event, emit) {
      DiceState newstate = DiceState(event.val);
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

    //task = periodic(pollInterval, poll);
  }

  void onMessage(event) {
    //poll(event);
  }

  void poll(event) async {
    final diceQuery = gql(r'''
      { dice { val } }
    ''');
    final QueryOptions options = QueryOptions(
        document: diceQuery
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }

      add(DiceMove(result.data?['dice']['val']));
  }

  void sendDiceVal(int val) async {
    final diceValMutation = gql(r'''
      mutation ($val: Int!){
        dice {
          set(val: $val)
        }
      }
    ''');

    final MutationOptions options = MutationOptions(
      document: diceValMutation,
      variables: <String, dynamic>{
        'val': val,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }
  }

  @override
  Future<void> close() {
    task.complete(true);
    return super.close();
  }
}
