import 'dart:async';
import 'dart:math';

import 'package:helloworld/provider/drawer_provider.dart';
import 'package:logger/logger.dart';

import 'package:graphql/client.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/chip_model.dart';
import '../model/utils.dart';
import '../model/card_model.dart';
import '../model/content_model.dart';

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
  
  ContentModel? randomContent(String type) {
    return Provider.of<DrawerProvider>(context, listen: false).randomContent(type);
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

    final ListTile physicalLevel = ListTile(
      onTap: () {
        CardModel model = CardModel(const Uuid().v4(), "Физический уровень", 
        100, 100,
        Colors.red[300]!.value, false, false, "", 0, 400, 500);
        addCardNetwork(model);
      },
      title: const Text("Физический уровень"));
    final ListTile emotionalLevel = ListTile(
      onTap: () {
        CardModel model = CardModel(const Uuid().v4(), "Эмоциональный уровень", 
        100, 100,
        Colors.orange[300]!.value, false, false, "", 3, 400, 500);
        addCardNetwork(model);
      },
      title: const Text("Эмоциональный уровень"));
    final ListTile mentalLevel = ListTile(
      onTap: () {
        CardModel model = CardModel(const Uuid().v4(), "Ментальный уровень", 
        100, 100,
        Colors.yellow[300]!.value, false, false, "", 5, 400, 500);
        addCardNetwork(model);
      },
      title: const Text("Ментальный уровень"));
    final ListTile spiritLevel = ListTile(
      onTap: () {
        CardModel model = CardModel(const Uuid().v4(), "Духовный уровень", 
        100, 100,
        Colors.blue[300]!.value, false, false, "", 7, 400, 500);

        addCardNetwork(model);
      },
      title: const Text("Духовный уровень"));
    final ListTile physicalKnowingTile = ListTile(
      onTap: () {

        ContentModel? candidate = randomContent("PHYSICAL_KNOWING");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;

        CardModel model = CardModel(id, "Осознание", 
          100, 100, //position
          Colors.red[600]!.value,
          true, false,
          candidate.title, 1, 60, 80);
        addCardNetwork(model);
      },
      title: const Text("Физическое Осознание") 
    );
    final ListTile emotionalKnowingTile = ListTile(
      onTap: () {
        ContentModel? candidate = randomContent("EMOTIONAL_KNOWING");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;
        
        CardModel model = CardModel(id, "Осознание", 
          100, 100, //position
          Colors.orange[600]!.value,
          true, false,
          candidate.title, 4, 60, 80);
        addCardNetwork(model);
      },
      title: const Text("Эмоциональное Осознание"));
    final ListTile mentalKnowingTile = ListTile(
      onTap: () {
        ContentModel? candidate = randomContent("MENTAL_KNOWING");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;

        CardModel model = CardModel(id, "Осознание", 
          100, 100, //position
          Colors.yellow[600]!.value,
          true, false,
          candidate.title, 6, 60, 80);
        addCardNetwork(model);
      },
      title: const Text("Ментальное Осознание"));
    final ListTile spiritKnowingTile = ListTile(
      onTap: () {
        ContentModel? candidate = randomContent("SPIRIT_KNOWING");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;

        CardModel model = CardModel(id, "Осознание", 
          100, 100, //position
          Colors.blue[600]!.value,
          true, false,
          candidate.title, 8, 60, 80);
        addCardNetwork(model);
      },
      title: const Text("Духовное Осознание"));

    final ListTile serviceButton = ListTile(
      onTap: () {
        CardModel model = CardModel(const Uuid().v4(), "Служение", 
          100, 100, //position
          Colors.white.value, false, false, "", 8, 60, 80);
        addCardNetwork(model);
      },
      title: const Text("Служение"));

    final ListTile angelButton = ListTile(
      onTap: () {
        ContentModel? candidate = randomContent("ANGEL");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;
        CardModel model = CardModel(id, "Ангел", 
          100, 100,
          Colors.white.value, true, false,
          candidate.title, 8, 120, 80);
        addCardNetwork(model);
      },
      title: const Text("Ангел"));
    
    final ListTile insightButton = ListTile(
      onTap: (() {
        ContentModel? candidate = randomContent("INSIGHT");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;
        CardModel model = CardModel(id, "Прозрение", 
          100, 100,
          Colors.amberAccent.value, true, false,
          candidate.title, 8, 120, 120);
        addCardNetwork(model);
      }),
      title: const Text("Прозрение"));
    final ListTile setbackButton = ListTile(
      onTap: (() {
        ContentModel? candidate = randomContent("SETBACK");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;
        CardModel model = CardModel(id, "Препятствие", 
          100, 100,
          Colors.blueGrey.value, true, false,
          candidate.title, 8, 120, 120);
        addCardNetwork(model);
      }),
      title: const Text("Препятствие"));
    final ListTile feedbackButton = ListTile(
      onTap: () {
        ContentModel? candidate = randomContent("FEEDBACK");
        if (candidate == null) {
          showAlertDialog(context, "Опс", "Эти карточки кончились(");
          return;
        }
        String id = candidate.id;
        CardModel model = CardModel(id, "Обратная связь", 
          100, 100,
          Colors.blueAccent.value, true, false,
          candidate.title, 8, 120, 120);
        addCardNetwork(model);
      },
      title: const Text("Обратная связь"));
    final ListTile painButton = ListTile(
      onTap: (() {
        CardModel model = CardModel(const Uuid().v4(), "Боль", 
          100, 100,
          Colors.blueGrey.value, false, false, "", 8, 60, 60);
        addCardNetwork(model);
      }),
      title: const Text("Боль"));

    return Drawer(
      child: 
        ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Выберите карточку'),
            ),
            ListTile(
              title: const Text('Запрос'),
              onTap: () {
                showDialog(context: context,
                  builder: (BuildContext context) => createRequest);
              },
            ),
            ListTile(
              title: const Text('Фишка'),
              onTap: () {
                showDialog(context: context,
                  builder: (BuildContext context) => createChip);
              },
            ),

            physicalLevel,
            emotionalLevel,
            mentalLevel,
            spiritLevel,

            physicalKnowingTile,
            emotionalKnowingTile,
            mentalKnowingTile,
            spiritKnowingTile,

            angelButton,
            insightButton,
            setbackButton,

            serviceButton,

            painButton,
            feedbackButton,
        ]));
  }

  // NETWORK
  final GraphQLClient client;
  
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
