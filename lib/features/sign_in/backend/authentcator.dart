import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:savery/app_widgets/widgets.dart';
import '../constants/constants.dart';
import '../models/auth_state.dart';

class Authenticator {
  const Authenticator();

  String? get userId => FirebaseAuth.instance.currentUser?.uid;
  bool get isAlreadyLoggedIn => userId != null;
  String get displayName =>
      FirebaseAuth.instance.currentUser?.displayName ?? '';
  String? get email => FirebaseAuth.instance.currentUser?.email;

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }

  Future<AuthResult> logInWithFacebook(BuildContext context) async {
    final loginResult = await FacebookAuth.instance.login();
    final token = loginResult.accessToken?.tokenString;
    if (token == null) {
      //user has aborted the logging in process
      return AuthResult.aborted;
    }
    final oAuthCredential = FacebookAuthProvider.credential(token);
    try {
      await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      showAppDialog(context, title: e.toString());
      // final credential = e.credential;
      // if (e.code == Constants.accountExistsWithDifferentCredential &&
      //     email != null &&
      //     credential != null) {
      //Is deprecated:
      // final providers = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
      //     email!); //you may get an error...maybe...according to the IDE 🤷
      // if (providers.contains(Constants.googleCom)) {
      //   await loginWithGoogle();
      //   FirebaseAuth.instance.currentUser?.linkWithCredential(
      //     credential,
      //   );
      // }
      // return AuthResult.success;
      // }
      return AuthResult.failure;
    }
  }

  Future<AuthResult> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      Constants.emailScope,
    ]);
    final signInAccount = await googleSignIn.signIn();
    if (signInAccount == null) {
      return AuthResult.aborted;
    }
    final googleAuth = await signInAccount.authentication;
    final oAuthCredentials = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(
        oAuthCredentials,
      );
      return AuthResult.success;
    } catch (e) {
      return AuthResult.failure;
    }
  }
}
