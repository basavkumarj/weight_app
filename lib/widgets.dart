import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weight/bloc/dash_bloc.dart';
import 'package:weight/constants.dart';
import 'package:weight/query_tags.dart';
import 'package:weight/utility.dart';
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

class GoogleSignInButton extends StatelessWidget {
  final GestureTapCallback onPressed;

  GoogleSignInButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: OutlineButton(
        splashColor: Colors.grey,
        onPressed: this.onPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.grey),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage("google_signin_logo.png"), height: 30.0),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Sign in with Google',
                  style:
                      GoogleFonts.roboto(color: Colors.black, fontSize: 18.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WeightCard extends StatelessWidget {
  final DocumentSnapshot data;
  final DashboardBloc bloc;
  final BuildContext context;

  WeightCard(this.data, this.bloc, this.context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.delete),
            ),
            alignment: Alignment.centerRight,
          ),
          direction: DismissDirection.endToStart,
          onDismissed: ((direction) {
            if (direction == DismissDirection.endToStart) {
              bloc.deleteData(data.documentID);
              bloc.updateList();
            }
          }),
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              width: double.maxFinite,
              color: Colors.white,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data[QueryTags.qWeight].toString(),
                          style: GoogleFonts.dmSans(
                              textStyle: TextStyle(fontSize: 25.0))),
                      Text("kg",
                          style: GoogleFonts.dmSans(
                              color: Colors.black54,
                              textStyle: TextStyle(fontSize: 15.0))),
                    ],
                  ),
                  Text(
                      data[QueryTags.qDateTime] != null
                          ? Utility.firestoreDTFormat(data[QueryTags.qDateTime])
                          : "waiting to sync",
                      style: GoogleFonts.dmSans(
                          textStyle: TextStyle(
                              fontSize: 10.0, fontStyle: FontStyle.italic))),
                ],
              ),
            ),
            onDoubleTap: () {
              showDialog(
                  context: this.context,
                  builder: (BuildContext context) {
                    final _editFormKey = GlobalKey<FormState>();
                    double _newWeight;
                    return SimpleDialog(
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.0),
                          color: Colors.white,
                          child: Form(
                            key: _editFormKey,
                            child: Column(
                              children: [
                                Text("Edit Weight",
                                    style: GoogleFonts.dmSans(
                                        textStyle: TextStyle(fontSize: 18.0),
                                        color: Colors.black54)),
                                TextFormField(
                                  autofocus: true,
                                  inputFormatters: [
                                    new LengthLimitingTextInputFormatter(6),
                                  ],
                                  validator: (value) {
                                    if (value.length == 0) {
                                      return "Please enter your weight";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  style: GoogleFonts.dmSans(),
                                  decoration: InputDecoration(
                                      hintText: "Enter today's weight",
                                      hintStyle: GoogleFonts.dmSans(),
                                      suffixText: " kg",
                                      suffixStyle: GoogleFonts.dmSans(),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black38))),
                                  onSaved: (value) {
                                    _newWeight = double.parse(value);
                                  },
                                  initialValue:
                                      data[QueryTags.qWeight].toString(),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                OutlineButton(
                                  onPressed: () {
                                    _editFormKey.currentState.validate();
                                    _editFormKey.currentState.save();
                                    bloc.editData(data.documentID, _newWeight);
                                    Navigator.of(context).pop();
                                    bloc.updateList();
                                  },
                                  child: new Text("Record"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  });
            },
          ),
        ),
        Divider(
          color: Colors.black38,
          height: 0.0,
        )
      ],
    );
  }
}
