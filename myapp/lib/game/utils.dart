import 'dart:async';

import 'package:logger/logger.dart';

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
