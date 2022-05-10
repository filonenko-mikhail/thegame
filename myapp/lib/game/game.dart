import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logger/logger.dart';

import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import "package:flame_bloc/flame_bloc.dart";

import '../components/card_layer.dart';
import '../components/button.dart';
import '../components/dice.dart';
import 'card_state.dart';

final logger = Logger();

const requestIdentifier = 'RequestEdit';

Vector2 cameraVelocity = Vector2.zero();

class MyGame extends FlameBlocGame
    with
        KeyboardEvents,
        ScrollDetector,
        MouseMovementDetector,
        HasTappables,
        HasDraggables,
        HasHoverables {

  final PushButton newRequest = PushButton("Запрос", 
    margin: const EdgeInsets.only(top: 1, left: 1),
    size: Vector2(100, 40));

  final PushButton zoomin = PushButton("Приблизить", 
    margin: const EdgeInsets.only(top: 1, left: 100),
    size: Vector2(100, 40)); 
  final PushButton zoomout = PushButton("Отдалить", 
    margin: const EdgeInsets.only(top: 1, left: 200),
    size: Vector2(100, 40)); 

  final Dice dice = Dice(margin: const EdgeInsets.only(bottom: 20, left: 20), size: Vector2(100, 100));
          
  static const int defaultFieldNums = 4;
  Vector2 cameraPosition = Vector2.zero();

  final CardLayer cardLayer = CardLayer();
  
  @override
  Color backgroundColor() {
    return Colors.blueGrey;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugMode = true;
  
    cameraPosition = size/2;
    camera.followVector2(cameraPosition);

    cardLayer.size = size;
    add(cardLayer);

    // HUD
    newRequest.callback = () {
      if (overlays.isActive(requestIdentifier)) {
        overlays.remove(requestIdentifier); 
      } else {
        overlays.add(requestIdentifier);
      }
    };
    add(newRequest);

    zoomin.callback = () {
      if (camera.zoom < 1.5) {
        camera.zoom += 0.2;
      }
    };
    add(zoomin);
    zoomout.callback = () {
      if (camera.zoom > 0.5) {
        camera.zoom -= 0.2;
      }
    };
    add(zoomout);

    add(dice);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (overlays.isActive(requestIdentifier)) {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  void onAttach() {
    // TODO when bloc state available
    super.onAttach();
  }
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String title = 'Transformation Game';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: title,
      home: MyStatefulWidget(),
    );
  }
}


class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final textController = TextEditingController();
  Color newColor = Colors.white;
  late GameWidget gameWidget;

  _MyStatefulWidgetState() {
    gameWidget = GameWidget<FlameBlocGame>(
      game: MyGame(),
      overlayBuilderMap: {
        requestIdentifier: (BuildContext ctx, FlameBlocGame game) {
          return 
            Container(
              constraints: BoxConstraints.loose(Size(game.size.x, 500)),
              margin: EdgeInsetsDirectional.all(40),
              color: Colors.white,
              child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите ваш запрос',
                    labelText: 'Запрос',
                  ),
                  controller: textController,
                ),
                ColorPicker(
                  pickerColor: Colors.white,
                  onColorChanged: onColorChanged,
                ),
                TextButton(
                  onPressed: () {
                    onOk(game);
                  }, child: const Text("Создать"),
                ),
                TextButton(
                  onPressed: () {
                    onCancel(game);
                  }, child: const Text("Отмена"),
                )
              ]
            ));
      },
    },
  );
  }

  void onColorChanged(Color val) {
    newColor = val;
  }

  void onOk(FlameBlocGame game) {
    game.read<CardBloc>().addCard(textController.text, 100, 100, newColor.value);
    game.overlays.remove(requestIdentifier);
  }

  void onCancel(FlameBlocGame game) {
    game.overlays.remove(requestIdentifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gameWidget
    );
  }
}
