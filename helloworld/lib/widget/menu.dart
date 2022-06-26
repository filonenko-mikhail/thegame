import 'dart:async';
import 'dart:math';

import 'package:helloworld/model/chip_model.dart';
import 'package:logger/logger.dart';

import 'package:graphql/client.dart';

import 'package:flutter/material.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:uuid/uuid.dart';

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


  Map<String, Map<String, ContentModel> > content = {};
  Map<String, bool> field = {};

  showAlertDialog(BuildContext context, String title, String content) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String randomKey(Map map) {
    if (map.isNotEmpty) {
      return map.keys.elementAt(Random.secure().nextInt(map.length));
    } else {
      return "";
    }
  }

  ContentModel? randomContent(String type) {
    if (!content.containsKey(type)) {
      logger.i("No content for $type while random");
    }
    ContentModel? candidate;
    for (int i=1; i < 20; i++) {
      String key = randomKey(content[type]!);
      candidate = content[type]![key];
      if (!field.containsKey(candidate!.id)) {
        break;
      } else {
        candidate = null;
      }
    }
    return candidate;
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
  final Duration pollInterval;
  late final Completer<bool> task;
  late final Stream subscription;
  late final StreamSubscription stream;
  
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
      pollInterval = const Duration(seconds: 60),
      super();

  @override
  void initState() {
    final query = gql(r'''
      query {
        content {
          list {
            id
            type
            title
            description
          }
        }
      }
    ''');

    final QueryOptions options = QueryOptions(
      document: query
    );

    client.query(options).then(handleContent);

    super.initState();
  }

  void insertOrUpdateContentFromNetwork(element) {
    ContentModel item = ContentModel.fromJson(element);
    if (!content.containsKey(item.type)) {
      content[item.type] = {};
    }
    content[item.type]?[item.id] = item;
  }

  void handleContent(QueryResult result) {
    if (result.hasException) {
      logger.i(result.exception.toString());
      // TODO RETRY
      return;
    }

    final List list = result.data?['content']['list'];    
    list.forEach(insertOrUpdateContentFromNetwork);

    // START WATCHING FIELD
    task = periodic(pollInterval, poll);
    
    final subscriptionRequest = gql(
      r'''
        subscription {
          card {
            add { id }
            remove { id }
          }
        }
      ''',
    );
    subscription = client.subscribe(
      SubscriptionOptions(
        document: subscriptionRequest
      ),
    );
    stream = subscription.listen(onMessage);
  }

  void insertOrUpdateCardFromNetwork(element) {
    field[element['id']] = true;
  }

  void poll(event) async {
    final cardQuery = gql(r'''
      { card { list { id } } }
    ''');
    final QueryOptions options = QueryOptions(document: cardQuery);

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    final List list = result.data?['card']['list'];
    
    field.clear();
    list.forEach(insertOrUpdateCardFromNetwork);
  }

  // WEBSOCKET PUSH
  void onMessage(event) {
    final Map card = event.data['card'];
    if (card['add'] != null ) {
      insertOrUpdateCardFromNetwork(card['add']);
      setState(() {});
    } else if (card['remove'] != null) {
      field.remove(card['remove']['id']);
    }
  }

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

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }
}
