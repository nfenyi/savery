import 'package:flutter_riverpod/flutter_riverpod.dart';

// basic information provider for getting data for inspection
class BottomNavIndexNotifier extends StateNotifier<int> {
  BottomNavIndexNotifier() : super(0);

  void updateIndex(int step) {
    if (step != 2) {
      state = step;
    }
  }

  void rebuildStatsScreen() {
    state = 2;
  }
}

final bottomNavIndexProvider =
    StateNotifierProvider<BottomNavIndexNotifier, int>(
  (ref) => BottomNavIndexNotifier(),
);
