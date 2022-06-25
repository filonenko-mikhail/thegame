import 'dart:async';
import 'dart:math';

import 'package:logger/logger.dart';

import 'package:flutter/material.dart';

import 'package:graphql/client.dart';

import '../model/utils.dart';

var logger = Logger();

class IntuitionPainter extends CustomPainter {

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

  static const greenTextStyle = TextStyle(
    color: Colors.green,
    fontSize: 24,
  );
  static const redTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 24,
  );

  double buttonAngle = 2*pi;
  bool isHover = false;
  bool localValue = true;

  IntuitionPainter(this.localValue, this.buttonAngle, this.isHover);

  @override
  void paint(Canvas canvas, Size size) {
    // center button paint
    double radius = min(size.width/2, size.height/2) - 3;
    
    // outter paints
    if (buttonAngle < 2*pi) {
      canvas.drawArc(Rect.fromCircle(center: size.center(Offset.zero), radius: radius),0, buttonAngle, true, circlePaint);
    } else {
      canvas.drawCircle(size.center(Offset.zero), radius, circlePaint);
    }

    TextStyle textStyle;
    String text = "";
    if (localValue) {
      text = "Молния";
      textStyle = greenTextStyle;
    } else {
      text = "Слезинка";
      textStyle = redTextStyle;
    }
    {
      canvas.save();
    
      canvas.translate(size.width/2, size.height/2);
      final textSpan = TextSpan(
        text: text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      canvas.translate(-textPainter.width/2, -textPainter.height/2);
      textPainter.paint(canvas, Offset.zero);
    
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(IntuitionPainter oldDelegate) {
    return oldDelegate.localValue != localValue 
      || oldDelegate.isHover != isHover
      || oldDelegate.buttonAngle != buttonAngle;
  }
}

class IntuitionWidget extends StatefulWidget {
  const IntuitionWidget({Key? key}) : super(key: key);

  @override
  IntuitionState createState() => IntuitionState();
}

class IntuitionState extends State<IntuitionWidget> {
  
  static final random = Random.secure();

  double buttonAngle = 2*pi;
  bool isHover = false;
  bool value = true;

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
                value = randVal % 2 == 0;
                buttonAngle = (whole - counter)*(2*pi/whole);
              });

              if (counter == 0) {
                sendIntuitionVal(randVal % 2 == 0);
                
                timer.cancel();
              }
            });
          },
            child: CustomPaint(
              size: const Size(120, 120),
              painter: IntuitionPainter(value, buttonAngle, isHover),
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

  IntuitionState()
    : client=GraphQLClient(cache: GraphQLCache(), 
                           link: Connection.instance.link,
                           defaultPolicies: DefaultPolicies(
                              watchQuery: policies,
                              query: policies,
                              mutate: policies,
                              subscribe: policies,
                            ),),
      pollInterval = const Duration(seconds: 30),
      super();

  @override
  void initState() {
    final subscriptionRequest = gql(
      r'''
        subscription {
          intuition
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
    final val = event.data['intuition'];
    setState(() {
      value = val;      
    });
  }

  void poll(event) async {
    final intuitionQuery = gql(r'''
      { intuition { val } }
    ''');
    final QueryOptions options = QueryOptions(
        document: intuitionQuery
      );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      logger.i(result.exception.toString());
      return;
    }

    setState(() {
      value = result.data?['intuition']['val'];
    });
  }

  void sendIntuitionVal(bool val) async {
    final intuitionValMutation = gql(r'''
      mutation ($val: Boolean!){
        intuition {
          set(val: $val)
        }
      }
    ''');

    final MutationOptions options = MutationOptions(
      document: intuitionValMutation,
      variables: { 'val': val, },
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
