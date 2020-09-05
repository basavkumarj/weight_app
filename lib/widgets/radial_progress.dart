import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weight/other/constants.dart';
import 'package:weight/other/utility.dart';
import 'package:vector_math/vector_math.dart' as math;

class RadialProgress extends StatefulWidget {
  final double percentValue;
  final Widget child;
  final int type;
  final bool isAnimateDisabled;

  @override
  _RadialProgressState createState() => _RadialProgressState();

  RadialProgress(
      {Key key,
        @required this.child,
        @required this.percentValue,
        @required this.type,
        @required this.isAnimateDisabled})
      : super(key: key);
}

class _RadialProgressState extends State<RadialProgress>
    with SingleTickerProviderStateMixin {
  AnimationController _radialProgressAnimationController;
  Animation<double> _progressAnimation;
  double progressDegrees = 0;

  @override
  void initState() {
    super.initState();
    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  void animate(double value) {
    _progressAnimation = Tween(begin: 0.0, end: 360.0).animate(CurvedAnimation(
        parent: _radialProgressAnimationController, curve: Curves.decelerate))
      ..addListener(() {
        setState(() {
          progressDegrees = value * _progressAnimation.value;
        });
      });
    _radialProgressAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.height * 0.45,
        child: widget.child,
        padding: EdgeInsets.all(16.0),
      ),
      painter: RadialPainter(
          progressDegrees,
          Utility.getBaseShader(widget.type),
          Utility.getTopShader(widget.type),
          widget.type > Constants.BMI_NORMAL),
    );
  }

  @override
  void didUpdateWidget(RadialProgress oldWidget) {
    if (!widget.isAnimateDisabled) _radialProgressAnimationController.reset();
    animate(widget.percentValue);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _radialProgressAnimationController.dispose();
    super.dispose();
  }
}

class RadialPainter extends CustomPainter {
  double _progressInDegrees;
  LinearGradient _topGradient, _baseGradient;
  bool _isClockWise;

  RadialPainter(this._progressInDegrees, this._baseGradient, this._topGradient,
      this._isClockWise);

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    Paint basePaint = Paint()
      ..shader = _baseGradient
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0;
    canvas.drawCircle(center, size.height / 2, basePaint);

    Paint topPaint = Paint()
      ..shader = _topGradient
          .createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18.0;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.height / 2),
        math.radians(-90),
        math.radians(_isClockWise ? _progressInDegrees : -_progressInDegrees),
        false,
        topPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}