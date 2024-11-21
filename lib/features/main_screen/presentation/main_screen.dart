import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ion.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';

import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/features/main_screen/state/bottom_nav_index_provider.dart';
import 'package:savery/features/new_transaction/presentation/new_transaction_screen.dart';

import 'package:savery/features/sign_in/user_info/models/user_model.dart';

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
  final _userBox = Hive.box<AppUser>(AppBoxes.user);
  final _accountBox = Hive.box<Account>(AppBoxes.accounts);

  // final int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    Container(),
    const BudgetsScreen(),
    const UserScreen(),
  ];

  // int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // int currentIndex = ref.watch(mainScreenIndexProvider);
    final int bottomNavIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          //TODO: this would have to be changed to accomodate the situation where another person logs
          //in maybe to make a brief check
          if (_accountBox.isNotEmpty) {
            // await FirebaseFirestore.instance
            //     .doc(
            //         '${FirestoreFieldNames.users}/${FirebaseAuth.instance.currentUser!.uid}')
            //     .get()
            //     .then(
            //       (value) => _accounts = value.data()?.values.first.keys.toList(),
            //     );
            // final rebuild = await navigatorKey.currentState!.push(
            //   MaterialPageRoute(
            //     builder: (context) => const NewTransactionScreen(),
            //   ),
            // );
            final rebuild = await Get.to(() => const NewTransactionScreen(),
                transition: Transition.downToUp);
            //TODO: complete
            // if (rebuild) {
            //   logger.d('rebuild');
            //   setState(() {

            //   });
            // }
          } else {
            showInfoToast('Please create an account first', context: context);
          }
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
              text: bottomNavIndex == 0
                  ? "Hello, ${_userBox.values.first.displayName}"
                  : bottomNavIndex == 1
                      ? "Statistics"
                      : bottomNavIndex == 3
                          ? "Budgets"
                          : bottomNavIndex == 4
                              ? 'Profile'
                              : "",
              weight: FontWeight.bold,
              color: bottomNavIndex != 4 ? Colors.black : Colors.white,
              size:
                  bottomNavIndex == 0 ? AppSizes.heading6 : AppSizes.bodySmall,
            ),
            bottomNavIndex == 0
                ? const AppText(text: 'Save for your goals')
                : const SizedBox.shrink()
          ],
        ),
        centerTitle: bottomNavIndex != 0 ? true : false,
        backgroundColor: bottomNavIndex != 4 ? Colors.white : AppColors.primary,
        actions: (bottomNavIndex == 4)
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
      body: _screens[bottomNavIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: BottomNavigationBar(
          currentIndex: ref.watch(bottomNavIndexProvider),
          onTap: (value) {
            // setState(() {
            //   _currentIndex = value;
            // });

            ref.read(bottomNavIndexProvider.notifier).updateIndex(value);
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
          items: [
            const BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.home_rounded,
                size: 27,
                color: AppColors.primary,
              ),
              icon: Icon(
                Icons.home_outlined,
                size: 27,
                // color: Colors.transparent,
              ),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primary,
                size: 27,
              ),
              icon: Icon(
                Icons.bar_chart_outlined,
                color: AppColors.neutral500,
                size: 27,
              ),
              label: 'Statistics',
            ),
            const BottomNavigationBarItem(
              icon: Iconify(
                Ion.wallet_outline,
                color: Colors.transparent,
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.account_balance_wallet,
                color: AppColors.primary,
              ),
              icon: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.neutral500,
              ),
              label: 'Budgets',
            ),
            BottomNavigationBarItem(
              activeIcon: (_userBox.values.first.photoUrl != null)
                  ? Image.network(_userBox.values.first.photoUrl!)
                  : const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 27,
                    ),
              icon: (_userBox.values.first.photoUrl != null)
                  ? Image.network(_userBox.values.first.photoUrl!)
                  : const Icon(Iconsax.user),
              label: 'User',
            ),
          ],
        ),
      ),
    );
  }
}
