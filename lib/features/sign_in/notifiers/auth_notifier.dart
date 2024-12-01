import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:savery/main.dart';
import '../services/authentcator.dart';
import '../models/auth_state.dart';
// import '../user_info/backend/user_info_storage.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _authenticator = const Authenticator();
  // final _userInfoStorage = const UserInfoStorage();

  AuthStateNotifier() : super(const AuthState.unknown()) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
          result: AuthResult.success,
          isLoading: false,
          userId: _authenticator.userId);
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.logOut();
    state = const AuthState.unknown();
  }

  Future<void> logInWithGoogle(WidgetRef ref) async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.loginWithGoogle(ref);
    final userId = _authenticator.userId;

    // if (result == AuthResult.success && userId != null) {
    //   await saveUserInfo(userId: userId);
    // }
    state = AuthState(
      isLoading: false,
      result: result,
      userId: userId,
    );
  }

  Future<void> createAccountWithEmailAndPassword(
      {required String email,
      required String password,
      required String name,
      required WidgetRef ref}) async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.createAccountWithEmailAndPassword(
        email: email, password: password, name: name, ref: ref);
    final userId = _authenticator.userId;

    state = AuthState(
      isLoading: false,
      result: result,
      userId: userId,
    );
  }

  Future<void> sendResetLink(String email, WidgetRef ref) async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.sendPasswordReset(email, ref);
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password, WidgetRef ref) async {
    state = state.copiedWithIsLoading(true);
    final result =
        await _authenticator.signInWithEmailAndPassword(email, password, ref);
    final userId = _authenticator.userId;

    state = AuthState(
      isLoading: false,
      result: result,
      userId: userId,
    );
  }

  Future<void> logInWithFacebook(WidgetRef ref) async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.logInWithFacebook(ref);
    final userId = _authenticator.userId;

    // if (result == AuthResult.success && userId != null) {
    //   await saveUserInfo(userId: userId);
    // }
    state = AuthState(
      isLoading: false,
      result: result,
      userId: userId,
    );
  }

  //  Future<void> verifyPhoneNumber(
  //     String phoneNumber) async {
  //   state = state.copiedWithIsLoading(true);

  //       await _authenticator.verifyPhoneNumber(phoneNumber);

  // }

  // Future<void> saveUserInfo({required String userId}) =>
  //     _userInfoStorage.saveUserInfo(
  //         userId: userId,
  //         displayName: _authenticator.displayName,
  //         email: _authenticator.email);
}
