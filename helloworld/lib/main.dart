import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'widget/dice.dart';
import 'widget/intuition.dart';
import 'widget/field.dart';
import 'widget/menu.dart';

var logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transformation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLogged = false;
  TextEditingController textController = TextEditingController();

  void onPin () {
    if (textController.text == '2607') {
      setState(() {
        textController.clear();
        isLogged = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget body = const SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 2000,
            width: 2000,
            child: FieldWidget())));
    if (!isLogged) {
      body = Center(
        child: Form(
          child:
          SizedBox(
            width: 200,
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Введите 4 цифры',
                    labelText: 'Passcode',
                  ),
                  controller: textController,
                  onEditingComplete: onPin,
                )),
                ElevatedButton(
                  onPressed: onPin,
                  child: const Text("OK")),
            ]))));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.person),
            onSelected: (value) {
              //print the selected option
              if (value == "exit") {
                setState(() {
                  isLogged = false;  
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: "exit",
                  child: Text("Выйти"),
                )];
            }
          ),
        ],
      ),
      body: body,
      drawer: const MenuWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: const [
            DiceWidget(),
            Spacer(),
            IntuitionWidget(),
          ],
        ),
      ),
    );
  }

}
