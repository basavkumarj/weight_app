import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:weight/account_screen.dart';
import 'package:weight/bloc/account_bloc.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/bloc/dash_bloc.dart';
import 'package:weight/constants.dart';
import 'package:weight/query_tags.dart';
import 'package:weight/utility.dart';
import 'package:weight/widgets.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  DashboardBloc dashboardBloc;
  final _formKey = GlobalKey<FormState>();
  double _weight, _height;

  @override
  void initState() {
    super.initState();
    dashboardBloc = BlocProvider.of<DashboardBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Text("Weight\nManagement System",
            style: GoogleFonts.dmSans(
                textStyle: TextStyle(),
                color: Colors.black87,
                fontWeight: FontWeight.w900)),
        elevation: 0.0,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            StreamBuilder(
                stream: dashboardBloc.bmiStream,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.only(top: 16.0, bottom: 4.0),
                        child: RadialRing(
                          type: snapshot.data != null
                              ? snapshot.data[QueryTags.qBMIType]
                              : Constants.BMI_NORMAL,
                          child: new Column(
                            children: [
                              Text("bmi",
                                  style: GoogleFonts.dmSans(
                                      textStyle: TextStyle(fontSize: 18.0),
                                      color: Colors.black54)),
                              Text(
                                  snapshot.data != null
                                      ? snapshot.data[QueryTags.qBMI].toString()
                                      : "--",
                                  style: GoogleFonts.dmSans(
                                      textStyle: TextStyle(fontSize: 85.0))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                          snapshot.data != null
                                              ? snapshot.data[QueryTags.qWeight]
                                                  .toString()
                                              : "--",
                                          style: GoogleFonts.dmSans(
                                              textStyle:
                                                  TextStyle(fontSize: 25.0))),
                                      Text("weight(kg)",
                                          style: GoogleFonts.dmSans(
                                              textStyle:
                                                  TextStyle(fontSize: 12.0),
                                              color: Colors.black38)),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                          snapshot.data != null
                                              ? snapshot.data[QueryTags.qHeight]
                                                  .toString()
                                              : "--",
                                          style: GoogleFonts.dmSans(
                                              textStyle:
                                                  TextStyle(fontSize: 25.0))),
                                      Text("height(cm)",
                                          style: GoogleFonts.dmSans(
                                              textStyle:
                                                  TextStyle(fontSize: 12.0),
                                              color: Colors.black38)),
                                    ],
                                  )
                                ],
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.12,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RawMaterialButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) {
                                  return BlocProvider<AccountBloc>(
                                    bloc: AccountBloc(),
                                    child: AccountScreen(),
                                  );
                                })).then(
                                    (value) => dashboardBloc.calculateData());
                              },
                              elevation: 2.0,
                              child: Icon(
                                Icons.settings,
                                size: 20.0,
                                color: Colors.black38,
                              ),
                              padding: EdgeInsets.all(16.0),
                              fillColor: Colors.white,
                              shape: CircleBorder(),
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                addWeightDialog();
                              },
                              elevation: 2.0,
                              child: Icon(
                                Icons.add,
                                size: 35.0,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(16.0),
                              fillColor: Colors.red,
                              shape: CircleBorder(),
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                Share.share(
                                    "Hi, my bmi is ${snapshot.data[QueryTags.qBMI]}. What's yours?");
                              },
                              elevation: 2.0,
                              child: Icon(
                                Icons.share,
                                size: 20.0,
                                color: Colors.black38,
                              ),
                              padding: EdgeInsets.all(16.0),
                              fillColor: Colors.white,
                              shape: CircleBorder(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
            new StreamBuilder(
                stream: dashboardBloc.listStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox();
                  } else if (snapshot.hasData &&
                      snapshot.data.documents.length == 0) {
                    return Container();
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.35,
                        minChildSize: 0.35,
                        maxChildSize: 1,
                        builder: (context, draggableScrollController) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20.0)),
                                color: Colors.white),
                            child: ListView(
                              controller: draggableScrollController,
                              padding: EdgeInsets.only(top: 15.0),
                              children: snapshot.data.documents
                                  .map((singleData) => WeightCard(
                                      singleData, dashboardBloc, context))
                                  .toList(),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }

  void addWeightDialog() {
    dashboardBloc.isHeightSaved().then((isHeightSaved) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text("Record Weight",
                            style: GoogleFonts.dmSans(
                                textStyle: TextStyle(fontSize: 18.0),
                                color: Colors.black54)),
                        !isHeightSaved
                            ? TextFormField(
                                autofocus: isHeightSaved ? false : true,
                                inputFormatters: [
                                  new LengthLimitingTextInputFormatter(6),
                                ],
                                validator: (value) {
                                  if (value.length == 0 &&
                                      isHeightSaved == false) {
                                    return "Please enter your height";
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                style: GoogleFonts.dmSans(),
                                decoration: InputDecoration(
                                    hintText: "Enter your height",
                                    hintStyle: GoogleFonts.dmSans(),
                                    suffixText: " cm",
                                    suffixStyle: GoogleFonts.dmSans(),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black38))),
                                onSaved: (value) {
                                  _height = double.parse(value);
                                },
                              )
                            : SizedBox(),
                        TextFormField(
                          autofocus: isHeightSaved ? true : false,
                          inputFormatters: [
                            new LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (value.length == 0) {
                              return "Please enter your weight";
                            }
                            return null;
                          },
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.dmSans(),
                          decoration: InputDecoration(
                              hintText: "Enter today's weight",
                              hintStyle: GoogleFonts.dmSans(),
                              suffixText: " kg",
                              suffixStyle: GoogleFonts.dmSans(),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black38))),
                          onSaved: (value) {
                            _weight = double.parse(value);
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        OutlineButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              _height != null
                                  ? dashboardBloc.saveWeightHeight(
                                      weight: _weight, height: _height)
                                  : dashboardBloc.saveWeight(_weight);
                              Navigator.of(context).pop();
                              dashboardBloc.updateList();
                            }
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
    });
  }
}
