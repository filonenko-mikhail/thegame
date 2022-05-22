import 'package:logger/logger.dart';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'game/dice_state.dart';
import 'game/intuition_state.dart';
import 'game/game.dart';
import 'game/card_state.dart';
import 'game/chip_state.dart';

var logger = Logger();

void main() {

  const endpoint = 'http://127.0.0.1:8080/query';
  const wsendpoint = 'ws://127.0.0.1:8080/query';

  final httpLink = HttpLink(endpoint);
  final wslink = WebSocketLink(wsendpoint);

  final link = Link.split((request) => request.isSubscription, wslink, httpLink);

  var clientId = const Uuid().v4();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<DiceBloc>(
        create: (BuildContext context) => DiceBloc(clientId, link, 
          const Duration(seconds: 30))),
      BlocProvider<IntuitionBloc>(
        create: (BuildContext context) => IntuitionBloc(clientId, link, 
          const Duration(seconds: 30))),
      BlocProvider<CardBloc>(
        create: (BuildContext context) => CardBloc(clientId, link, 
          const Duration(seconds: 30), const Duration(seconds: 1))),
      BlocProvider<ChipBloc>(
        create: (BuildContext context) => ChipBloc(clientId, link, 
          const Duration(seconds: 30), const Duration(seconds: 1))),
    ], 
    child: const MyApp()));
}
