library p5;

import "dart:math";
import "dart:typed_data";
import "dart:ui";

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/*
 * @Document
 * Based on p5 wrapper by 'andres'
 * @Ref http://andrescolubri.net/blog/2018/06/26/experiments_with_flutter_and_dart.html
 */

class PWidget extends StatelessWidget {
  final pc = new PainterContainer();

//  PPainter painter;

  PWidget(PPainter p) {
//    this.painter = p;
    pc.setp = p;
  }

  @override
  Widget build(BuildContext context) {
//    print("BUILDING WIDGET...");

//    print(painter);
    return new Container(
      width: pc.getp.fillParent ? null : pc.getp.width.toDouble(),
      height: pc.getp.fillParent ? null : pc.getp.height.toDouble(),
      constraints: pc.getp.fillParent ? BoxConstraints.expand() : null,
      //new
      margin: const EdgeInsets.all(0.0),
      child: new ClipRect(
          child: new CustomPaint(
        painter: pc.getp,
        child: new GestureDetector(
          // The gesture detector needs to be declared here so it can
          // access the context from the CustomPaint, which allows to
          // transforms global positions into local positions relative
          // to the widget.
          onTapDown: (details) {
            pc.getp.onTapDown(context, details);
          },
          onPanStart: (details) {
            pc.getp.onDragStart(context, details);
          },
          onPanUpdate: (details) {
            pc.getp.onDragUpdate(context, details);
          },
          onTapUp: (details) {
            pc.getp.onTapUp(context, details);
          },
//              onTapCancel: (details) {
//
//              },
//              onPanCancel: (details) {
//
//              },
          onPanEnd: (details) {
            pc.getp.onDragEnd(context, details);
          },
        ),
      )),
    );
  }
}

// So just PWidget contains only final fields
class PainterContainer {
  PPainter p;

  set setp(PPainter p) {
    this.p = p;
  }

  PPainter get getp {
    return p;
  }
}

// Animation tutorial
// https://flutter.io/tutorials/animation/
// and code:
// https://raw.githubusercontent.com/flutter/website/master/_includes/code/animation/animate1/main.dart
// https://raw.githubusercontent.com/flutter/website/master/_includes/code/animation/animate3/main.dart
class PAnimator extends AnimationController {
  PAnimator(TickerProvider v)
      : super.unbounded(
            duration: const Duration(milliseconds: 2000), vsync: v) {
    addStatusListener((status) {
      // Loop animation by reversing/forward when status changes.
      if (status == AnimationStatus.completed) {
        reverse();
      } else if (status == AnimationStatus.dismissed) {
        forward();
      }
    });
  }

  void run() {
    forward();
  }
}

class PConstants {
  static const int OPEN = 0;
  static const int CLOSE = 1;

  static const int LINES = 1;
  static const int POINTS = 2;
  static const int POLYGON = 3;

  static const int SQUARE = 1 << 0; // called 'butt' in the svg spec
  static const int ROUND = 1 << 1;
  static const int PROJECT = 1 << 2; // called 'square' in the svg spec

  static const int MITER = 1 << 3;
  static const int BEVEL = 1 << 5;
}

class PPainter extends ChangeNotifier implements CustomPainter {
  bool fillParent = false;
  int width = 100;
  int height = 100;
  Canvas paintCanvas;
  Size paintSize;
  Rect canvasRect;

  int frameCount = 0;

  double mouseX = 0.0;
  double mouseY = 0.0;
  double pmouseX = 0.0;
  double pmouseY = 0.0;

  Paint backPaint = Paint();
  Paint fillPaint = Paint();
  Paint strokePaint = Paint();
  bool useFill = true;
  bool useStroke = true;

  var vertices = List<Offset>();
  Path path = new Path();
  var shapeMode = PConstants.POLYGON;

  PPainter() {
    init();
    setup();
    redraw();
  }

  bool hitTest(Offset position) => null;

  @override
  void paint(Canvas canvas, Size size) {
    paintCanvas = canvas;
    paintSize = size;
    canvasRect = Offset.zero & paintSize;
    draw();
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      // Annotate a the entire P5 widget with the label "P5 Sketch".
      // When text to speech feature is enabled on the device, a user will be
      // able to locate the sun on this picture by touch.
      var rect = Offset.zero & size;
      rect = const Alignment(0.0, 0.0).inscribe(size, rect);
      return [
        new CustomPainterSemantics(
          rect: rect,
          properties: new SemanticsProperties(
            label: 'P5 Sketch',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool shouldRebuildSemantics(PPainter oldDelegate) {
    return false;
  }

  void init() {
    backPaint.style = PaintingStyle.fill;
    backPaint.color = Colors.white;

    fillPaint.style = PaintingStyle.fill;
    fillPaint.color = Colors.white;

    strokePaint.style = PaintingStyle.stroke;
    strokePaint.color = Colors.black;
    strokePaint.strokeCap = StrokeCap.butt;
    strokePaint.strokeJoin = StrokeJoin.bevel;
  }

  //////////////////////////////////////////////////////////////////////////////
  // Touch events

  void updatePointer(Offset offset) {
    pmouseX = mouseX;
    mouseX = offset.dx;

    pmouseY = mouseY;
    mouseY = offset.dy;
  }

  void onTapDown(BuildContext context, TapDownDetails details) {
//    print("onTapDown");
    final RenderBox box = context.findRenderObject();
    final Offset offset = box.globalToLocal(details.globalPosition);
    updatePointer(offset);
    mousePressed();
    redraw();
  }

  void onTapUp(BuildContext context, TapUpDetails details) {
//    print("onTapUp");
    final RenderBox box = context.findRenderObject();
    final Offset offset = box.globalToLocal(details.globalPosition);
    updatePointer(offset);
    mouseReleased();
    redraw();
  }

  void onDragStart(BuildContext context, DragStartDetails details) {
//    print("onDragStart");
    final RenderBox box = context.findRenderObject();
    final Offset offset = box.globalToLocal(details.globalPosition);
    updatePointer(offset);
    mousePressed();
    redraw();
  }

  void onDragUpdate(BuildContext context, DragUpdateDetails details) {
//    print("onDragUpdate");
    final RenderBox box = context.findRenderObject();
    final Offset offset = box.globalToLocal(details.globalPosition);
    updatePointer(offset);
    mouseDragged();
    redraw();
  }

  void onDragEnd(BuildContext context, DragEndDetails details) {
//    print("onDragEnd");
    mouseReleased();
    redraw();
  }

  //////////////////////////////////////////////////////////////////////////////
  // Processing API

  void fullScreen() {
    fillParent = true;
  }

  void size(int w, int h) {
    width = w;
    height = h;
  }

  void setup() {}

  void draw() {}

  void redraw() {
    frameCount++;
    notifyListeners();
  }

  Color color(num r, num g, num b, [num a = 255]) {
    return Color.fromRGBO(r, g, b, a / 255);
  }

  void background(Color color) {
    backPaint.color = color;
    paintCanvas.drawRect(canvasRect, backPaint);
  }

  void stroke(Color color) {
    strokePaint.color = color;
    useStroke = true;
  }

  void strokeWeight(num weight) {
    strokePaint.strokeWidth = weight.toDouble();
  }

  void strokeCap(int cap) {
    if (cap == PConstants.SQUARE) {
      strokePaint.strokeCap = StrokeCap.butt;
    }
    if (cap == PConstants.ROUND) {
      strokePaint.strokeCap = StrokeCap.round;
    }
    if (cap == PConstants.PROJECT) {
      strokePaint.strokeCap = StrokeCap.square;
    }
  }

  void strokeJoin(int join) {
    if (join == PConstants.BEVEL) {
      strokePaint.strokeJoin = StrokeJoin.bevel;
    }
    if (join == PConstants.MITER) {
      strokePaint.strokeJoin = StrokeJoin.miter;
    }
    if (join == PConstants.ROUND) {
      strokePaint.strokeJoin = StrokeJoin.round;
    }
  }

  void noStroke() {
    useStroke = false;
  }

  void fill(Color color) {
    fillPaint.color = color;
    useFill = true;
  }

  void noFill() {
    useFill = false;
  }

  void ellipse(num x, num y, num w, num h) {
    final rect = new Offset(x - w / 2, y - h / 2) & new Size(w, h);
    if (useFill) {
      paintCanvas.drawOval(rect, fillPaint);
    }
    if (useStroke) {
      paintCanvas.drawOval(rect, strokePaint);
    }
  }

  void line(num x1, num y1, num x2, num y2) {
    if (useStroke) {
      paintCanvas.drawLine(new Offset(x1, y1), new Offset(x2, y2), strokePaint);
    }
  }

  void point(num x, num y) {
    if (useStroke) {
      var points = [new Offset(x, y)];
      paintCanvas.drawPoints(PointMode.points, points, strokePaint);
    }
  }

  void quad(num x1, num y1, num x2, num y2, num x3, num y3, num x4, num y4) {
    beginShape();
    vertex(x1, y1);
    vertex(x2, y2);
    vertex(x3, y3);
    vertex(x4, y4);
    endShape(PConstants.CLOSE);
  }

  void rect(num x, num y, num w, num h) {
    final rect = new Offset(x.toDouble(), y.toDouble()) &
        new Size(w.toDouble(), h.toDouble());
    if (useFill) {
      paintCanvas.drawRect(rect, fillPaint);
    }
    if (useStroke) {
      paintCanvas.drawRect(rect, strokePaint);
    }
  }

  void triangle(num x1, num y1, num x2, num y2, num x3, num y3) {
    beginShape();
    vertex(x1, y1);
    vertex(x2, y2);
    vertex(x3, y3);
    endShape();
  }

  void beginShape([int mode = 3]) {
    shapeMode = mode;
    vertices.clear();
  }

  void vertex(num x, num y) {
    vertices.add(Offset(x.toDouble(), y.toDouble()));
  }

  void endShape([int mode = 0]) {
    if (0 < vertices.length) {
      if (shapeMode == PConstants.POINTS || shapeMode == PConstants.LINES) {
        var vlist = List<double>();
        for (var v in vertices) {
          vlist.add(v.dx);
          vlist.add(v.dy);
        }
        var raw = Float32List.fromList(vlist);
        if (shapeMode == PConstants.POINTS) {
          paintCanvas.drawRawPoints(PointMode.points, raw, strokePaint);
        } else {
          paintCanvas.drawRawPoints(PointMode.lines, raw, strokePaint);
        }
      } else {
        path.reset();
        path.addPolygon(vertices, mode == PConstants.CLOSE);
        if (useFill) {
          paintCanvas.drawPath(path, fillPaint);
        }
        if (useStroke) {
          paintCanvas.drawPath(path, strokePaint);
        }
      }
    }
  }

  void translate(num tx, num ty) {
    paintCanvas.translate(tx.toDouble(), ty.toDouble());
  }

  void rotate(num angle) {
    paintCanvas.rotate(angle.toDouble());
  }

  void scale(num sx, num sy) {
    paintCanvas.scale(sx.toDouble(), sy.toDouble());
  }

  void push() {
    paintCanvas.save();
  }

  num radians(num angle) {
    return (angle / 180) * pi;
  }

  num degrees(num angle) {
    return (angle / pi) * 180;
  }

  void pop() {
    paintCanvas.restore();
  }

  void mousePressed() {}

  void mouseDragged() {}

  void mouseReleased() {}
}

class PVector {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;

  PVector(double x, double y, [double z = 0.0]) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}
