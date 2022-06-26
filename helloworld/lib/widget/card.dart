import 'dart:ui';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

var logger = Logger();

class CardWidget extends StatelessWidget {
  final void Function(ValueKey<String>, Offset) move;
  final void Function(ValueKey<String>) remove;
  final void Function(ValueKey<String>, bool) triggerFlip;
  final void Function(ValueKey<String>, int) setPrio;
  final String text;
  final Offset offset;
  final Size size;
  final int prio;
  final Color backgroundColor;
  final bool flipable;
  final bool flip;
  final String fliptext;
  
  const CardWidget({Key? key,
    required this.text,
    
    required this.move,
    required this.remove,
    required this.triggerFlip,
    required this.setPrio,

    required this.offset,
    required this.size,
    required this.prio,
    required this.backgroundColor,
    required this.flipable,
    required this.flip,
    required this.fliptext})
    : super(key: key);

  @override
  Widget build(BuildContext context) {

    Widget textWidget = Text(
      flip?fliptext:text,
      textAlign: TextAlign.center,);
    
    Widget upButton = IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.move_up, size: 16.0),
      splashRadius: 16.0,
      iconSize: 16.0,
      onPressed: () {
        setPrio(key as ValueKey<String>, prio + 1);
      });
    Widget downButton = IconButton(
      padding: const EdgeInsets.all(2),
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.move_down, size: 16.0),
      splashRadius: 16.0,
      iconSize: 16.0,
      onPressed: () {
        setPrio(key as ValueKey<String>, prio - 1);
      });
    
    final Widget removeButton = InkWell(
      radius: 16.0,
      borderRadius: BorderRadius.zero,
      child: Ink(
        padding: EdgeInsets.zero,
        child: const Icon(Icons.close, size: 16.0),
      ),
      onLongPress: () {
        remove(key as ValueKey<String>);
      });
    Widget flipButton = InkWell(
      radius: 16.0,
      borderRadius: BorderRadius.zero,
      onLongPress: () {
        triggerFlip(key as ValueKey<String>, !flip);
      },
      child: Ink(
        padding: EdgeInsets.zero,
        child: const Icon(Icons.flip, size: 16.0),
      ),
      );

    List<Widget> controlPanel = [
      removeButton,
      upButton,
      downButton,
    ];
    if (flipable) {
      controlPanel.add(flipButton);
    }
    Widget content = 
      Card(
        color: backgroundColor,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Row(
            children:[
              Expanded(child: 
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  primary: false,
                  child:
                  textWidget)),
              Column(
                children: controlPanel),
            ])));
    return 
      Positioned(
        left: offset.dx,
        top: offset.dy,
        child: Draggable(
          feedback: content,
          childWhenDragging: Container(),
          onDragEnd: (info) {
            RenderBox renderObject = context.findRenderObject()! as RenderBox;
            move(key as ValueKey<String>, offset + renderObject.globalToLocal(info.offset));
          },
          child: content,
      ));
  }

}
