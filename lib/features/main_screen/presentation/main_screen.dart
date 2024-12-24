import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/main_screen/state/bottom_nav_index_provider.dart';
import 'package:savery/features/new_transaction/presentation/new_transaction_screen.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:secure_content/secure_content.dart';
import '../../../app_constants/app_constants.dart';
import '../../../app_widgets/widgets.dart';
import '../../../main.dart';
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
  late bool _lock;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const PlaceholderWidget(),
    const BudgetsScreen(),
    const UserScreen(),
  ];

  bool _showBiometricsOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lock = ref.read(appBackgroundCheckProvider);
    if (_lock) ref.read(appBackgroundCheckProvider.notifier).unlock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) return;
    if (Hive.box(AppBoxes.appState)
            .get('enableBiometrics', defaultValue: false) &&
        _showBiometricsOverlay == false &&
        (state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused)) {
      _showBiometricsOverlay = true;
      ref.read(appBackgroundCheckProvider.notifier).lock();
    } else if (_showBiometricsOverlay == true &&
        Hive.box(AppBoxes.appState)
            .get('enableBiometrics', defaultValue: false) &&
        state == AppLifecycleState.resumed &&
        ref.read(appBackgroundCheckProvider) == true) {
      ref.read(appBackgroundCheckProvider.notifier).unlock();
      _showBiometricsOverlay = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _lock = ref.watch(appBackgroundCheckProvider);
    final int bottomNavIndex = ref.watch(bottomNavIndexProvider);
    return SecureWidget(
        debug: _lock,
        protectInAppSwitcherMenu: true,
        overlayWidgetBuilder: (context) {
          // logger.d('hello');
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: ((ref.watch(themeProvider) == 'System' ||
                                    ref.watch(themeProvider) == 'Dark') &&
                                (MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark))
                            ? const Color.fromARGB(255, 32, 25, 33)
                                .withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
              Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                ),
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Column(
                    children: [
                      FaIcon(
                        Icons.lock,
                        color: ((ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary),
                      ),
                      const Gap(10),
                      const AppNameWidget(),
                      AppText(
                        text: context.localizations.simplify_your_expenses,
                        // 'Simplify your expenses',
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? const Color.fromARGB(255, 162, 166, 173)
                            : Colors.grey,
                      ),
                      Gap(Adaptive.h(50)),
                      AppTextButton(
                          text: context.localizations.unlock,
                          size: 15,
                          // 'Unlock',
                          callback: () async {
                            await ref
                                .read(appBackgroundCheckProvider.notifier)
                                .unlock();
                          })
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        isSecure: true,
        appSwitcherMenuColor: ((ref.watch(themeProvider) == 'System' ||
                    ref.watch(themeProvider) == 'Dark') &&
                (MediaQuery.platformBrightnessOf(context) == Brightness.dark))
            ? const Color.fromARGB(255, 32, 25, 33)
            : Colors.white.withOpacity(0.6),
        builder: (context, onInit, onDispose) {
          // if (shouldUnlock) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
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
                  showInfoToast(
                      context.localizations.create_an_account_first_toast_info,
                      // 'Please create an account first',
                      context: context);
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
                        ? "${context.localizations.hello}, ${_userBox.values.firstWhere(
                              (element) => element.uid == _appStateUid,
                            ).displayName}"
                        : bottomNavIndex == 1
                            ? navigatorKey
                                .currentContext!.localizations.statistics
                            // "Statistics"
                            : bottomNavIndex == 3
                                ? navigatorKey
                                    .currentContext!.localizations.budgets
                                //  "Budgets"
                                : bottomNavIndex == 4
                                    ? navigatorKey
                                        .currentContext!.localizations.profile
                                    // 'Profile'
                                    : "",
                    weight: FontWeight.bold,
                    color: bottomNavIndex != 4 ? null : Colors.white,
                    size: bottomNavIndex == 0
                        ? AppSizes.heading6
                        : AppSizes.bodySmall,
                  ),
                  bottomNavIndex == 0
                      ? AppText(text: context.localizations.save_for_your_goals
                          // 'Save for your goals!'
                          )
                      : const SizedBox.shrink()
                ],
              ),
              centerTitle: bottomNavIndex != 0 ? true : false,
              backgroundColor: bottomNavIndex != 4
                  ? null
                  : (ref.watch(themeProvider) == 'System' &&
                              MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark) ||
                          ref.watch(themeProvider) == 'Dark'
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
                decoration: (ref.watch(themeProvider) == 'System' &&
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark) ||
                        ref.watch(themeProvider) == 'Dark'
                    ? const BoxDecoration(
                        border: Border(
                            top: BorderSide(color: AppColors.neutral800)))
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

                      ref
                          .read(bottomNavIndexProvider.notifier)
                          .updateIndex(value);
                    }
                  },
                  backgroundColor: (ref.watch(themeProvider) == 'System' &&
                              MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark) ||
                          ref.watch(themeProvider) == 'Dark'
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
                    BottomNavigationBarItem(
                        activeIcon: const Icon(
                          Icons.home_rounded,
                          size: 27,
                          // color: AppColors.primary,
                        ),
                        icon: const Icon(
                          Icons.home_outlined,
                          size: 27,
                          // color: Colors.transparent,
                        ),
                        label: context.localizations.home
                        // 'Home',
                        ),
                    BottomNavigationBarItem(
                      activeIcon: Iconify(
                        MaterialSymbols.insert_chart_rounded,
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        size: 27,
                      ),
                      icon: const Iconify(
                        MaterialSymbols.insert_chart_outline_rounded,
                        color: AppColors.neutral500,
                        size: 27,
                      ),
                      label: context.localizations.statistics,
                      //  'Statistics',
                    ),
                    const BottomNavigationBarItem(
                      icon: Iconify(
                        Ion.wallet_outline,
                        color: Colors.transparent,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      activeIcon: const Icon(
                        Icons.account_balance_wallet,
                        // color: AppColors.primary,
                      ),
                      icon: const Icon(
                        Icons.account_balance_wallet_outlined,
                        // color: AppColors.neutral500,
                      ),
                      label: context.localizations.budgets,
                      // 'Budgets',
                    ),
                    BottomNavigationBarItem(
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
                          const Icon(
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
                          const Icon(Iconsax.user),
                      label: navigatorKey.currentContext!.localizations.user,
                      //  'User',
                    ),
                  ],
                ),
              ),
            ),
          );
          // } else {
          //   return Scaffold(
          //     appBar: AppBar(),
          //     body: Center(
          //       child: Column(
          //         children: [
          //           const AppNameWidget(),
          //           AppText(
          //             text: context.localizations.simplify_your_expenses,
          //             // 'Simplify your expenses',
          //             color: (ref.watch(themeProvider) == 'System' &&
          //                         MediaQuery.platformBrightnessOf(context) ==
          //                             Brightness.dark) ||
          //                     ref.watch(themeProvider) == 'Dark'
          //                 ? const Color.fromARGB(255, 162, 166, 173)
          //                 : Colors.grey,
          //           ),
          //           Gap(Adaptive.h(50)),
          //           AppTextButton(
          //               text: context.localizations.unlock,
          //               // 'Unlock',
          //               callback: () async {
          //                 await ref
          //                     .read(appBackgroundCheckProvider.notifier)
          //                     .unlock();
          //               })
          //         ],
          //       ),
          //     ),
          //   );
          // }
        });
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
    return SafeArea(
        child: Column(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLoader(),
                const Gap(10),
                AppText(text: context.localizations.loading
                    //  'Loading...'
                    )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
