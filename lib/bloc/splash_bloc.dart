import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:weight/constants.dart';

class SplashBloc implements BlocBase {
  final _subject = BehaviorSubject<AuthState>();

  Stream<AuthState> get stream => _subject.stream;

  @override
  void dispose() {
    _subject.close();
  }

  SplashBloc() {
    isUserLoggedIn();
  }

  void isUserLoggedIn() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser != null) {
      _subject.add(AuthState.AUTH_STATUS_LOGGED_IN);
    } else {
      _subject.add(AuthState.AUTH_STATUS_NOT_LOGGED_IN);
    }
  }
}
