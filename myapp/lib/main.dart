import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

import 'package:flame/game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game/state.dart';
import 'game/game.dart';

var logger = Logger();

void main() {
  final gameWidget = GameWidget(
      game: MyGame(),
  );
  runApp(BlocProvider(
    create: (_) => GameBloc(),
    child: gameWidget));
}
