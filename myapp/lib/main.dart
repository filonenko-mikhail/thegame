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

  final httpLink = HttpLink(
    'http://127.0.0.1:8080/query',
  );
  var clientId = const Uuid().v4();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<DiceBloc>(
        create: (BuildContext context) => DiceBloc(clientId, httpLink, 
          const Duration(seconds: 4))),
      BlocProvider<IntuitionBloc>(
        create: (BuildContext context) => IntuitionBloc(clientId, httpLink, 
          const Duration(seconds: 4))),
      BlocProvider<CardBloc>(
        create: (BuildContext context) => CardBloc(clientId, httpLink, 
          const Duration(seconds: 4), const Duration(seconds: 1))),
      BlocProvider<ChipBloc>(
        create: (BuildContext context) => ChipBloc(clientId, httpLink, 
          const Duration(seconds: 4), const Duration(seconds: 1))),
    ], 
    child: const MyApp()));
}
