//import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart' as appleSignIn;
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:weight/bloc/auth_bloc.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/bloc/splash_bloc.dart';
import 'package:weight/constants.dart';
import 'package:weight/bloc/dash_bloc.dart';
import 'package:weight/dashboard.dart';
import 'package:weight/splash_screen.dart';
import 'package:weight/widgets.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthBloc authBloc;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    authBloc = BlocProvider.of<AuthBloc>(context);
    authBloc.statusStream.listen((event) {
      print(event);
      if (event == Constants.AUTH_STATUS_SUCCESS) {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (BuildContext context) {
          return BlocProvider<SplashBloc>(
            bloc: SplashBloc(),
            child: SplashScreen(),
          );
        }), (_) => false);
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Unable to login. Try again."),
          duration: Duration(seconds: 3),
        ));
      }
    });
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            defaultTargetPlatform == TargetPlatform.iOS
                ? appleSignIn.AppleSignInButton(
                    type: appleSignIn.ButtonType.continueButton,
                    style: appleSignIn.ButtonStyle.black,
                    onPressed: () => authBloc.signInWithApple(),
                  )
                : new SizedBox(),
            SizedBox(
              height: 10.0,
            ),
            GoogleSignInButton(
              onPressed: () => authBloc.signInWithGoogle(),
            ),
            SizedBox(
              height: 50.0,
            )
          ],
        ),
      )),
    );
  }
}