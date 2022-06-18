import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

var logger = Logger();

class LoginPage extends StatelessWidget {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: 
      Column(children: [
        Text("Login"),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'пароль',
            labelText: 'Пароль',
          ),
          controller: textController,
        ),
        TextButton(
          onPressed: () {
            if (textController.text == '2607') {
              Navigator.of(context).pushNamed("/home");
            }
          },
          child: Text("OK")),
      ]),
    );
  }
}
