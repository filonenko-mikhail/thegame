import 'dart:async';

import 'package:logger/logger.dart';

import 'package:graphql/client.dart';

import 'package:flutter/material.dart';

import '../model/utils.dart';

var logger = Logger();

class StatusWidget extends StatefulWidget {
  const StatusWidget({Key? key}) : super(key: key);

  @override
  StatusState createState() => StatusState  ();
}

class StatusState extends State<StatusWidget> {

  bool online = false;
  bool ping = false;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.red;
    IconData iconData = Icons.wifi_off;
    if (online) {
      iconData = Icons.wifi_rounded;
      color = Colors.green;
    }
    return Icon(iconData, size: 16, color: color);
  }

  final GraphQLClient client;
  final Duration pollInterval;
  late final Completer<bool> task;
  late final Stream subscription;
  late final StreamSubscription stream;
  
  static final policies = Policies(
    fetch: FetchPolicy.noCache,
  );

  StatusState()
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: Connection.instance.link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                              subscribe: policies,
                              watchMutation: policies,
                            ),),
      pollInterval = const Duration(seconds: 10),
      super();

  @override
  void initState() {
  
    final subscriptionRequest = gql(
      r'''
        subscription { ping }
      ''',
    );
    subscription = client.subscribe(
      SubscriptionOptions(
        document: subscriptionRequest
      ),
    );
    subscription.handleError(onError);
    stream = subscription.listen(onMessage,
      onError: onError,
      onDone: onDone,);
    
    task = periodic(pollInterval, poll);
    
    super.initState();
  }

  // WEBSOCKET PUSH
  void onMessage(event) {
    ping = true;
    setState(() {
      online = true;
    });
  }

  void onError(event) {
    logger.i("BBBBB");
    ping = false;
    setState(() {
      online = false;
    });
  }

  void onDone() {
    logger.i("Dones");
    ping = false;
    setState(() {
      online = false;
    });
  }

  void poll(event) {
    if (!ping) {
      setState(() {
        online = false;
      });
    } else {
      setState(() {
        online = true;
      });
    }
    ping = false;
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }
}
