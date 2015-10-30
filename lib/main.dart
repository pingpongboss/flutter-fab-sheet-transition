import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

void main() {
  runApp(new MaterialApp(
      title: "Flutter Demo",
      routes: {'/': (RouteArguments args) => new FlutterDemo()}));
}

class FlutterDemo extends StatefulComponent {
  FlutterDemoState createState() => new FlutterDemoState();
}

class FlutterDemoState extends State<FlutterDemo> {
  Performance _performance;
  AnimatedValue<double> _translationXValue;
  AnimatedValue<double> _translationYValue;
  AnimatedValue<double> _scrimOpacityValue;

  int totalDuration = 375;
  int xDelay = 0;
  int xDuration = 285;
  int yDelay = 15;
  int yDuration = 360;

  int scrimOpacityDelay = 75;
  int scrimOpacityDuration = 150;

  double fabTranslationX = -75.0;
  double fabTranslationY = -120.0;

  void initState() {
    super.initState();

    WidgetFlutterBinding.instance.addEventListener(_backHandler);

    _performance =
        new Performance(duration: new Duration(milliseconds: totalDuration));
    _translationXValue = new AnimatedValue<double>(0.0,
        end: fabTranslationX,
        curve: new Interval(xDelay / totalDuration.toDouble(),
            (xDelay + xDuration) / totalDuration.toDouble(),
            curve: Curves.fastOutSlowIn));
    _translationYValue = new AnimatedValue<double>(0.0,
        end: fabTranslationY,
        curve: new Interval(yDelay / totalDuration.toDouble(),
            (yDelay + yDuration) / totalDuration.toDouble(),
            curve: Curves.fastOutSlowIn));
    _scrimOpacityValue = new AnimatedValue<double>(0.0,
        end: 1.0,
        curve: new Interval(
            scrimOpacityDelay / totalDuration.toDouble(),
            (scrimOpacityDelay + scrimOpacityDuration) /
                totalDuration.toDouble(),
            curve: Curves.fastOutSlowIn));
  }

  void dispose() {
    WidgetFlutterBinding.instance.removeEventListener(_backHandler);
  }

  Widget build(BuildContext context) {
    return new BuilderTransition(variables: <AnimatedValue<double>>[
      _translationXValue,
      _translationYValue,
      _scrimOpacityValue
    ], performance: _performance, builder: (_) {
      return new Stack([
        new Scaffold(
            toolBar: new ToolBar(center: new Text("Flutter Fab to Sheet Demo")),
            body: new Material(
                child: new Center(child: new Text("Goodbye world!")))),
        new GestureDetector(
            child: new Opacity(
                child: new Container(
                    decoration: new BoxDecoration(
                        backgroundColor: new Color(0x76000000))),
                opacity: _scrimOpacityValue.value),
            onTap: _onScrimPressed),
        new Positioned(
            child: new SizedBox(
                width: 200.0,
                height: 300.0,
                child: new Material(color: new Color(0xFFFF0000))),
            right: getSheetAnimatedRight(),
            bottom: getSheetAnimatedBottom()),
        new Positioned(
            child: new FloatingActionButton(
                child: new Icon(type: 'content/add', size: IconSize.s24),
                onPressed: _onFabPressed),
            right: getFabAnimatedRight(),
            bottom: getFabAnimatedBottom()),
      ]);
    });
  }

  double getFabAnimatedRight() {
    return 15.0 - _translationXValue.value;
  }

  double getFabAnimatedBottom() {
    return 15.0 - _translationYValue.value;
  }

  double getSheetAnimatedRight() {
    return -55.0 - _translationXValue.value;
  }

  double getSheetAnimatedBottom() {
    return -100.0 - _translationYValue.value;
  }

  void _onFabPressed() {
    _performance.forward();
  }

  void _onScrimPressed() {
    _performance.reverse();
  }

  void _backHandler(InputEvent event) {
    if (event.type == 'back') {
      // I want to tell _MaterialAppState._backHandler to not finish the Activity.
      _performance.reverse();
    }
  }
}
