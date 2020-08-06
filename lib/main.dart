import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight/auth_screen.dart';
import 'package:weight/bloc/auth_bloc.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/bloc/dash_bloc.dart';
import 'package:weight/bloc/splash_bloc.dart';
import 'package:weight/dashboard.dart';
import 'package:weight/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance();
    return MaterialApp(
        title: 'Weight MS',
        theme: ThemeData(
          primaryColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocProvider<SplashBloc>(
            child: SplashScreen(), bloc: SplashBloc()));
  }
}
