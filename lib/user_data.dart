import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weight/query_tags.dart';

class UserData {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> saveHeight(double height) async {
    SharedPreferences sp = await _prefs;
    sp.setDouble(QueryTags.qHeight, height);
    return sp.commit();
  }


  Future<double> getHeight() async {
    SharedPreferences sp = await _prefs;
    return sp.getDouble(QueryTags.qHeight);
  }



  Future<Null> logout() async {
    SharedPreferences sp = await _prefs;
    sp.clear();
    FirebaseAuth.instance.signOut();
  }
}
