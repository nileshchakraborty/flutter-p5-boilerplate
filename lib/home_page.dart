import 'package:flutter/material.dart';
import 'package:p5/p5.dart';

import 'sketch.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  MySketch sketch;
  PAnimator animator;

  @override
  void initState() {
    super.initState();
    sketch = new MySketch();
    // Need an animator to call the draw() method in the sketch continuously,
    // otherwise it will be called only when touch events are detected.
    animator = new PAnimator(this);
    animator.addListener(() {
      setState(() {
        sketch.redraw();
      });
    });
    animator.run();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("P5 Draw!")),
      backgroundColor: const Color.fromRGBO(200, 200, 200, 1.0),
      body: new Center(
        child: new PWidget(sketch),
      ),
    );
  }
}
