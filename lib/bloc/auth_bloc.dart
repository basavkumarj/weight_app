import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weight/bloc/bloc_provider.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weight/constants.dart';

class AuthBloc extends BlocBase {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final _statusSubject = BehaviorSubject<FirebaseAuthState>();

  Stream<FirebaseAuthState> get statusStream => _statusSubject.stream;

  @override
  void dispose() {
    _statusSubject.close();
  }

  void signInWithGoogle() async {
    final GoogleSignIn googleSignIn = new GoogleSignIn(scopes: ['email']);
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    final AuthResult authResult =
        await firebaseAuth.signInWithCredential(authCredential);
    if (authResult.user != null) {
      _statusSubject.add(FirebaseAuthState.AUTH_STATUS_SUCCESS);
    } else {
      _statusSubject.add(FirebaseAuthState.AUTH_STATUS_ERROR);
    }
  }

  void signInWithApple() async {
    final result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.fullName, Scope.email])
    ]);
    print(result.status);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleCred = result.credential;
        final oauth = OAuthProvider(providerId: 'apple.com');
        final cred = oauth.getCredential(
            idToken: String.fromCharCodes(appleCred.identityToken),
            accessToken: String.fromCharCodes(appleCred.authorizationCode));
        final user = await FirebaseAuth.instance.signInWithCredential(cred);
        UserUpdateInfo updateInfo = UserUpdateInfo();
        updateInfo.displayName =
            "${appleCred.fullName.givenName} ${appleCred.fullName.familyName}";
        await user.user.updateProfile(updateInfo);
        _statusSubject.add(FirebaseAuthState.AUTH_STATUS_SUCCESS);
        break;
      case AuthorizationStatus.cancelled:
        _statusSubject.add(FirebaseAuthState.AUTH_STATUS_CANCELLED);
        break;
      case AuthorizationStatus.error:
        _statusSubject.add(FirebaseAuthState.AUTH_STATUS_ERROR);
        break;
      default:
        _statusSubject.add(FirebaseAuthState.AUTH_STATUS_ERROR);
        break;
    }
  }
}
