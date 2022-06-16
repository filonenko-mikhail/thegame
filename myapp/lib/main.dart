import 'package:logger/logger.dart';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

//import 'package:universal_html/html.dart';

import 'game/dice_state.dart';
import 'game/intuition_state.dart';
import 'game/game.dart';
import 'game/card_state.dart';
import 'game/chip_state.dart';
import 'game/game_widget.dart';


var logger = Logger();

void main() {
  final Uri myurl = Uri.base;
  final String host = myurl.host;
  int port = 80;
  if (myurl.hasPort) {
    port = myurl.port;
  }

  String endpoint = 'http://${host}:${port}/query';
  String wsendpoint = 'ws://${host}:${port}/query';
  if (kDebugMode) {
    endpoint = 'http://127.0.0.1:8080/query';
    wsendpoint = 'ws://127.0.0.1:8080/query';
  }

  final httpLink = HttpLink(endpoint);
  final wslink = WebSocketLink(wsendpoint);

  final link = Link.split((request) => request.isSubscription, wslink, httpLink);
  
  var clientId = const Uuid().v4();

  runApp(
    MultiBlocProvider(
    providers: [
      BlocProvider<DiceBloc>(
        create: (BuildContext context) => DiceBloc(clientId, link, 
          const Duration(seconds: 30))),
      BlocProvider<IntuitionBloc>(
        create: (BuildContext context) => IntuitionBloc(clientId, link, 
          const Duration(seconds: 30))),
      BlocProvider<CardBloc>(
        create: (BuildContext context) => CardBloc(clientId, link, 
        // TODO duration for send
          const Duration(seconds: 30), const Duration(seconds: 20))),
      BlocProvider<ChipBloc>(
        create: (BuildContext context) => ChipBloc(clientId, link, 
        // TODO duration for send
          const Duration(seconds: 30), const Duration(seconds: 20))),
    ], 
    child: MyGameWidget<MyGame>(game: MyGame())
    
    // //child: const MyApp()
    ));
}
