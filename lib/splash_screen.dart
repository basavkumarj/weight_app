import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weight/auth_screen.dart';
import 'package:weight/bloc/auth_bloc.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/bloc/dash_bloc.dart';
import 'package:weight/bloc/splash_bloc.dart';
import 'package:weight/constants.dart';
import 'package:weight/dashboard.dart';

class SplashScreen extends StatelessWidget {
  SplashBloc splashBloc;

  @override
  Widget build(BuildContext context) {
    splashBloc = BlocProvider.of<SplashBloc>(context);
    splashBloc.stream.listen((status) {
      if (status == Constants.AUTH_STATUS_LOGGED_IN) {
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
    return Container(
      child: Center(
        child: defaultTargetPlatform == TargetPlatform.android
            ? CircularProgressIndicator()
            : CupertinoActivityIndicator(),
      ),
    );
  }
}
