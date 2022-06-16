import 'dart:math';

import 'package:helloworld/model/chip_model.dart';
import 'package:logger/logger.dart';

import 'package:graphql/client.dart';

import 'package:flutter/material.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/utils.dart';
import '../model/card_model.dart';

var logger = Logger();

class MenuWidget extends StatefulWidget {
  const MenuWidget({Key? key}) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<MenuWidget> {

  TextEditingController textController = TextEditingController();
  Color cardColor = Colors.blue;
  Color chipColor = Colors.blue;

  void onColorChanged(Color color) {
    cardColor = color;
  }

  void onChipColorChanged(Color color) {
    chipColor = color;
  }
  
  @override
  Widget build(BuildContext context) {
    final createRequest = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
        mainAxisSize: MainAxisSize.min,
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
          pickersEnabled: const {
            ColorPickerType.accent: false,
          },
          enableShadesSelection: false,
          onColorChanged: onColorChanged,
          width: 44,
          height: 44,
          borderRadius: 22,
        ),
        TextButton(
          onPressed: () {
            Size size = textSize(textController.text, 200);

            CardModel model = CardModel(const Uuid().v4(), 
              textController.text, 
              100, 100,
              cardColor.value, false, false, "", 10, 
              160, 200);
            addCardNetwork(model);

            Navigator.of(context, rootNavigator: true)..pop()..pop();
          }, 
          child: const Text("Создать"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)..pop()..pop();
          },
          child: const Text("Отмена"),
        )
      ])));

    final createChip = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child:
      Column(
        mainAxisSize: MainAxisSize.min,
      children: [
        ColorPicker(
          pickersEnabled: const {
            ColorPickerType.accent: false,
          },
          enableShadesSelection: false,
          onColorChanged: onChipColorChanged,
          width: 44,
          height: 44,
          borderRadius: 22,
        ),
        TextButton(
          onPressed: () {
            ChipModel model = ChipModel(
              const Uuid().v4(), 100, 100, chipColor.value);
            addChipNetwork(model);
            Navigator.of(context, rootNavigator: true)..pop()..pop();
          }, 
          child: const Text("Создать"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)..pop()..pop();
          },
          child: const Text("Отмена"),
        )
      ])));

    final TextButton physicalLevel = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Физический уровень", 
        100, 100,
        Colors.red[300]!.value, false, false, "", 0, 400, 500);
        addCardNetwork(model);
      },
      child: Text("Физический"));
    final TextButton emotionalLevel = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Эмоциональный уровень", 
        100, 100,
        Colors.orange[300]!.value, false, false, "", 0, 400, 500);
        addCardNetwork(model);
      },
      child: Text("Эмоциональный"));
    final TextButton mentalLevel = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Ментальный уровень", 
        100, 100,
        Colors.yellow[300]!.value, false, false, "", 0, 400, 500);
        addCardNetwork(model);
      },
      child: Text("Ментальный"));
    final TextButton spiritLevel = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Духовный уровень", 
        100, 100,
        Colors.blue[300]!.value, false, false, "", 0, 400, 500);

        addCardNetwork(model);
      },
      child: Text("Духовный"));
    final TextButton physicalKnowing = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        100, 100, //position
        Colors.red[600]!.value,
        true, false,
        // TODO random
        "Здоровье", 11, 60, 80);
        addCardNetwork(model);
      },
      child: Text("Физическое Осознание") 
    );
    final TextButton emotionalKnowing = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        100, 100, //position
        Colors.orange[600]!.value,
        true, false,
        // TODO random
        "Спокойствие", 11, 60, 80);
        addCardNetwork(model);
      },
      child: Text("Эмоциональное Осознание"));
    final TextButton mentalKnowing = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        100, 100, //position
        Colors.yellow[600]!.value,
        true, false,
        // TODO random
        "Умиротворённость", 11, 60, 80);
        addCardNetwork(model);
      },
      child: Text("Ментальное Осознание"));
    final TextButton spiritKnowing = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Осознание", 
        100, 100, //position
        Colors.blue[600]!.value,
        true, false,
        // TODO random
        "Воссоединение", 11, 60, 80);
        addCardNetwork(model);
      },
      child: Text("Духовное Осознание"));

    final TextButton serviceButton = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Служение", 
        100, 100, //position
        Colors.white.value, false, false, "", 11, 60, 80);
        addCardNetwork(model);
      },
      child: Text("Служение"));

    final TextButton angelButton = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Ангел", 
        100, 100,
        Colors.white.value, true, false,
        // TODO random
        "Ангел: Радость", 10, 120, 80);
        addCardNetwork(model);
      },
      child: Text("Ангел"));
    
    final TextButton insightButton = TextButton(
      onPressed: (() {
        CardModel model = CardModel(const Uuid().v4(), "Прозрение", 
        100, 100,
        Colors.amberAccent.value, true, false,
        // TODO random 
        "Вы справились с завистью. Возьмите 3 осознания.", 11, 120, 120);
        addCardNetwork(model);
      }),
      child: Text("Прозрение"));
    final TextButton setbackButton = TextButton(
      onPressed: (() {
        CardModel model = CardModel(const Uuid().v4(), "Препятствие", 
        100, 100,
        Colors.blueGrey.value, true, false,
        // TODO random 
        "Склонность к сплетням. Возьмите 2 боли.", 11, 120, 120);
        addCardNetwork(model);
      }),
      child: Text("Препятствие"));
    final TextButton feedbackButton = TextButton(
      onPressed: () {
        CardModel model = CardModel(const Uuid().v4(), "Обратная связь", 
        100, 100,
        Colors.blueAccent.value, true, false,
        // TODO random 
        "Вселенная поддержала вас. Возьмите 2 осознания.", 11, 120, 120);
        addCardNetwork(model);
      },
      child: Text("Обратная связь"));
    final TextButton painButton = TextButton(
      onPressed: (() {
        CardModel model = CardModel(const Uuid().v4(), "Боль", 
        100, 100,
        Colors.blueGrey.value, false, false, "", 11, 60, 60);
        addCardNetwork(model);
      }),
      child: Text("Боль"));

    return Drawer(
      child: Center(child: Column(
        children: [
          TextButton(
            onPressed: () {
              showDialog(context: context,
                builder: (BuildContext context) => createRequest);
            }, 
            child: Text("Запрос")),
          TextButton(
            onPressed: () {
              showDialog(context: context,
                builder: (BuildContext context) => createChip);
            }, 
            child: Text("Фишка")),
          physicalLevel,
          emotionalLevel,
          mentalLevel,
          spiritLevel,

          physicalKnowing,
          emotionalKnowing,
          mentalKnowing,
          spiritKnowing,

          angelButton,
          insightButton,
          setbackButton,

          serviceButton,

          painButton,
          feedbackButton,
        ])));
  }

  // NETWORK  
  final GraphQLClient client;
  late final Stream subscription;
  
  static final policies = Policies(
    fetch: FetchPolicy.noCache,
  );

  MenuState()
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: Connection.instance.link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                              subscribe: policies,
                              watchMutation: policies,
                            ),),
      super();

  void addCardNetwork(CardModel model) async {
    final mutation = gql(r'''
      mutation ($payload: CardAddPayload!){
        card {
          add(payload:$payload) {
            id
          }
        }
      }
    ''');

    final MutationOptions options = MutationOptions(
      document: mutation,
      variables: {
        "payload": model.toJson(),
      }
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }
  }

  void addChipNetwork(ChipModel model) async {
    final mutation = gql(r'''
      mutation ($payload: ChipAddPayload!){
        chip {
          add(payload:$payload) {
            id
          }
        }
      }
    ''');

    final MutationOptions options = MutationOptions(
      document: mutation,
      variables: {
        "payload": model.toJson(),
      }
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }
  }
}
