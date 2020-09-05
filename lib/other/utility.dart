import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight/other/constants.dart';

class Utility {
  static double calulateBMI(double height, double weight) {
    return (weight / pow(height / 100, 2));
  }

  static String firestoreDTFormat(Timestamp timestamp) {
    return DateFormat('EEEE, dd MMMM yyyy ')
        .format(DateTime.parse(timestamp.toDate().toString()));
  }

  static int getBMIType(double bmi) {
    if (bmi < 18.5) {
      return Constants.BMI_UNDERWEIGHT;
    } else if (bmi <= 24.9) {
      return Constants.BMI_NORMAL;
    } else if (bmi <= 29.9) {
      return Constants.BMI_OVERWEIGHT;
    } else {
      return Constants.BMI_OBESE;
    }
  }

  static LinearGradient getBaseShader(int type) {
    if (type <= Constants.BMI_NORMAL) {
      return LinearGradient(colors: [Colors.black12, Colors.black12]);
    } else {
      return LinearGradient(
          colors: [Colors.greenAccent, Colors.green, Color(0xFF006400)]);
    }
  }

  static LinearGradient getTopShader(int type) {
    if (type == Constants.BMI_UNDERWEIGHT) {
      return LinearGradient(
          colors: [Colors.yellow, Colors.amberAccent, Colors.amber]);
    } else if (type == Constants.BMI_NORMAL) {
      return LinearGradient(
          colors: [Colors.greenAccent, Colors.green, Color(0xFF006400)]);
    } else if (type == Constants.BMI_OVERWEIGHT) {
      return LinearGradient(
          colors: [Colors.orange, Colors.deepOrange, Color(0xFFFF0000)]);
    } else {
      return LinearGradient(
          colors: [Colors.red, Color(0xFFFF0000), Colors.black]);
    }
  }
}
