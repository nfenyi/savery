import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';
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
    await Hive.box(AppBoxes.user).put('authenticated', false);

    // await appStateBox.put('user', {});
  }

  Future<AuthResult> logInWithFacebook() async {
    final loginResult = await FacebookAuth.instance.login();
    final AccessToken? accessToken = loginResult.accessToken;

    if (accessToken == null) {
      //user has aborted the logging in process
      return AuthResult.aborted;
    }
    final oAuthCredential = FacebookAuthProvider.credential(accessToken.token);

    try {
      await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
      await Hive.box(AppBoxes.appState).put('authenticated', true);
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      final credential = e.credential;
      if (e.code == Constants.accountExistsWithDifferentCredential &&
          email != null &&
          credential != null) {
        // logger.d(e);
        // Is deprecated:
        // final providers = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        //     email!);
        // if (providers.contains(Constants.googleCom)) {
        await loginWithGoogle();
        //TODO: handle errors that can come from this function:
        await FirebaseAuth.instance.currentUser?.linkWithCredential(
          credential,
        );
        // }
        return AuthResult.success;
      } else if (e.code == Constants.accountExistsWithDifferentCredential) {
        showInfoToast(
          context: navigatorKey.currentContext!,
          'It seems you signed in using your google account. Signing in with Google instead',
        );
        return await loginWithGoogle();
      } else {
        await showAppInfoDialog(navigatorKey.currentContext!,
            title: e.toString());
        return AuthResult.failure;
      }
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
      await Hive.box(AppBoxes.appState).put('authenticated', true);
      return AuthResult.success;
    } catch (e) {
      await showAppInfoDialog(navigatorKey.currentContext!,
          title: e.toString());
      return AuthResult.failure;
    }
  }

  Future<AuthResult> createAccountWithEmailAndPassword(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);

        await Hive.box(AppBoxes.appState).put('authenticated', true);

        return AuthResult.success;
      } else {
        return AuthResult.failure;
      }
    } on Exception catch (e) {
      //TODO: make error message user friendly
      await showAppInfoDialog(navigatorKey.currentContext!,
          title: e.toString());
      return AuthResult.failure;
    }
  }

  Future<AuthResult> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

//TODO: Do this for all functions within this class:
      await Hive.box<AppUser>(AppBoxes.user).add(AppUser(
          uid: result.user!.uid,
          displayName: result.user?.displayName,
          email: result.user?.email,
          photoUrl: result.user?.photoURL,
          phoneNumber: result.user?.phoneNumber));

      return AuthResult.success;
    } catch (e) {
      await showAppInfoDialog(navigatorKey.currentContext!,
          title: e.toString());
      return AuthResult.failure;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      await showAppInfoDialog(navigatorKey.currentContext!,
          title: e.toString());
      // switch (e.code) {
      //   case 'invalid-email':
      //     throw InvalidEmailAuthException();
      //   case 'user-not-found':
      //     throw UserNotFoundAuthException();
      //   default:
      //     throw GenericAuthException();
      // }
    }
  }

  // Future<void> verifyPhoneNumber(String phoneNumber) async {
  //   try {
  //     Box box = Hive.box('user');
  //     await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //       timeout: const Duration(minutes: 2),
  //       verificationCompleted: (phoneAuthCredential) async {
  //         await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
  //         User user = FirebaseAuth.instance.currentUser!;
  //         await box.put('user', {
  //           'displayName': user.displayName,
  //           'email': user.email,
  //           'photoUrl': user.photoURL,
  //           'phoneNumber': user.phoneNumber,
  //         });
  //         navigatorKey.currentState!.pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (context) => const MainScreen()), (r) {
  //           return false;
  //         });
  //       },
  //       verificationFailed: (error) {
  //         showInfoToast(error.toString(),
  //             context: navigatorKey.currentContext!);
  //       },
  //       codeSent: (verificationId, forceResendingToken) {
  //         // ref.read(verificationIdProvider.notifier).updateValue(verificationId);
  //         showInfoToast(
  //             "It seems the number you provided is not on this device. Please check the device that bears this number and enter code",
  //             context: navigatorKey.currentContext!);

  //         //will remove page routing later:
  //         navigatorKey.currentState!.pushReplacement(
  //             MaterialPageRoute(builder: (context) => const OTPScreen()));
  //       },
  //       codeAutoRetrievalTimeout: (verificationId) {
  //         // ref.read(verificationIdProvider.notifier).updateValue(verificationId);
  //         // showInfoToast(" ", context: context);
  //       },
  //     );
  //   } catch (e) {
  //     await showAppDialog(navigatorKey.currentContext!, title: e.toString());
  //     // return AuthResult.failure;
  //   }
  // }
}
