
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

import 'package:logger/logger.dart';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';

import 'package:flutter_bloc/flutter_bloc.dart';


var logger = Logger();

class GameState {
  bool connected = false;
  Map<String, Vector2> clientPointers = {};
  Map<String, Map> cards = {};

  GameState();

  GameState.clone(GameState other) {
    clientPointers = Map.from(other.clientPointers);
    cards = Map.from(other.cards);
    connected = other.connected;
  }
}

abstract class OnlineEvent {}
@immutable
class OfflineBecome implements OnlineEvent {}
@immutable
class OnlineBecome implements OnlineEvent {}

@immutable
class OnlineEventMouseMove implements OnlineEvent {
  final String source;
  final double x, y;
  const OnlineEventMouseMove(this.source, this.x, this.y);
}
@immutable
class OnlineClientDisconnected implements OnlineEvent {
  final String source;
  const OnlineClientDisconnected(this.source);
}

class OnlineNewCard implements OnlineEvent {
  final Map card;
  const OnlineNewCard(this.card);
}
class OnlineGetCards implements OnlineEvent {
  final List<Map<String, dynamic>> cards;
  const OnlineGetCards(this.cards);
}

class GameBloc extends Bloc<OnlineEvent,GameState> {
  int tryConnectPause = 3;
  bool isChannelConnected = false;
  late WebSocketChannel channel;
  String clientId = const Uuid().v4();
  String address = 'ws://127.0.0.1:8080/ws';
  int lastMouseSend = DateTime.now().millisecondsSinceEpoch;

  GameBloc() : super(GameState()) {
    on<OnlineEventMouseMove>((event, emit) {
      GameState newstate = GameState.clone(state);
      newstate.clientPointers[event.source] = Vector2(event.x, event.y);
      emit(newstate);
    });
    on<OnlineClientDisconnected>((event, emit) {
      GameState newstate = GameState.clone(state);
      newstate.clientPointers.remove([event.source]);
      emit(newstate);
    });
    on<OnlineBecome>((event, emit) {
      GameState newstate = GameState.clone(state);
      newstate.connected = true;
      emit(newstate);
    });
    on<OfflineBecome>((event, emit) {
      GameState newstate = GameState.clone(state);
      newstate.connected = false;
      emit(newstate);
    });

    on<OnlineNewCard>((event, emit) {
      GameState newstate = GameState.clone(state);
      newstate.cards[event.card["card_id"]] = event.card;
      emit(newstate);
    });

    on<OnlineGetCards>((event, emit) {
      GameState newstate = GameState.clone(state);
      
      logger.i("TODO");
      emit(newstate);
    });

    connect();
  }

  void handleError(error) async {
    if (isChannelConnected) {
      isChannelConnected = false;
      add(OfflineBecome());
    }
    logger.e(error);
  }
  void onDone() async {
    if (isChannelConnected) {
      isChannelConnected = false;
      add(OfflineBecome());
    }
    logger.i("Start to connect from onDone");
    await Future.delayed(Duration(seconds: tryConnectPause));
    tryConnectPause = tryConnectPause*2;
    connect();
  }

  void connect() async {
    if (isChannelConnected) {
      return;
    }
    logger.i("Trying to connect after ${tryConnectPause}");
    isChannelConnected = false;
    channel = WebSocketChannel.connect(Uri.parse(address + "?client-id=${clientId}"));
    isChannelConnected = true;
    channel.stream.listen(
      processMessage,      
      onError: handleError,
      onDone: onDone,
    );
  }

  void processMessage(event) {
    if (!isChannelConnected) {
      isChannelConnected = true;
      add(OnlineBecome());
    }
    tryConnectPause = 3;

    var eventMap = jsonDecode(event);

    switch (eventMap["event-type"]) {
      case "mouse-move":
        add(OnlineEventMouseMove(eventMap["source"], eventMap["x"], eventMap["y"]));
        break;
      case "client_disconnected":
        add(OnlineClientDisconnected(eventMap["source"]));
        break;
      case "get-cards":
        logger.i('get-cards ${eventMap}');
        break;
      case "new-card":
        logger.i('new-card ${eventMap}');
        add(OnlineNewCard(eventMap["payload"]));
        break;
      default:
    }
  }

  void sendMouseMove(double x, double y) {
    if (!isChannelConnected) {
      return;
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastMouseSend > 200) {
      channel.sink.add('{"event-type":"mouse-move", "x":$x, "y":$y}');
      lastMouseSend = now;
    }
  }

  void sendNewCard() {
    if (!isChannelConnected) {
      logger.e("Could not create new card when not connected");
      return;
    }
    var newCard = {
      "card_id": Uuid().v4(),
      "x" : 0.0,
      "y" : 0.0,
    };
    
    var event = {};
    event["event-type"] = "new-card";
    event["payload"] = newCard;
 
    channel.sink.add(jsonEncode(event));
  }

  void sendGetCards() {
    if (!isChannelConnected) {
      logger.e("Could not get cards when not connected");
      return;
    }

    var event = {};
    event["event-type"] = "get-cards";
 
    channel.sink.add(jsonEncode(event));
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    logger.e('$error, $stackTrace');
    super.onError(error, stackTrace);
  }

  @override
  Future<void> close() {
    logger.i("Closing bloc");
    if (isChannelConnected) {
      logger.i("Closing websocket");
      channel.sink.close();
    }
    return super.close();
  }
}
