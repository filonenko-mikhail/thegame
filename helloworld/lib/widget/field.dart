import 'dart:async';

import 'package:graphql/client.dart';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import '../model/card_model.dart';
import '../model/chip_model.dart';
import '../model/utils.dart';
import 'card.dart';
import 'chip.dart';

var logger = Logger();

class FieldWidget extends StatefulWidget {
  const FieldWidget({Key? key}) : super(key: key);

  @override
  FieldState createState() => FieldState();
}

class FieldState extends State<FieldWidget> {
  final Widget game = Positioned(
      left: 600,
      top: 100,
      child: SizedBox(
        height: 600,
        width: 600,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/game.png'),
              fit:BoxFit.cover
            )))));
  final Widget heaven = Positioned(
      left: 1200,
      top: 100,
      child: SizedBox(
        height: 200,
        width: 200,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/heaven.png'),
              fit:BoxFit.cover
            )
          ),
        )));

  List<CardWidget> children = [];
  List<ChipWidget> chips = [];

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        game,
        heaven,
        ...children,
        ...chips]);
  }
  
  void moveChip(ValueKey<String> key, Offset offset, {bool local = true}) {
    final index = chips.indexWhere((element) => element.key == key);
    if (index == -1) {
      logger.i("Chip with $key for move not found");
      return;
    }
    ChipWidget child = chips[index];

    if (child.offset == offset) {
      return;
    }
    ChipWidget replacement = ChipWidget(
      move: child.move,
      remove: child.remove,
      offset: offset,
      color: child.color,
      key: child.key);
    
    setState(() {
      chips[index] = replacement;
    });

    if (local) {
      moveChipNetwork(key.value, offset.dx, offset.dy);
    }
  }

  void removeChip(ValueKey<String> key, {bool local = true}) {
    setState(() {
      chips.removeWhere((element) => element.key == key);
    });

    if (local) {
      removeChipNetwork(key.value);
    }
  }

  void move(ValueKey key, Offset offset, {bool local = true}) {
    final index = children.indexWhere((Widget element) => element.key == key);
    if (index == -1) {
      logger.i("Element with $key for move not found");
      return;
    }
    CardWidget child = children[index];
    
    if (child.offset == offset) {
      return;
    }
    CardWidget replacement = CardWidget(text: child.text, 
      move: child.move, 
      remove: child.remove,
      setPrio: child.setPrio,
      triggerFlip: child.triggerFlip,
      offset: offset,
      size: child.size,
      prio: child.prio,
      backgroundColor: child.backgroundColor,
      flipable: child.flipable,
      flip: child.flip,
      fliptext: child.fliptext,
      key: child.key);
    
    setState(() {
      children[index] = replacement;
    });

    if (local) {
      moveCardNetwork(key.value, offset.dx, offset.dy);
    }
  }

  void remove(ValueKey key, {bool local = true}) {
    children.removeWhere((element) => element.key == key);
    setState(() {});
    if (local) {
      removeCardNetwork(key.value);
    }
  }

  void flip(ValueKey key, bool flip, {bool local = true}) {
    final index = children.indexWhere((Widget element) => element.key == key);
    if (index == -1) {
      logger.i("Element with $key for flip not found");
      return;
    }
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
      flip: flip,
      fliptext: child.fliptext,
      key: child.key);
    children[index] = replacement;
    
    setState(() {});

    if (local) {
      flipCardNetwork(key.value, flip);
    }
  }

  void prio(ValueKey key, int prio, {bool local = true}) {
    final index = children.indexWhere((Widget element) => element.key == key);
    if (index == -1) {
      logger.i("Element with $key for prio not found");
      return;
    }
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
      changePrioCardNetwork(key.value, prio);
    }
  }

  void insertSorted(int index, CardWidget child, CardWidget replacement) {
    children[index] = replacement;

    if (replacement.prio > child.prio) {
      for (int i = index + 1; i < children.length; ++i) {
        if (children[i].prio <= replacement.prio) {
          children[i - 1] = children[i];
          children[i] = replacement;
        } else {
          break;
        }
      }
    } else if (replacement.prio < child.prio) {
      for (int i = index - 1; i >= 0; --i) {
        if (children[i].prio >= replacement.prio) {
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
  final Duration pollInterval;
  late final Completer<bool> task;
  late final Stream subscription;
  late final Stream chipSubscription;
  late final StreamSubscription stream;
  late final StreamSubscription chipStream;

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
      pollInterval = const Duration(seconds: 60),
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
            remove { id }
            move { id x y }
            flip { id flip }
            prio { id prio }
          }
        }
      ''',
    );
    subscription = client.subscribe(
      SubscriptionOptions(
        document: subscriptionRequest
      ),
    );
    stream = subscription.listen(onMessage);

    final chipSubscriptionRequest = gql(
      r'''
        subscription {
          chip {
            add { id x y color }
            remove { id }
            move { id x y }
          }
        }
      ''',
    );
    chipSubscription = client.subscribe(
      SubscriptionOptions(
        document: chipSubscriptionRequest
      ),
    );
    chipStream = chipSubscription.listen(onMessage);
    
    poll(null);
    pollChips(null);

    task = periodic(pollInterval, (int _) {
      poll(null);
      pollChips(null);
    });

    super.initState();
  }


  // WEBSOCKET PUSH
  void onMessage(event) {
    if (event.data.containsKey('card')) {
      final Map card = event.data['card'];
      if (card['add'] != null ) {
        insertOrUpdateCardFromNetwork(card['add']);
        setState(() {});
      } else if (card['remove'] != null) {
        ValueKey key = ValueKey<String>(card['remove']['id']);
        remove(key, local: false);
        setState(() {});
      } else if (card['move'] != null) {
        ValueKey key = ValueKey<String>(card['move']['id']);
        Offset offset = Offset(card['move']['x'],
          card['move']['y']);
        move(key, offset, local: false);
      } else if (card['flip'] != null) {
        ValueKey key = ValueKey<String>(card['flip']['id']);
        flip(key, card['flip']['flip'], local: false);
      }
    } else if (event.data.containsKey('chip')) {
      final Map chip = event.data['chip'];
      if (chip['add'] != null) {
        insertOrUpdateChipFromNetwork(chip['add']);
        setState(() {});
      } else if (chip['remove'] != null) {
        final key = ValueKey<String>(chip['remove']['id']);
        removeChip(key, local: false);
      } else if (chip['move'] != null) {
        final key = ValueKey<String>(chip['move']['id']);
        Offset offset = Offset(chip['move']['x'], chip['move']['y']);
        moveChip(key, offset, local: false);
      }
    }
  }

  // timer
  void poll(event) async {
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

    final List list = result.data?['card']['list'];
    
    // TODO clear children
    list.forEach(insertOrUpdateCardFromNetwork);

    setState(() {});
  }

  void pollChips(event) async {
    final chipQuery = gql(r'''
      { chip { list { id x y color} } }
    ''');
    final QueryOptions options = QueryOptions(
        document: chipQuery
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    final List list = result.data?['chip']['list'];
    list.forEach(insertOrUpdateChipFromNetwork);
    setState(() {});
  }

  void insertOrUpdateChipFromNetwork(element) {
    ChipModel item = ChipModel.fromJson(element);
    final key = ValueKey(item.id);
  
    final Offset offset = Offset(item.x, item.y);
    final widget = ChipWidget(
      move: moveChip, 
      remove: removeChip, 
      offset: offset,
      color: Color(item.color),
      key: key,
    );
    final index = chips.indexWhere((element) => element.key == key);
    if (index != -1) {
      chips[index] = widget;
    } else {
      chips.add(widget);
    }
  }

  void insertOrUpdateCardFromNetwork(element) {
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

  void moveCardNetwork(String id, double x, double y) async {
    final mutation = gql(r'''
        mutation ($id: ID! $x: Float! $y: Float!){
          card {
            move(payload:{id:$id x:$x y:$y}) {
              id
            }
          }
        }
      ''');
    final MutationOptions options = MutationOptions(
        document: mutation,
        variables: { 'id': id, 'x':  x, 'y': y, },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }
  }

  void flipCardNetwork(String id, bool flip) async {
    final mutation = gql(r'''
      mutation ($id: ID! $flip: Boolean!){
        card {
          flip(payload: {id:$id flip:$flip}) {
            id
          }
        }
      }
    ''');
    
    final MutationOptions options = MutationOptions(
      document: mutation,
      variables: { "id": id, "flip": flip, }
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }
  }

  void changePrioCardNetwork(String id, int prio) async {
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

    final MutationOptions options = MutationOptions(
      document: mutation,
      variables: { "id": id, "prio": prio, }
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }
  }

  void removeCardNetwork(String id) async {
    final mutation = gql(r'''
      mutation ($id: ID!){
        card {
          remove(payload:{id:$id}) {
            id
          }
        }
      }
    ''');

    final MutationOptions options = MutationOptions(
      document: mutation,
      variables: { 'id': id, },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }
  }

  void moveChipNetwork(String id, double x, double y) async {
    final mutation = gql(r'''
        mutation ($id: ID! $x: Float! $y: Float!) {
          chip {
            move(payload:{id:$id x:$x y:$y}) {
              id
            }
          }
        }
      ''');
    final MutationOptions options = MutationOptions(
        document: mutation,
        variables: { 'id': id, 'x':  x, 'y': y, },
      );

      final QueryResult result = await client.mutate(options);

      if (result.hasException) {
        logger.i(result.exception.toString());
        return;
      }
  }

  void removeChipNetwork(String id) async {
    final mutation = gql(r'''
        mutation ($id: ID!) {
          chip {
            remove(payload:{id:$id}) {
              id
            }
          }
        }
      ''');
    final MutationOptions options = MutationOptions(
      document: mutation,
      variables: { 'id': id, },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }
  }

  @override
  void dispose() {
    task.complete(true);
    stream.cancel();
    chipStream.cancel();
    super.dispose();
  }
}
