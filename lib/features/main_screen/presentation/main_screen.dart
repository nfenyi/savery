import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';

import 'budget_screen.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'user_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Logger logger = Logger();

  // final Box _box = Hive.box("application");

  // final int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const BudgetScreen(),
    const UserScreen(),
  ];

  int _currentIndex = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   ref.read(transformerMakesProvider.notifier).init();
  // }

  @override
  Widget build(BuildContext context) {
    // int currentIndex = ref.watch(mainScreenIndexProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
          // ref.read(mainScreenIndexProvider.notifier).update(value);
        },
        backgroundColor: Colors.white,
        elevation: 5,
        enableFeedback: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: AppSizes.bodySmallest,
        unselectedFontSize: AppSizes.bodySmallest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral500,
        selectedLabelStyle: GoogleFonts.manrope(
          fontSize: AppSizes.bodySmallest,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: AppSizes.bodySmallest,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            activeIcon: Icon(
              Iconsax.home5,
              color: AppColors.primary,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.wifi),
            activeIcon: Icon(
              Iconsax.wifi5,
              color: AppColors.primary,
            ),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.monitor_mobbile),
            activeIcon: Icon(
              Iconsax.monitor_mobbile5,
              color: AppColors.primary,
            ),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_2user),
            activeIcon: Icon(
              Iconsax.profile_2user5,
              color: AppColors.primary,
            ),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
