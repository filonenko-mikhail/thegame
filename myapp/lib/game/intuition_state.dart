import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql/client.dart';

import 'utils.dart';

abstract class IntuitionEvent {}

@immutable
class IntuitionMove implements IntuitionEvent {
  final bool val;
  const IntuitionMove(this.val);
}

@immutable
class IntuitionState {
  final bool val;

  const IntuitionState(this.val);

  IntuitionState.clone(IntuitionState other):val = other.val;
}


class IntuitionBloc extends Bloc<IntuitionEvent,IntuitionState> {
  final HttpLink link;
  final String clientId;
  final GraphQLClient client;
  final Duration pollInterval;
  late final Completer<bool> task;

  static final policies = Policies(
    fetch: FetchPolicy.networkOnly,
  );

  IntuitionBloc(this.clientId, this.link, this.pollInterval)
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                            ),),
      super(const IntuitionState(true)) {

    on<IntuitionMove>((event, emit) {
      IntuitionState newstate = IntuitionState(event.val);
      emit(newstate);
    });

    task = periodic(pollInterval, poll);
  }

  void poll(event) async {
    const String intuitionQuery = r'''
      { intuition { val } }
    ''';
    final QueryOptions options = QueryOptions(
        document: gql(intuitionQuery)
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }

      add(IntuitionMove(result.data?['intuition']['val']));
  }

  void sendIntuitionVal(bool val) async {
    const String intuitionValMutation = r'''
      mutation ($val: Boolean!){
        intuition {
          set(val: $val)
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(intuitionValMutation),
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
