import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'widget/dice.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const SingleChildScrollView(
        child: SizedBox(
          height: 2000,
          child: SafeArea(
            bottom: false,
            child: FieldWidget()))),
      drawer: MenuWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            DiceWidget(),
            Spacer(),
          ],
        ),
      ),
    );
  }

}
