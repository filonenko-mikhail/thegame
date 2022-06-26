import 'dart:ui';
import 'dart:async';
import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:graphql/client.dart';

import '../model/utils.dart';

var logger = Logger();

class DicePainter extends CustomPainter {

  static final Paint circlePaint = Paint()
    ..color=Colors.black87
    ..style=PaintingStyle.stroke
    ..strokeWidth=3;

  static final Paint buttonPaint = Paint()
    ..color=Colors.black26
    ..style=PaintingStyle.fill;

  static final Paint hoverButtonPaint = Paint()
    ..color=Colors.black87
    ..style=PaintingStyle.fill;

  static const textStyle = TextStyle(
    color: Colors.black,
    fontSize: 24,
  );
  static const selectedTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 24,
  );

  double buttonAngle = 2*pi;
  bool isHover = false;
  int value = 1;

  DicePainter(this.value, this.buttonAngle, this.isHover);

  @override
  void paint(Canvas canvas, Size size) {
    // center button paint
    double radius = min(size.width/2, size.height/2) - 3;
    if (!isHover) { // !is hovered
      canvas.drawCircle(size.center(Offset.zero), radius/2, buttonPaint);
    } else {
      canvas.drawCircle(size.center(Offset.zero), radius/2, hoverButtonPaint);
    }
    
    // outter paints
    if (buttonAngle < 2*pi) {
      canvas.drawArc(Rect.fromCircle(center: size.center(Offset.zero), radius: radius),0, buttonAngle, true, circlePaint);
    } else {
      canvas.drawCircle(size.center(Offset.zero), radius, circlePaint);
    }

    canvas.save();
    canvas.translate(size.width/2, size.height/2);
    
    for (var i=0; i<6; ++i){
      canvas.save();
      canvas.rotate(i*(2*pi/6));
      canvas.translate(0, -radius);

      TextStyle style = textStyle;
      if (value == i + 1) {
        style = selectedTextStyle;
      }
      final textSpan = TextSpan(
        text: (i + 1).toString(),
        style: style,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.translate(-textPainter.width/2, 0);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DicePainter oldDelegate) {
    return oldDelegate.value != value 
      || oldDelegate.isHover != isHover
      || oldDelegate.buttonAngle != buttonAngle;
  }
}

class DiceWidget extends StatefulWidget {
  const DiceWidget({Key? key}) : super(key: key);

  @override
  DiceState createState() => DiceState();
}

class DiceState extends State<DiceWidget> {
  
  static final random = Random.secure();

  double buttonAngle = 2*pi;
  bool isHover = false;
  int value = 1;

  int nextRandom(int min, int max) {
    return min + random.nextInt(max - min);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          isHover = true;
        });
      },
      onExit: (event) {
        setState(() {
          isHover = false;
        });
      },
      child:
        GestureDetector(
          onTapDown: (details) {
            var whole = 25;
            var counter = whole;
            Timer.periodic(Duration(milliseconds: (1000~/whole)), (timer) {

              final int randVal = nextRandom(1, 7);
              counter--;
              setState(() {
                value = randVal;
                buttonAngle = (whole - counter)*(2*pi/whole);
              });

              if (counter == 0) {
                sendDiceVal(randVal);
                
                timer.cancel();
              }
            });
          },
            child: CustomPaint(
              size: const Size(120, 120),
              painter: DicePainter(value, buttonAngle, isHover),
            )
        )
    );
  }

  // NETWORK PART
  final GraphQLClient client;
  final Duration pollInterval;
  late final Completer<bool> task;
  late final Stream subscription;
  late final StreamSubscription stream;

  static final policies = Policies(
    fetch: FetchPolicy.noCache,
  );

  DiceState()
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: Connection.instance.link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                              subscribe: policies,
                            ),),
      pollInterval = const Duration(seconds: 30),
      value = 1,
      super();

  @override
  void initState() {
    final subscriptionRequest = gql(
      r'''
        subscription {
          dice
        }
      ''',
    );
    subscription = client.subscribe(
      SubscriptionOptions(
        document: subscriptionRequest
      ),
    );
    stream = subscription.listen(onMessage);

    task = periodic(pollInterval, poll);
    
    super.initState();
  }

  void onMessage(event) {
    final diceVal = event.data['dice'];
    setState(() {
      value = diceVal;      
    });
  }

  void poll(event) async {
    final diceQuery = gql(r'''
      { dice { val } }
    ''');
    final QueryOptions options = QueryOptions(
        document: diceQuery
      );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    setState(() {
      value = result.data?['dice']['val'];
    });
  }

  void sendDiceVal(int val) async {
    final diceValMutation = gql(r'''
      mutation ($val: Int!){
        dice {
          set(val: $val)
        }
      }
    ''');

    final MutationOptions options = MutationOptions(
      document: diceValMutation,
      variables: <String, dynamic>{
        'val': val,
      },
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
    
    super.dispose();
  }
}
