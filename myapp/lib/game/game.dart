import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:logger/logger.dart';

import 'package:flutter/services.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart';
import "package:flame_bloc/flame_bloc.dart";
import 'package:uuid/uuid.dart';

import '../components/card_layer.dart';
import '../components/chip_layer.dart';
import '../components/button.dart';
import '../components/dice.dart';
import '../components/intuition.dart';
import 'card_state.dart';
import 'chip_state.dart';
import 'utils.dart';

final logger = Logger();

const requestIdentifier = 'RequestEdit';
const chipIdentifier = 'ChipEdit';

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

  final PushButton newChip = PushButton("Фишка", 
    margin: const EdgeInsets.only(top: 1, left: 300),
    size: Vector2(100, 40));

  final PushButton physicalLevel = PushButton("Физический ур-нь", 
    margin: const EdgeInsets.only(top: 1, left: 400),
    size: Vector2(100, 40));

  final Dice dice = Dice(margin: const EdgeInsets.only(bottom: 20, left: 20), size: Vector2(100, 100));

  final Intuition intuition = Intuition(margin: const EdgeInsets.only(bottom: 20, right: 20), size: Vector2(100, 100));
          
  static const int defaultFieldNums = 4;
  Vector2 cameraPosition = Vector2.zero();

  final CardLayer cardLayer = CardLayer();
  final ChipLayer chipLayer = ChipLayer();
  
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

    chipLayer.size = size;
    add(chipLayer);

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

    newChip.callback = () {
      if (overlays.isActive(chipIdentifier)) {
        overlays.remove(chipIdentifier); 
      } else {
        overlays.add(chipIdentifier);
      }
    };
    add(newChip);

    physicalLevel.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Физический уровень", 
      100, 100, //position
      Colors.redAccent.value, false, false, "", 50, 400, 600);

      read<CardBloc>().addCard(model);
    };
    add(physicalLevel);

    add(dice);
    add(intuition);
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
      themeMode: ThemeMode.dark,
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
  Color newColor = Colors.blue;
  Color newChipColor = Colors.green;
  late GameWidget gameWidget;

  _MyStatefulWidgetState() {
    gameWidget = GameWidget<FlameBlocGame>(
      game: MyGame(),
      overlayBuilderMap: {
        requestIdentifier: (BuildContext ctx, FlameBlocGame game) {
          return 
            Container(
              constraints: BoxConstraints.loose(Size(game.size.x, 500)),
              padding: EdgeInsetsDirectional.all(40),  
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
                  // Use the screenPickerColor as start color.
                  color: newColor,
                  
                  pickersEnabled: {
                    ColorPickerType.accent: false,
                  },
                  enableShadesSelection: false,
                  // Update the screenPickerColor using the callback.
                  onColorChanged: onColorChanged,
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                ),
                TextButton(
                  onPressed: () {
                    onOk(game);
                  }, 
                  child: const Text("Создать"),
                ),
                TextButton(
                  onPressed: () {
                    onCancel(game);
                  },
                  child: const Text("Отмена"),
                )
              ]
            ));
      },
      chipIdentifier: (BuildContext ctx, FlameBlocGame game) {
          return 
            Container(
              constraints: BoxConstraints.loose(Size(game.size.x, 500)),
              padding: EdgeInsetsDirectional.all(40),  
              margin: EdgeInsetsDirectional.all(40),
              color: Colors.white,
              child: Column(
              children: [
                ColorPicker(
                  // Use the screenPickerColor as start color.
                  color: newColor,
                  pickersEnabled: {
                    ColorPickerType.accent: false,
                  },
                  enableShadesSelection: false,
                  // Update the screenPickerColor using the callback.
                  onColorChanged: onChipColorChanged,
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                ),
                TextButton(
                  onPressed: () {
                    onChipOk(game);
                  }, 
                  child: const Text("Создать"),
                ),
                TextButton(
                  onPressed: () {
                    onChipCancel(game);
                  },
                  child: const Text("Отмена"),
                )
              ]
            ));
      }
    },
  );
  }

  void onColorChanged(Color val) {
    newColor = val;
  }

  void onChipColorChanged(Color val) {
    newChipColor = val;
  }

  void onOk(FlameBlocGame game) {
    Size size = textSize(textController.text, 200);

    CardModel model = CardModel(const Uuid().v4(), textController.text, 
      100, 100, //position
      newColor.value, false, false, "", 50, 
      max(size.width, 100), max(size.height, 200));

    game.read<CardBloc>().addCard(model);
    game.overlays.remove(requestIdentifier);
  }

  void onCancel(FlameBlocGame game) {
    game.overlays.remove(requestIdentifier);
  }

void onChipOk(FlameBlocGame game) {
    ChipModel model = ChipModel(const Uuid().v4(), 
      100, 100, //position
      newChipColor.value);

    game.read<ChipBloc>().addChip(model);
    game.overlays.remove(chipIdentifier);
  }

  void onChipCancel(FlameBlocGame game) {
    game.overlays.remove(chipIdentifier);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gameWidget
    );
  }
}
