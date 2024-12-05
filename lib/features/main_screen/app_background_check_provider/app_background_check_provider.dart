import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/features/sign_in/local_auth_api/local_auth_api.dart';

import '../../../app_constants/app_constants.dart';

class AppBackgroundCheckNotifier extends StateNotifier<bool> {
  AppBackgroundCheckNotifier()
      : super(!Hive.box(AppBoxes.appState)
            .get('enableBiometrics', defaultValue: false));

  void lock() {
    state = false;
  }

  Future<void> unlock() async {
    final shouldUnlock = await LocalAuthApi.authenticate();
    state = shouldUnlock;
  }
}

final appBackgroundCheckProvider =
    StateNotifierProvider<AppBackgroundCheckNotifier, bool>((ref) {
  return AppBackgroundCheckNotifier();
});
