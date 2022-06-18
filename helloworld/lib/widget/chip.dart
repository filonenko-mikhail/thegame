import 'dart:ui';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

var logger = Logger();

class ChipWidget extends StatelessWidget {
  final void Function(ValueKey<String>, Offset) move;
  final void Function(ValueKey<String>) remove;
  final Offset offset;
  final Color color;
  
  const ChipWidget({Key? key,
    required this.move,
    required this.remove,
    required this.offset,
    required this.color,})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content = 
      GestureDetector(
        onLongPress: () {
          remove(key as ValueKey<String>);
        },
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          )));
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Draggable(
          feedback: content,
          childWhenDragging: Container(),
          onDragEnd: (info) {
            RenderBox renderObject = context.findRenderObject()! as RenderBox;
            move(key as ValueKey<String>, offset + renderObject.globalToLocal(info.offset));
          },

      child: content));
  }

}
