import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_constants/firestore_field_name_constants.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/features/new_transaction/presentation/new_transaction_screen.dart';
import 'package:savery/features/sign_in/constants/constants.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_constants.dart';
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
  final Box<AppUser> _userBox = Hive.box<AppUser>(AppBoxes.user);

  // final int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const BudgetsScreen(),
    const StatisticsScreen(),
    const UserScreen(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // int currentIndex = ref.watch(mainScreenIndexProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          // await FirebaseFirestore.instance
          //     .doc(
          //         '${FirestoreFieldNames.users}/${FirebaseAuth.instance.currentUser!.uid}')
          //     .get()
          //     .then(
          //       (value) => _accounts = value.data()?.values.first.keys.toList(),
          //     );
          await navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => const NewTransactionScreen(),
            ),
          );
        },
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: _currentIndex == 0
                  ? "Hello, ${_userBox.values.first.displayName}"
                  : _currentIndex == 1
                      ? "Budgets"
                      : _currentIndex == 2
                          ? "Statistics"
                          : _currentIndex == 3
                              ? 'Profile'
                              : "",
              weight: FontWeight.bold,
              color: _currentIndex != 3 ? Colors.black : Colors.white,
              size: _currentIndex == 0 ? AppSizes.heading6 : AppSizes.bodySmall,
            ),
            _currentIndex == 0
                ? const AppText(text: 'Save for your goals')
                : const SizedBox.shrink()
          ],
        ),
        centerTitle: _currentIndex != 0 ? true : false,
        backgroundColor: _currentIndex != 3 ? Colors.white : AppColors.primary,
        actions: (_currentIndex == 3)
            ? [
                AppTextButton(
                  text: 'Edit',
                  color: Colors.orange,
                  callback: () {
                    // navigatorKey.currentState!.pushReplacement(
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
            icon: Icon(Iconsax.wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting_4),
            label: 'Statistics',
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
