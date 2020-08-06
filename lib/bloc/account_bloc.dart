import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/query_tags.dart';
import 'package:weight/user_data.dart';

class AccountBloc implements BlocBase {
  final _userSubject = new BehaviorSubject<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get userStream => _userSubject.stream;

  @override
  void dispose() {
    _userSubject.close();
  }

  AccountBloc() {
    getUser();
  }

  Future<void> getUser() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    double height = await UserData().getHeight();
    _userSubject
        .add({QueryTags.qUser: firebaseUser, QueryTags.qHeight: height});
  }

  Future<bool> updateHeight(double height) async {
    await UserData().saveHeight(height);
    getUser();
    return true;
  }

  Future<bool> logout() async {
    await UserData().logout();
    return true;
  }
}
