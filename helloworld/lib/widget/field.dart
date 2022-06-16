import 'dart:ui';
import 'dart:async';

import 'package:graphql/client.dart';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import '../model/card_model.dart';
import '../model/utils.dart';
import 'card.dart';

var logger = Logger();

class FieldWidget extends StatefulWidget {
  const FieldWidget({Key? key}) : super(key: key);

  @override
  FieldState createState() => FieldState();
}

class FieldState extends State<FieldWidget> {
  List<CardWidget> children = [];

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: children);
  }

  void move(ValueKey key, Offset offset, {bool local = true}) {
    final index = children.indexWhere((Widget element) => element.key == key);
    CardWidget child = children[index];
    
    Offset newpos = child.offset + offset;
    CardWidget replacement = CardWidget(text: child.text, 
      move: child.move, 
      remove: child.remove,
      setPrio: child.setPrio,
      triggerFlip: child.triggerFlip,
      offset: newpos,
      size: child.size,
      prio: child.prio,
      backgroundColor: child.backgroundColor,
      flipable: child.flipable,
      flip: child.flip,
      fliptext: child.fliptext,
      key: child.key);
    children[index] = replacement;
    
    setState(() {});

    if (local) {
      moveCard(key.value, newpos.dx, newpos.dy);
    }
  }

  void remove(ValueKey key, {bool local = true}) {
    children.removeAt(children.indexWhere((Widget element) => element.key == key));
    setState(() {});
    if (local) {
      removeCard(key.value);
    }
  }

  void sort() {
    children.sort((Widget a, Widget b) {
      return (a as CardWidget).prio - (b as CardWidget).prio;
    });
  }

  void flip(ValueKey key, {bool local = true}) {
    final index = children.indexWhere((Widget element) => element.key == key);
    CardWidget child = children[index];
    
    CardWidget replacement = CardWidget(text: child.text,
      move: child.move, 
      remove: child.remove,
      setPrio: child.setPrio,
      triggerFlip: child.triggerFlip,
      offset: child.offset,
      size: child.size,
      prio: child.prio,
      backgroundColor: child.backgroundColor,
      flipable: child.flipable,
      flip: !child.flip,
      fliptext: child.fliptext,
      key: child.key);
    children[index] = replacement;
    
    setState(() {});

    if (local) {
      flipCard(key.value, !child.flip);
    }
  }

  void prio(ValueKey key, int prio, {bool local = true}) {
    final index = children.indexWhere((Widget element) => element.key == key);
    CardWidget child = children[index];
    
    CardWidget replacement = CardWidget(text: child.text,
      move: child.move, 
      remove: child.remove,
      triggerFlip: child.triggerFlip,
      setPrio: child.setPrio,
      offset: child.offset,
      size: child.size,
      prio: prio,
      backgroundColor: child.backgroundColor,
      flipable: child.flipable,
      flip: child.flip,
      fliptext: child.fliptext,
      key: child.key);
    
    insertSorted(index, child, replacement);
    
    setState(() {});

    if (local) {
      changePrioCard(key.value, prio);
    }
  }

  void insertSorted(int index, CardWidget child, CardWidget replacement) {
    children[index] = replacement;

    if (replacement.prio > child.prio) {
      for (int i = index + 1; i < children.length; ++i) {
        if (children[i].prio < replacement.prio) {
          children[i - 1] = children[i];
          children[i] = replacement;
        } else {
          break;
        }
      }
    } else if (replacement.prio < child.prio) {
      for (int i = index - 1; i >= 0; --i) {
        if (children[i].prio > replacement.prio) {
          children[i + 1] = children[i];
          children[i] = replacement;
        } else {
          break;
        }
      }
    }
  }

  // NETWORK PART
  final GraphQLClient client;
  int lastSend;
  int lastPoll;
  final Duration pollInterval;
  final Duration sendInterval;
  late final Completer<bool> task;
  late final Completer<bool> task2;
  late final Stream subscription;
  Map<String, Offset> toSendXY;

  static final policies = Policies(
    fetch: FetchPolicy.noCache,
  );

  FieldState()
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

  @override
  void initState() {
    final subscriptionRequest = gql(
      r'''
        subscription {
          card {
            add {
              id text x y color flipable flip 
              fliptext prio sizex sizey
            }
            remove {
              id
            }
            move {
              id x y
            }
          }
        }
      ''',
    );
    subscription = client.subscribe(
      SubscriptionOptions(
        document: subscriptionRequest
      ),
    );
    subscription.listen(onMessage);
    
    poll(null);

    //task = periodic(pollInterval, poll);
    task2 = periodic(sendInterval, send);

    super.initState();
  }

  void onMessage(event) {
    logger.i(event.data);
    if (event.data.containsKey('add')) {
      addElement(event.data['add']);
      setState(() {});
    } else if (event.data.containsKey('remove')) {
      remove(event.data['remove']['id']);
    } else if (event.data.containsKey('move')) {
      Offset offset = Offset(event.data['move']['id']['x'],
        event.data['move']['id']['y']);
      move(event.data['move']['id'], offset, local: false);
    }
  }

  // timer
  void poll(event) async {
    int now = DateTime.now().millisecondsSinceEpoch;
    //if (now - lastPoll < 200) {
    //  return ;
    //}
    final cardQuery = gql(r'''
      { card 
        {
          list {
            id text x y color flipable flip 
            fliptext prio sizex sizey } } }
    ''');
    final QueryOptions options = QueryOptions(document: cardQuery);

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    final list = result.data?['card']['list'];
    
    list.forEach(addElement);
    setState(() {});

    lastPoll = DateTime.now().millisecondsSinceEpoch;
  }

  void addElement(element) {
    CardModel item = CardModel.fromJson(element);

    final key = ValueKey(item.id);
    final widget = CardWidget(text: item.text, 
      move: move,
      remove: remove,
      setPrio: prio,
      triggerFlip: flip,
      offset: Offset(item.x, item.y),
      size: Size(item.sizex, item.sizey),
      prio: item.prio,
      backgroundColor: Color(item.color),
      flipable: item.flipable,
      flip: item.flip,
      fliptext: item.fliptext,
      key: key);

    final index = children.indexWhere((element) => element.key == widget.key);
    if (index == -1) {
      bool inserted = false;
      for (int i = 0; i < children.length; ++i) {
        if (children[i].prio > widget.prio) {
          children.insert(i, widget);
          inserted = true;
          break;
        }
      }
      if (!inserted) {
        children.add(widget);
      }
    } else {
      CardWidget child = children[index];
      insertSorted(index, child, widget);
    }
  }

  // timer
  void send(event) async {
    final mutation = gql(r'''
        mutation ($id: ID! $x: Float! $y: Float!){
          card {
            move(payload:{id:$id x:$x y:$y}) {
              id
            }
          }
        }
      ''');

    toSendXY.forEach((key, value) async {
      final MutationOptions options = MutationOptions(
        document: mutation,
        variables: <String, dynamic>{
          'id': key,
          'x':  value.dx,
          'y': value.dy,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }
    });
    toSendXY = {};
  }

  

  void moveCard(String id, double x, double y) async {
    toSendXY[id] = Offset(x, y);
  }

  void flipCard(String id, bool flip) async {
    final mutation = gql(r'''
      mutation ($id: ID! $flip: Boolean!){
        card {
          flip(payload: {id:$id flip:$flip}) {
            id
          }
        }
      }
    ''');

    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastSend > 200) {      
      final MutationOptions options = MutationOptions(
        document: mutation,
        variables: {
          "id": id,
          "flip": flip,
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

  void changePrioCard(String id, int prio) async {
    final mutation = gql(r'''
      mutation ($id: ID! $prio: Int!){
        card {
          prio(payload: {id:$id prio:$prio}) {
            id
            prio
          }
        }
      }
    ''');

    int now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastSend > 200) {      
      final MutationOptions options = MutationOptions(
        document: mutation,
        variables: {
          "id": id,
          "prio": prio,
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

  void removeCard(String id) async {
    final mutation = gql(r'''
      mutation ($id: ID!){
        card {
          remove(payload:{id:$id}) {
            id
          }
        }
      }
    ''');

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastSend > 20) {      
      final MutationOptions options = MutationOptions(
        document: mutation,
        variables: <String, dynamic>{
          'id': id,
        },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }

      lastSend = now;
    }
  }

  @override
  void dispose() {
    task.complete(true);
    task2.complete(true);
    super.dispose();
  }
}
