import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weight/screen/auth_screen.dart';
import 'package:weight/bloc/auth_bloc.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/bloc/dash_bloc.dart';
import 'package:weight/bloc/splash_bloc.dart';
import 'package:weight/other/constants.dart';
import 'package:weight/screen/dashboard.dart';

class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SplashBloc splashBloc = BlocProvider.of<SplashBloc>(context);
    splashBloc.stream.listen((status) {
      if (status == AuthState.AUTH_STATUS_LOGGED_IN) {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (BuildContext context) {
          return BlocProvider<DashboardBloc>(
            bloc: DashboardBloc(),
            child: Dashboard(),
          );
        }), (_) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (BuildContext context) {
          return BlocProvider<AuthBloc>(
            bloc: AuthBloc(),
            child: AuthScreen(),
          );
        }), (_) => false);
      }
    });
    return Scaffold(
      body: Container(
        child: Center(
          child: defaultTargetPlatform == TargetPlatform.android
              ? CircularProgressIndicator()
              : CupertinoActivityIndicator(),
        ),
      ),
    );
  }
}
