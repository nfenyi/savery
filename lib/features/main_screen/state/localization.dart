import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_constants.dart';

// basic information provider for getting data for inspection
class LocalizationNotifier extends StateNotifier<String> {
  LocalizationNotifier()
      : super(Hive.box(AppBoxes.appState)
            .get('language', defaultValue: 'English'));

  Future<void> changeLanguage(String language) async {
    await Hive.box(AppBoxes.appState).put('language', language);
    state = language;
  }
}

final languageProvider = StateNotifierProvider<LocalizationNotifier, String>(
  (ref) => LocalizationNotifier(),
);
