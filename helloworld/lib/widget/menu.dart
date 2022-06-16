import 'package:logger/logger.dart';

import 'package:graphql/client.dart';

import 'package:flutter/material.dart';

import 'package:flex_color_picker/flex_color_picker.dart';

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

  void onColorChanged(Color color) {

  }
  
  @override
  Widget build(BuildContext context) {
    final createRequest = Dialog(
      
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child:
      Column(
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
          // Use the screenPickerColor as start color.
          //color: newColor,
          
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
            Navigator.of(context, rootNavigator: true).pop();
            logger.i("OK");
          }, 
          child: const Text("Создать"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            logger.i("Cancel");
          },
          child: const Text("Отмена"),
        )
      ])));
    // TODO: implement build
    return Drawer(
      child: Center(child: Column(
        children: [
          TextButton(
            onPressed: () {
              showDialog(context: context, 
                builder: (BuildContext context) => createRequest);

              logger.i("Add pressed");
            }, 
            child: Text("Запрос")),
          TextButton(
            onPressed: () {
              logger.i("Chip pressed");
            }, 
            child: Text("Фишка"))
        ])));
  }

  // NETWORK  
  final GraphQLClient client;
  int lastSend;
  int lastPoll;
  final Duration pollInterval;
  final Duration sendInterval;
  late final Stream subscription;
  Map<String, Offset> toSendXY;
  
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
      pollInterval = Duration(seconds: 30),
      sendInterval = Duration(seconds: 1),
      lastSend = DateTime.now().millisecondsSinceEpoch,
      lastPoll = DateTime.now().millisecondsSinceEpoch,
      toSendXY = {},
      super();


  void addCard(CardModel model) async {
    final mutation = gql(r'''
      mutation ($payload: CardAddPayload!){
        card {
          add(payload:$payload) {
            id
          }
        }
      }
    ''');

    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastSend < 200) {
      return;
    }
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

    lastSend = now;
  }
}
