import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:logger/logger.dart';

import 'package:flame/game.dart';
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
import '../components/background_layer.dart';


final logger = Logger();

const requestIdentifier = 'RequestEdit';
const chipIdentifier = 'ChipEdit';

class Stub extends Component {
  @override
  void update(double dt) {
    Future.delayed(Duration(seconds: 1));
    
    super.update(dt);
  }
}

class MyGame extends FlameBlocGame
  with  KeyboardEvents,
        ScrollDetector,
        //MouseMovementDetector,
        HasTappables,
        HasDraggables,
        HasHoverables {

  final PushButton newRequest = PushButton("Запрос", 
    margin: const EdgeInsets.only(top: 1, left: 1),
    size: Vector2(100, 40));
  final PushButton newChip = PushButton("Фишка", 
    margin: const EdgeInsets.only(top: 41, left: 1),
    size: Vector2(100, 40));

  final PushButton physicalLevel = PushButton("Физический", 
    margin: const EdgeInsets.only(top: 1, left: 100),
    size: Vector2(100, 40));
  final PushButton emotionalLevel = PushButton("Эмоциональ\nный", 
    margin: const EdgeInsets.only(top: 1, left: 200),
    size: Vector2(100, 40));
  final PushButton mentalLevel = PushButton("Ментальный", 
    margin: const EdgeInsets.only(top: 1, left: 300),
    size: Vector2(100, 40));
  final PushButton spiritLevel = PushButton("Духовный", 
    margin: const EdgeInsets.only(top: 1, left: 400),
    size: Vector2(100, 40));

  final PushButton physicalKnowing = PushButton("Физическое\nОсознание", 
    margin: const EdgeInsets.only(top: 41, left: 100),
    size: Vector2(100, 40));
  final PushButton emotionalKnowing = PushButton("Эмоциональ\nОсознание", 
    margin: const EdgeInsets.only(top: 41, left: 200),
    size: Vector2(100, 40));
  final PushButton mentalKnowing = PushButton("Ментальное\nОсознание", 
    margin: const EdgeInsets.only(top: 41, left: 300),
    size: Vector2(100, 40));
  final PushButton spiritKnowing = PushButton("Духовное\nОсознание", 
    margin: const EdgeInsets.only(top: 41, left: 400),
    size: Vector2(100, 40));

  final PushButton serviceButton = PushButton("Служение", 
    margin: const EdgeInsets.only(top: 1, left: 500),
    size: Vector2(100, 40));

  final PushButton angelButton = PushButton("Ангел", 
    margin: const EdgeInsets.only(top: 1, left: 600),
    size: Vector2(100, 40));
  
  final PushButton insightButton = PushButton("Прозрение", 
    margin: const EdgeInsets.only(top: 1, left: 700),
    size: Vector2(100, 40));
  final PushButton setbackButton = PushButton("Препятствие", 
    margin: const EdgeInsets.only(top: 41, left: 700),
    size: Vector2(100, 40));
  final PushButton feedbackButton = PushButton("Обратная\nсвязь", 
    margin: const EdgeInsets.only(top: 1, left: 800),
    size: Vector2(100, 40));

  final PushButton painButton = PushButton("Боль",
    margin: const EdgeInsets.only(top: 1, left: 1000),
    size: Vector2(100, 40));
  
  final PushButton zoomin = PushButton("Приблизить", 
    margin: const EdgeInsets.only(top: 1, left: 1200),
    size: Vector2(100, 40)); 
  final PushButton zoomout = PushButton("Отдалить", 
    margin: const EdgeInsets.only(top: 41, left: 1200),
    size: Vector2(100, 40));

  
  final Dice dice = Dice(margin: const EdgeInsets.only(bottom: 20, left: 20), size: Vector2(100, 100));

  final Intuition intuition = Intuition(margin: const EdgeInsets.only(bottom: 20, right: 20), size: Vector2(100, 100));

  final CardLayer cardLayer = CardLayer();
  final ChipLayer chipLayer = ChipLayer();
  final BackgroundLayer backgroundLayer = BackgroundLayer(priority:-100);

  Vector2 cameraPosition = Vector2.zero();
  
  @override
  Color backgroundColor() {
    return Colors.blueGrey;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugMode = false;

    cameraPosition = size/2;
    camera.followVector2(cameraPosition, 
      worldBounds: Rect.fromLTRB(0, 0, 2000, 2000));

    backgroundLayer.size = size;
    //add(backgroundLayer);

    cardLayer.size = size;
    //add(cardLayer);

    chipLayer.size = size;
    //add(chipLayer);

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
      cameraPosition.x, cameraPosition.y,
      Colors.red[300]!.value, false, false, "", -6, 400, 500);

      read<CardBloc>().addCard(model);
    };
    emotionalLevel.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Эмоциональный уровень", 
      cameraPosition.x, cameraPosition.y,
      Colors.orange[300]!.value, false, false, "", -4, 400, 500);

      read<CardBloc>().addCard(model);
    };
    mentalLevel.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Ментальный уровень", 
      cameraPosition.x, cameraPosition.y,
      Colors.yellow[300]!.value, false, false, "", -2, 400, 500);

      read<CardBloc>().addCard(model);
    };
    spiritLevel.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Духовный уровень", 
      cameraPosition.x, cameraPosition.y,
      Colors.blue[300]!.value, false, false, "", 0, 400, 500);

      read<CardBloc>().addCard(model);
    };
    add(physicalLevel);
    add(emotionalLevel);
    add(mentalLevel);
    add(spiritLevel);

    physicalKnowing.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.red[600]!.value,
        true, false,
        // TODO random
        "Здоровье", 11, 60, 80);
      read<CardBloc>().addCard(model);
    };
    emotionalKnowing.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.orange[600]!.value,
        true, false,
        // TODO random
        "Здоровье", 11, 60, 80);
      read<CardBloc>().addCard(model);
    };
    mentalKnowing.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.yellow[600]!.value,
        true, false,
        // TODO random
        "Здоровье", 11, 60, 80);
      read<CardBloc>().addCard(model);
    };
    spiritKnowing.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.blue[600]!.value, 
        true, false,
        // TODO random
        "Здоровье", 11, 60, 80);
      read<CardBloc>().addCard(model);
    };
    add(physicalKnowing);
    add(emotionalKnowing);
    add(mentalKnowing);
    add(spiritKnowing);

    angelButton.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Ангел", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.white.value, true, false,
        // TODO random
        "Ангел: Радость", 10, 120, 60);
      read<CardBloc>().addCard(model);
    };
    add(angelButton);
    // TODO
    insightButton.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Прозрение", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.white.value, true, false,
        // TODO random 
        "Вы справились с завистью. Возьмите 3 осознания.", 11, 120, 120);
      read<CardBloc>().addCard(model);
    };
    add(insightButton);
    // TODO
    setbackButton.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Препятствие", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.white.value, true, false,
        // TODO random 
        "Склонность к сплетням. Возьмите 2 боли.", 11, 120, 120);
      read<CardBloc>().addCard(model);
    };
    add(setbackButton);
    serviceButton.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Служение", 
      cameraPosition.x, cameraPosition.y, //position
      Colors.white.value, false, false, "", 11, 60, 80);
      read<CardBloc>().addCard(model);
    };
    add(serviceButton);
    painButton.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Боль", 
      cameraPosition.x, cameraPosition.y, //position
      Colors.white.value, false, false, "", 11, 60, 60);
      read<CardBloc>().addCard(model);
    };
    add(painButton);
    feedbackButton.callback = () {
      CardModel model = CardModel(const Uuid().v4(), "Обратная связь", 
        cameraPosition.x, cameraPosition.y, //position
        Colors.white.value, true, false,
        // TODO random 
        "Вселенная поддержала вас. Возьмите 2 осознания.", 11, 120, 120);
      read<CardBloc>().addCard(model);
    };
    add(feedbackButton);

    add(dice);
    add(intuition);

    add(Stub());
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

  @override
  void onGameResize(Vector2 canvasSize) {
    cameraPosition.x = canvasSize.x/2;
    cameraPosition.y = canvasSize.y/2;
    super.onGameResize(canvasSize);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    if (cameraPosition.y + info.scrollDelta.game.y > size.y/2) {
      cameraPosition.y += info.scrollDelta.game.y;
    }
    if (cameraPosition.x + info.scrollDelta.game.x > size.x/2) {
      cameraPosition.x += info.scrollDelta.game.x;
    }
    super.onScroll(info);
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String title = 'Transformation Game';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      },),
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
    gameWidget = GameWidget<MyGame>(
      game: MyGame(),
      // overlayBuilderMap: {
      //   requestIdentifier: (BuildContext ctx, MyGame game) {
      //     return 
      //       Container(
      //         constraints: BoxConstraints.loose(Size(game.size.x, game.size.y)),
      //         padding: EdgeInsetsDirectional.all(40),  
      //         margin: EdgeInsetsDirectional.all(40),
      //         color: Colors.white,
      //         child: Column(
      //         children: [
      //           TextField(
      //             decoration: const InputDecoration(
      //               border: OutlineInputBorder(),
      //               hintText: 'Введите ваш запрос',
      //               labelText: 'Запрос',
      //             ),
      //             controller: textController,
      //           ),
      //           ColorPicker(
      //             // Use the screenPickerColor as start color.
      //             color: newColor,
                  
      //             pickersEnabled: {
      //               ColorPickerType.accent: false,
      //             },
      //             enableShadesSelection: false,
      //             // Update the screenPickerColor using the callback.
      //             onColorChanged: onColorChanged,
      //             width: 44,
      //             height: 44,
      //             borderRadius: 22,
      //           ),
      //           TextButton(
      //             onPressed: () {
      //               onOk(game);
      //             }, 
      //             child: const Text("Создать"),
      //           ),
      //           TextButton(
      //             onPressed: () {
      //               onCancel(game);
      //             },
      //             child: const Text("Отмена"),
      //           )
      //         ]
      //       ));
      // },
      // chipIdentifier: (BuildContext ctx, MyGame game) {
      //     return 
      //       Container(
      //         constraints: BoxConstraints.loose(Size(game.size.x, game.size.y)),
      //         padding: EdgeInsetsDirectional.all(40),  
      //         margin: EdgeInsetsDirectional.all(40),
      //         color: Colors.white,
      //         child: Column(
      //         children: [
      //           ColorPicker(
      //             // Use the screenPickerColor as start color.
      //             color: newColor,
      //             pickersEnabled: {
      //               ColorPickerType.accent: false,
      //             },
      //             enableShadesSelection: false,
      //             // Update the screenPickerColor using the callback.
      //             onColorChanged: onChipColorChanged,
      //             width: 44,
      //             height: 44,
      //             borderRadius: 22,
      //           ),
      //           TextButton(
      //             onPressed: () {
      //               onChipOk(game);
      //             }, 
      //             child: const Text("Создать"),
      //           ),
      //           TextButton(
      //             onPressed: () {
      //               onChipCancel(game);
      //             },
      //             child: const Text("Отмена"),
      //           )
      //         ]
      //       ));
      //  }
    //},
  );
  }

  void onColorChanged(Color val) {
    newColor = val;
  }

  void onChipColorChanged(Color val) {
    newChipColor = val;
  }

  // Request Card
  void onOk(MyGame game) {
    Size size = textSize(textController.text, 200);

    CardModel model = CardModel(const Uuid().v4(), 
      textController.text, 
      game.cameraPosition.x/2, game.cameraPosition.y/2,
      newColor.value, false, false, "", 10, 
      max(size.width, 100), max(size.height, 200));

    game.read<CardBloc>().addCard(model);
    game.overlays.remove(requestIdentifier);
  }

  void onCancel(FlameBlocGame game) {
    game.overlays.remove(requestIdentifier);
  }

  // Chip card
  void onChipOk(MyGame game) {
    ChipModel model = ChipModel(const Uuid().v4(), 
      game.cameraPosition.x/2, game.cameraPosition.y/2,
      newChipColor.value);

    game.read<ChipBloc>().addChip(model);
    game.overlays.remove(chipIdentifier);
  }

  void onChipCancel(FlameBlocGame game) {
    game.overlays.remove(chipIdentifier);
    game.renderBox.gameLoop!.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gameWidget
    );
  }
}
