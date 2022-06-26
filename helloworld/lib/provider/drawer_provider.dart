
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:graphql/client.dart';

import 'package:provider/provider.dart';

import 'package:graphql/client.dart';

import 'package:flutter/material.dart';


import '../model/utils.dart';
import '../model/content_model.dart';

class DrawerProvider extends ChangeNotifier {

  Map<String, Map<String, ContentModel> > content = {};
  Map<String, bool> field = {};

  String randomKey(Map map) {
    if (map.isNotEmpty) {
      return map.keys.elementAt(Random.secure().nextInt(map.length));
    } else {
      return "";
    }
  }

  ContentModel? randomContent(String type) {
    if (!content.containsKey(type)) {
      logger.i("No content for $type while random");
      return null;
    }
    ContentModel? candidate;
    for (int i=1; i < 20; i++) {
      String key = randomKey(content[type]!);
      candidate = content[type]![key];
      if (!field.containsKey(candidate!.id)) {
        break;
      } else {
        candidate = null;
      }
    }
    if (candidate == null) {
      logger.i("No content for $type after randome");
    }
    return candidate;
  }


  // NETWORK
  final GraphQLClient client;
  final Duration pollInterval;
  late final Completer<bool> task;
  late final Stream subscription;
  late final StreamSubscription stream;
  
  static final policies = Policies(
    fetch: FetchPolicy.noCache,
  );

  DrawerProvider()
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: Connection.instance.link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                              subscribe: policies,
                              watchMutation: policies,
                            ),),
      pollInterval = const Duration(seconds: 60),
      super() {

    final query = gql(r'''
      query {
        content {
          list {
            id
            type
            title
            description
          }
        }
      }
    ''');

    
    final QueryOptions options = QueryOptions(
      document: query
    );

    client.query(options).then(handleContent);

    // START WATCHING FIELD
    task = periodic(pollInterval, poll);
    
    final subscriptionRequest = gql(
      r'''
        subscription {
          card {
            add { id }
            remove { id }
          }
        }
      ''',
    );
    subscription = client.subscribe(
      SubscriptionOptions(
        document: subscriptionRequest
      ),
    );
    stream = subscription.listen(onMessage);
  }


  void insertOrUpdateContentFromNetwork(element) {
    ContentModel item = ContentModel.fromJson(element);
    if (!content.containsKey(item.type)) {
      content[item.type] = {};
    }
    content[item.type]?[item.id] = item;
  }

  void handleContent(QueryResult result) {
    if (result.hasException) {
      logger.i(result.exception.toString());
      // TODO RETRY
      return;
    }

    final List list = result.data?['content']['list'];
    list.forEach(insertOrUpdateContentFromNetwork);
  }

  void insertOrUpdateCardFromNetwork(element) {
    field[element['id']] = true;
  }

  void poll(event) async {
    final cardQuery = gql(r'''
      { card { list { id } } }
    ''');
    final QueryOptions options = QueryOptions(document: cardQuery);

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    final List list = result.data?['card']['list'];
    
    field.clear();
    list.forEach(insertOrUpdateCardFromNetwork);
  }

  // WEBSOCKET PUSH
  void onMessage(event) {
    final Map card = event.data['card'];
    if (card['add'] != null ) {
      insertOrUpdateCardFromNetwork(card['add']);
    } else if (card['remove'] != null) {
      field.remove(card['remove']['id']);
    }
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }
}
