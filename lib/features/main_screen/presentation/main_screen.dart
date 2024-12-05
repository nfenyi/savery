import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ion.dart';
import 'package:iconify_flutter_plus/icons/material_symbols.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/features/main_screen/state/bottom_nav_index_provider.dart';
import 'package:savery/features/new_transaction/presentation/new_transaction_screen.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import '../../../app_constants/app_constants.dart';
import '../../../app_widgets/widgets.dart';
import '../../../themes/themes.dart';
import '../app_background_check_provider/app_background_check_provider.dart';
import '../state/rebuild_stats_screen_provider.dart';
import 'budget_screen.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'user_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  Logger logger = Logger();
  final _userBox = Hive.box<AppUser>(AppBoxes.users);
  final _accountBox = Hive.box<Account>(AppBoxes.accounts);
  final _appStateUid = Hive.box(AppBoxes.appState).get('currentUser');
//appstate changes when the os biometrics dialog is shown(puased) and popped(resumed)
//so this bool prevents unnecessary showing of the biometrics dialog
  bool _lockState = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const PlaceholderWidget(),
    const BudgetsScreen(),
    const UserScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (Hive.box(AppBoxes.appState)
            .get('enableBiometrics', defaultValue: false) &&
        (state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused)) {
      _lockState = true;
      ref.read(appBackgroundCheckProvider.notifier).lock();
    }
    if (Hive.box(AppBoxes.appState)
            .get('enableBiometrics', defaultValue: false) &&
        state == AppLifecycleState.resumed &&
        _lockState == true) {
      ref.read(appBackgroundCheckProvider.notifier).unlock();
      _lockState = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool shouldUnlock = ref.watch(appBackgroundCheckProvider);
    final int bottomNavIndex = ref.watch(bottomNavIndexProvider);
    if (shouldUnlock) {
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
              await Get.to(() => const NewTransactionScreen(),
                  transition: Transition.downToUp);
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
                AppColors.primary,
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
                    ? "Hello, ${_userBox.values.firstWhere(
                          (element) => element.uid == _appStateUid,
                        ).displayName}"
                    : bottomNavIndex == 1
                        ? "Statistics"
                        : bottomNavIndex == 3
                            ? "Budgets"
                            : bottomNavIndex == 4
                                ? 'Profile'
                                : "",
                weight: FontWeight.bold,
                color: bottomNavIndex != 4 ? null : Colors.white,
                size: bottomNavIndex == 0
                    ? AppSizes.heading6
                    : AppSizes.bodySmall,
              ),
              bottomNavIndex == 0
                  ? const AppText(text: 'Save for your goals!')
                  : const SizedBox.shrink()
            ],
          ),
          centerTitle: bottomNavIndex != 0 ? true : false,
          backgroundColor: bottomNavIndex != 4
              ? null
              : ((ref.watch(themeProvider) == 'System' ||
                          ref.watch(themeProvider) == 'Dark') &&
                      (MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark))
                  ? AppColors.primaryDark
                  : AppColors.primary,
          actions:
              // (bottomNavIndex == 4)
              // ? [
              //     AppTextButton(
              //       text: 'Edit',
              //       color: Colors.orange,
              //       callback: () {
              //         // navigatorKey.currentState!.pushReplacement(
              //         //   MaterialPageRoute(
              //         //     builder: (context) => const SignInScreen(),
              //         //   ),
              //         // );
              //       },
              //     ),
              //   ]
              // :
              null,
        ),
        body: _screens[bottomNavIndex],
        bottomNavigationBar: Theme(
          data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent),
          child: Container(
            decoration: ((ref.watch(themeProvider) == 'System' ||
                        ref.watch(themeProvider) == 'Dark') &&
                    (MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark))
                ? const BoxDecoration(
                    border:
                        Border(top: BorderSide(color: AppColors.neutral800)))
                : null,
            child: BottomNavigationBar(
              currentIndex: ref.watch(bottomNavIndexProvider),
              onTap: (value) {
                final previousIndex = ref.read(bottomNavIndexProvider);

                if (value != previousIndex) {
                  if (previousIndex == 1) {
                    ref.read(inStatsScreenProvider.notifier).state = false;
                  }
                  if (value == 1) {
                    ref.read(inStatsScreenProvider.notifier).state = true;
                  }

                  ref.read(bottomNavIndexProvider.notifier).updateIndex(value);
                }
              },
              backgroundColor: ((ref.watch(themeProvider) == 'System' ||
                          ref.watch(themeProvider) == 'Dark') &&
                      (MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark))
                  ? const Color.fromARGB(255, 32, 25, 33)
                  : Colors.white,
              elevation: 5,
              enableFeedback: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: AppSizes.bodySmallest,
              unselectedFontSize: AppSizes.bodySmallest,
              // selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.neutral500,
              selectedLabelStyle: GoogleFonts.manrope(
                fontSize: AppSizes.bodySmallest,
                fontWeight: FontWeight.w500,
                // color: AppColors.primary,
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
                    // color: AppColors.primary,
                  ),
                  icon: Icon(
                    Icons.home_outlined,
                    size: 27,
                    // color: Colors.transparent,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  activeIcon: Iconify(
                    MaterialSymbols.insert_chart_rounded,
                    color: ((ref.watch(themeProvider) == 'System' ||
                                ref.watch(themeProvider) == 'Dark') &&
                            (MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark))
                        ? AppColors.primaryDark
                        : AppColors.primary,
                    size: 27,
                  ),
                  icon: const Iconify(
                    MaterialSymbols.insert_chart_outline_rounded,
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
                    // color: AppColors.primary,
                  ),
                  icon: Icon(
                    Icons.account_balance_wallet_outlined,
                    // color: AppColors.neutral500,
                  ),
                  label: 'Budgets',
                ),
                const BottomNavigationBarItem(
                  activeIcon:
                      // (_userBox.values
                      //             .firstWhere(
                      //               (element) => element.uid == _appStateUid,
                      //             )
                      //             .photoUrl !=
                      //         null)
                      //     ? Stack(
                      //         alignment: Alignment.center,
                      //         children: [
                      //           Container(
                      //             decoration: BoxDecoration(
                      //                 color: ((ref.watch(themeProvider) == 'System' ||
                      //                             ref.watch(themeProvider) ==
                      //                                 'Dark') &&
                      //                         (MediaQuery.platformBrightnessOf(
                      //                                 context) ==
                      //                             Brightness.dark))
                      //                     ? AppColors.primaryDark
                      //                     : AppColors.primary,
                      //                 borderRadius: const BorderRadius.all(
                      //                     Radius.circular(30))),
                      //             height: 27,
                      //             width: 27,
                      //           ),
                      //           CircleAvatar(
                      //             backgroundImage: const AssetImage(
                      //               AppAssets.noProfile,
                      //             ),
                      //             // maxRadius: 5,
                      //             // minRadius: 5,
                      //             radius: 11,
                      //             foregroundImage: NetworkImage(_userBox.values
                      //                 .firstWhere(
                      //                   (element) => element.uid == _appStateUid,
                      //                 )
                      //                 .photoUrl!),
                      //           ),
                      //         ],
                      //       )
                      //     :
                      Icon(
                    Icons.person,
                    // color: AppColors.primary,
                    size: 27,
                  ),
                  icon:
                      //  (_userBox.values
                      //             .firstWhere(
                      //               (element) => element.uid == _appStateUid,
                      //         )
                      //         .photoUrl !=
                      //     null)
                      // ? Stack(
                      //     alignment: Alignment.center,
                      //     children: [
                      //       Container(
                      //         decoration: BoxDecoration(
                      //             // color: ((ref.watch(themeProvider) == 'System' ||
                      //             //             ref.watch(themeProvider) ==
                      //             //                 'Dark') &&
                      //             //         (MediaQuery.platformBrightnessOf(
                      //             //                 context) ==
                      //             //             Brightness.dark))
                      //             //     ? AppColors.primaryDark
                      //             //     : AppColors.primary,
                      //             color: AppColors.neutral600,
                      //             borderRadius: const BorderRadius.all(
                      //                 Radius.circular(30))),
                      //         height: 27,
                      //         width: 27,
                      //       ),
                      //       CircleAvatar(
                      //         backgroundImage: const AssetImage(
                      //           AppAssets.noProfile,
                      //         ),
                      //         // maxRadius: 5,
                      //         // minRadius: 5,
                      //         radius: 11,
                      //         foregroundImage: NetworkImage(_userBox.values
                      //             .firstWhere(
                      //               (element) => element.uid == _appStateUid,
                      //             )
                      //             .photoUrl!),
                      //       ),
                      //     ],
                      //   )
                      // :
                      Icon(Iconsax.user),
                  label: 'User',
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            children: [
              const AppNameWidget(),
              AppText(
                text: 'Simplify your expenses',
                color: ((ref.watch(themeProvider) == 'System' ||
                            ref.watch(themeProvider) == 'Dark') &&
                        (MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark))
                    ? const Color.fromARGB(255, 162, 166, 173)
                    : Colors.grey,
              ),
              Gap(Adaptive.h(50)),
              AppTextButton(
                  text: 'Unlock',
                  callback: () async {
                    await ref
                        .read(appBackgroundCheckProvider.notifier)
                        .unlock();
                  })
            ],
          ),
        ),
      );
    }
  }
}

class PlaceholderWidget extends ConsumerWidget {
  const PlaceholderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(bottomNavIndexProvider.notifier).updateIndex(1);
    });
    return const SafeArea(
        child: Column(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [AppLoader(), Gap(10), AppText(text: 'Loading...')],
            ),
          ),
        ),
      ],
    ));
  }
}
