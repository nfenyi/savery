import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/features/new_transaction/presentation/new_transaction_screen.dart';

import '../../../app_widgets/widgets.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const NewTransactionScreen(),
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color.fromARGB(
                255,
                224,
                6,
                135,
              ),
              AppColors.primary
            ]),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Container(
            // padding: padding,
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: AppText(
          text: _currentIndex == 0
              ? "Hello, Ann"
              : _currentIndex == 1
                  ? "Statistics"
                  : _currentIndex == 2
                      ? "Budget"
                      : _currentIndex == 3
                          ? 'Profile'
                          : "",
          color: _currentIndex != 3 ? Colors.black : Colors.white,
          size: AppSizes.heading6,
        ),
        centerTitle: _currentIndex != 0 ? true : false,
        backgroundColor: _currentIndex != 3 ? Colors.white : AppColors.primary,
        actions: (_currentIndex == 3)
            ? [
                AppTextButton(
                  text: 'Edit',
                  color: Colors.orange,
                  callback: () {
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(
                    //     builder: (context) => const SignInScreen(),
                    //   ),
                    // );
                  },
                ),
              ]
            : null,
      ),
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
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting_4),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
