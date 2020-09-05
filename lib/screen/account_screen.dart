import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weight/bloc/account_bloc.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/bloc/splash_bloc.dart';
import 'package:weight/query_tags.dart';
import 'package:weight/screen/splash_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  AccountBloc accountBloc;
  final _formKey = GlobalKey<FormState>();
  double _height;

  @override
  Widget build(BuildContext context) {
    accountBloc = BlocProvider.of<AccountBloc>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: Text("Account Info",
            style: GoogleFonts.dmSans(
                textStyle: TextStyle(fontSize: 20.0),
                color: Colors.black87,
                fontWeight: FontWeight.w900)),
        elevation: 0.0,
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Color(0xFFf2f2f2),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            padding: EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.all(15.0),
            child: StreamBuilder(
              stream: accountBloc.userStream,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Text("No Data"),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("name",
                          style: GoogleFonts.dmSans(
                              textStyle: TextStyle(fontSize: 12.0),
                              color: Colors.black38,
                              fontWeight: FontWeight.w600)),
                      Text(snapshot.data[QueryTags.qUser].displayName,
                          style: GoogleFonts.dmSans(
                              textStyle: TextStyle(fontSize: 20.0),
                              color: Colors.black87,
                              fontWeight: FontWeight.w900)),
                      Text("email",
                          style: GoogleFonts.dmSans(
                              textStyle: TextStyle(fontSize: 12.0),
                              color: Colors.black38,
                              fontWeight: FontWeight.w600)),
                      Text(snapshot.data[QueryTags.qUser].email,
                          style: GoogleFonts.dmSans(
                              textStyle: TextStyle(fontSize: 20.0),
                              color: Colors.black87,
                              fontWeight: FontWeight.w900)),
                      Text("height",
                          style: GoogleFonts.dmSans(
                              textStyle: TextStyle(fontSize: 12.0),
                              color: Colors.black38,
                              fontWeight: FontWeight.w600)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${snapshot.data[QueryTags.qHeight]}cm",
                              style: GoogleFonts.dmSans(
                                  textStyle: TextStyle(fontSize: 20.0),
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900)),
                          GestureDetector(
                            onTap: () {
                              updateHeightDialog(
                                  snapshot.data[QueryTags.qHeight]);
                            },
                            child: Text("change?",
                                style: GoogleFonts.dmSans(
                                    textStyle: TextStyle(fontSize: 16.0),
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600)),
                          )
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: OutlineButton(
                  padding: EdgeInsets.all(12.0),
                  onPressed: () {
                    accountBloc.logout().then((value) {
                      Navigator.of(context).pushAndRemoveUntil(
                          new MaterialPageRoute(
                              builder: (BuildContext context) {
                        return BlocProvider<SplashBloc>(
                          bloc: SplashBloc(),
                          child: SplashScreen(),
                        );
                      }), (_) => false);
                    });
                  },
                  child: Text("logout",
                      style: GoogleFonts.dmSans(
                          textStyle: TextStyle(fontSize: 18.0),
                          color: Colors.red,
                          fontWeight: FontWeight.w800)),
                  highlightElevation: 2.0,
                  highlightedBorderColor: Colors.red,
                ),
                width: double.maxFinite,
              ),
            ),
          )
        ],
      )),
    );
  }

  void updateHeightDialog(double initialValue) {
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
                      TextFormField(
                        autofocus: true,
                        inputFormatters: [
                          new LengthLimitingTextInputFormatter(6),
                        ],
                        validator: (value) {
                          if (value.length == 0) {
                            return "Please enter your height";
                          }
                          return null;
                        },
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.dmSans(),
                        decoration: InputDecoration(
                            hintText: "Enter your height",
                            hintStyle: GoogleFonts.dmSans(),
                            suffixText: " cm",
                            suffixStyle: GoogleFonts.dmSans(),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black38))),
                        onSaved: (value) {
                          _height = double.parse(value);
                        },
                        initialValue: initialValue.toString(),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      OutlineButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            accountBloc.updateHeight(_height);
                            Navigator.of(context).pop();
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
  }
}
