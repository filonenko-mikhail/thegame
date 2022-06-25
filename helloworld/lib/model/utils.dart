import 'dart:async';

import 'package:graphql/client.dart';
import 'package:logger/logger.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

class Connection {

  static Connection? _instance;

  late Link link;

  Connection._() {
    final Uri myurl = Uri.base;
    final String host = myurl.host;
    int port = 80;
    if (myurl.hasPort) {
      port = myurl.port;
    }

    String endpoint = 'http://${host}:${port}/query';
    String wsendpoint = 'ws://${host}:${port}/query';
    if (kDebugMode) {
      endpoint = 'http://127.0.0.1:8080/query';
      wsendpoint = 'ws://127.0.0.1:8080/query';
    }

    final httpLink = HttpLink(endpoint);
    final wslink = WebSocketLink(wsendpoint);

    link = Link.split((request) => request.isSubscription, wslink, httpLink);
  }

  static Connection get instance => _instance ??= Connection._();
}
