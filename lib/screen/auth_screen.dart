//import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart' as appleSignIn;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:weight/bloc/auth_bloc.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/bloc/splash_bloc.dart';
import 'package:weight/constants.dart';
import 'package:weight/screen/splash_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthBloc _authBloc;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _authBloc.statusStream.listen((event) {
      print(event);
      if (event == FirebaseAuthState.AUTH_STATUS_SUCCESS) {
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
                ? AppleSignInButton(
                    onPressed: () => _authBloc.signInWithApple(),
                    style: AppleButtonStyle.black,
                  )
                : new SizedBox(),
            SizedBox(
              height: 10.0,
            ),
            GoogleSignInButton(
              onPressed: () => _authBloc.signInWithGoogle(),
              darkMode: true,
            ),
          ],
        ),
      )),
    );
  }
}
