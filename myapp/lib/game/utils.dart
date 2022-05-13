import 'dart:async';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flame/input.dart';

var logger = Logger();

Completer<bool> periodic(Duration interval, Function(int cycle) callback) {
  final done = Completer<bool>();

  () async {
    var cycle = 0;
    while (!done.isCompleted) {
      try {
        await callback(cycle);
      } catch (e, s) {
        logger.e("$e $s");
      }
      cycle++;
      await done.future
          .timeout(interval)
          .onError((error, stackTrace) => false);
    }
  }();

  return done;
}

Size textSize(String text, double maxWidth) {
    TextSpan span = TextSpan(text: text);
    TextPainter textPainter = TextPainter(text: span,
                                          textWidthBasis: TextWidthBasis.longestLine,
                                          textDirection: TextDirection.ltr,
                                          );
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    return textPainter.size;
}
