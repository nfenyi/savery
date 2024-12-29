import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter/icons/mdi_light.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter_plus/icons/ic.dart';
import 'package:iconify_flutter_plus/icons/la.dart';
import 'package:iconify_flutter_plus/icons/material_symbols.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/features/onboarding/onboarding_texts.dart';
import 'package:savery/features/onboarding/presentation/widgets.dart';
import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/main.dart';
import 'package:savery/themes/themes.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Box _appStateBox = Hive.box(AppBoxes.appState);
  final _transactionCategoriesBox =
      Hive.box<TransactionCategory>(AppBoxes.transactionsCategories);
  double? currentPage = 0.0;
  final _pageController = PageController(initialPage: 0);
  // final _indicatorController = PageController(initialPage: 0);
  // final _imagePageController = PageController(initialPage: 0);
  // final _textWidgetPageController = PageController(initialPage: 0);
  final List<OnboardingText> _onboardingTexts = [
    OnboardingText(
        headerText:
            navigatorKey.currentContext!.localizations.save_for_your_goals,
        //  "Save for your dreams!",
        bodyText: navigatorKey.currentContext!.localizations.onboarding_body1
        // "Set financial goals. save money. and buy stocks. All the financial tools for your goals in one place"
        ),
    OnboardingText(
        headerText:
            navigatorKey.currentContext!.localizations.onboarding_header2,
        //  "Quick analysis of all",
        bodyText: navigatorKey.currentContext!.localizations.onboarding_body2
        // "All expenses by cards ate reflected automatically in the application. and the analytics system helps to Control them"
        ),
    OnboardingText(
        headerText:
            navigatorKey.currentContext!.localizations.onboarding_header3,
        //  "Tips to optimize spendings!",
        bodyText: navigatorKey.currentContext!.localizations.onboarding_body3
        // "The system notices where you're slipping on the budget and tells you how to optimize costs"
        ),
  ];

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    // _indicatorController.dispose();
    // _imagePageController.dispose();
    // _textWidgetPageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          AppTextButton(
            text: 'Skip',
            size: AppSizes.bodySmall,
            callback: () async {
              if (_appStateBox.get('firebaseServiceNotAvailable') ?? false) {
                await showAppInfoDialog(
                  navigatorKey.currentContext!,
                  dismissible: false,
                  ref,
                  title:
                      'Please ensure you are connected to the internet on your first launch of Savery to complete setup',
                  confirmCallbackFunction: () async {
                    await _appStateBox.delete('firebaseServiceNotAvailable');
                    // await SystemNavigator.pop(animated: true);
                    exit(0);
                  },
                );
              } else {
                await _appStateBox.putAll({
                  'onboarded': true,
                  'ratesAccessKey': 'M2KtcVAx901sgSFPG0Kq0SKDO7Wp37ZQ'
                });
                await _transactionCategoriesBox.addAll([
                  TransactionCategory(
                      icon: Ph.gift,
                      name: navigatorKey.currentContext!.localizations.gifts
                      //  'Gifts'
                      ),
                  TransactionCategory(
                      icon: La.stethoscope,
                      name: navigatorKey.currentContext!.localizations.health
                      // 'Health'
                      ),
                  TransactionCategory(
                      icon: MaterialSymbols.directions_car_outline_rounded,
                      name: navigatorKey.currentContext!.localizations.car
                      //  'Car'
                      ),
                  TransactionCategory(
                      icon: La.chess_knight,
                      name: navigatorKey.currentContext!.localizations.gaming
                      // 'Game',
                      ),
                  TransactionCategory(
                    icon: Ph.coffee_light,
                    name: navigatorKey.currentContext!.localizations.cafe,
                    // 'Cafe'
                  ),
                  TransactionCategory(
                      icon: La.plane,
                      name: navigatorKey.currentContext!.localizations.travel
                      // 'Travel'
                      ),
                  TransactionCategory(
                    icon: Ph.lightbulb_filament_light,
                    name: navigatorKey.currentContext!.localizations.utility,
                    // 'Utility'
                  ),
                  TransactionCategory(
                      icon: Ic.round_face_2,
                      name: navigatorKey.currentContext!.localizations.care
                      // 'Care'
                      ),
                  TransactionCategory(
                      icon: Ic.outline_tv,
                      name: navigatorKey.currentContext!.localizations.devices
                      //  'Devices'
                      ),
                  TransactionCategory(
                      icon: Ph.fork_knife_fill,
                      name: navigatorKey.currentContext!.localizations.food
                      // 'Food'
                      ),
                  TransactionCategory(
                    icon: Ph.shopping_cart_thin,
                    name: navigatorKey.currentContext!.localizations.shopping,
                    // 'Shopping'
                  ),
                  TransactionCategory(
                      icon: MdiLight.truck,
                      name: navigatorKey.currentContext!.localizations.transport
                      //  'Transport'
                      ),
                ]);
                await navigatorKey.currentState!.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(
                  height: Adaptive.h(70),
                  width: double.infinity,
                  child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentPage = index.toDouble();
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark) ||
                                          ref.watch(themeProvider) == 'Dark'
                                      ? const RadialGradient(colors: [
                                          Color.fromARGB(255, 90, 85, 97),
                                          // ((ref.watch(themeProvider) == 'System') &&
                                          //         (MediaQuery.platformBrightnessOf(
                                          //                 context) ==
                                          //             Brightness.dark))
                                          //     ? const Color.fromARGB(
                                          //         255, 32, 25, 33)
                                          // :
                                          Color.fromARGB(255, 32, 25, 33)
                                        ])
                                      : const RadialGradient(
                                          colors: [
                                            Color.fromARGB(
                                              255,
                                              174,
                                              145,
                                              233,
                                            ),
                                            // ((ref.watch(themeProvider) == 'System') &&
                                            //         (MediaQuery.platformBrightnessOf(
                                            //                 context) ==
                                            //             Brightness.dark))
                                            //     ? const Color.fromARGB(
                                            //         255, 32, 25, 33)
                                            // :
                                            Colors.white
                                          ],
                                        ),
                                ),
                                child: Image.asset(
                                  AppAssets.onboarding1,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              const Divider(
                                height: 15,
                              ),
                              const Gap(20),
                              SizedBox(
                                height: Adaptive.h(20),
                                width: double.infinity,
                                child: PageViewTextWidget(
                                    headerText: _onboardingTexts[0].headerText,
                                    bodyText: _onboardingTexts[0].bodyText),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark) ||
                                          ref.watch(themeProvider) == 'Dark'
                                      ? const RadialGradient(colors: [
                                          Color.fromARGB(255, 90, 85, 97),
                                          // ((ref.watch(themeProvider) == 'System') &&
                                          //         (MediaQuery.platformBrightnessOf(
                                          //                 context) ==
                                          //             Brightness.dark))
                                          //     ? const Color.fromARGB(
                                          //         255, 32, 25, 33)
                                          // :
                                          Color.fromARGB(255, 32, 25, 33)
                                        ])
                                      : const RadialGradient(
                                          colors: [
                                            Color.fromARGB(
                                              255,
                                              174,
                                              145,
                                              233,
                                            ),
                                            // ((ref.watch(themeProvider) == 'System') &&
                                            //         (MediaQuery.platformBrightnessOf(
                                            //                 context) ==
                                            //             Brightness.dark))
                                            //     ? const Color.fromARGB(
                                            //         255, 32, 25, 33)
                                            // :
                                            Colors.white
                                          ],
                                        ),
                                ),
                                child: Image.asset(
                                  AppAssets.onboarding2,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              const Divider(
                                height: 15,
                              ),
                              const Gap(20),
                              SizedBox(
                                height: Adaptive.h(20),
                                width: double.infinity,
                                child: PageViewTextWidget(
                                    headerText: _onboardingTexts[1].headerText,
                                    bodyText: _onboardingTexts[1].bodyText),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark) ||
                                          ref.watch(themeProvider) == 'Dark'
                                      ? const RadialGradient(colors: [
                                          Color.fromARGB(255, 90, 85, 97),
                                          // ((ref.watch(themeProvider) == 'System') &&
                                          //         (MediaQuery.platformBrightnessOf(
                                          //                 context) ==
                                          //             Brightness.dark))
                                          //     ? const Color.fromARGB(
                                          //         255, 32, 25, 33)
                                          // :
                                          Color.fromARGB(255, 32, 25, 33)
                                        ])
                                      : const RadialGradient(
                                          colors: [
                                            Color.fromARGB(
                                              255,
                                              174,
                                              145,
                                              233,
                                            ),
                                            // ((ref.watch(themeProvider) == 'System') &&
                                            //         (MediaQuery.platformBrightnessOf(
                                            //                 context) ==
                                            //             Brightness.dark))
                                            //     ? const Color.fromARGB(
                                            //         255, 32, 25, 33)
                                            // :
                                            Colors.white
                                          ],
                                        ),
                                ),
                                child: Image.asset(
                                  AppAssets.onboarding3,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              const Divider(
                                height: 15,
                              ),
                              const Gap(20),
                              SizedBox(
                                height: Adaptive.h(20),
                                width: double.infinity,
                                child: PageViewTextWidget(
                                    headerText: _onboardingTexts[2].headerText,
                                    bodyText: _onboardingTexts[2].bodyText),
                              ),
                            ],
                          ),
                        ),
                      ]),
                ),
              ],
            ),
            Column(
              children: [
                SmoothPageIndicator(
                    onDotClicked: (index) async {
                      await _pageController.animateToPage(index,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeIn);
                    },
                    controller: _pageController,
                    effect: SlideEffect(
                        activeDotColor: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? Colors.white
                            : Colors.black,
                        dotHeight: 6,
                        radius: 200,
                        dotWidth: 6,
                        paintStyle: PaintingStyle.fill,
                        dotColor: const Color.fromARGB(255, 93, 69, 142)),
                    count: _onboardingTexts.length),
                const Gap(30),
                AppGradientButton(
                  text: currentPage != 2
                      ? navigatorKey.currentContext!.localizations.next_caps
                      // 'NEXT'
                      : navigatorKey
                          .currentContext!.localizations.get_started_caps,
                  // 'GET STARTED',
                  callback: () async {
                    if (_appStateBox.get('firebaseServiceNotAvailable') ??
                        false) {
                      await showAppInfoDialog(
                        navigatorKey.currentContext!,
                        ref,
                        dismissible: false,
                        title:
                            'Please ensure you are connected to the internet on your first launch of Savery to complete setup',
                        confirmCallbackFunction: () async {
                          await _appStateBox
                              .delete('firebaseServiceNotAvailable');
                          // await SystemNavigator.pop(animated: true);
                          exit(0);
                        },
                      );
                    } else {
                      if (currentPage != 2) {
                        await _pageController.nextPage(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeIn);
                      } else {
                        await _appStateBox.putAll({
                          'onboarded': true,
                          'ratesAccessKey': 'M2KtcVAx901sgSFPG0Kq0SKDO7Wp37ZQ'
                        });
                        await _transactionCategoriesBox.addAll([
                          TransactionCategory(
                              icon: Ph.gift,
                              name: navigatorKey
                                  .currentContext!.localizations.gifts
                              //  'Gifts'
                              ),
                          TransactionCategory(
                              icon: La.stethoscope,
                              name: navigatorKey
                                  .currentContext!.localizations.health
                              // 'Health'
                              ),
                          TransactionCategory(
                              icon: MaterialSymbols
                                  .directions_car_outline_rounded,
                              name:
                                  navigatorKey.currentContext!.localizations.car
                              //  'Car'
                              ),
                          TransactionCategory(
                            icon: La.chess_knight,
                            name: navigatorKey
                                .currentContext!.localizations.gaming,
                            // 'Game',
                          ),
                          TransactionCategory(
                            icon: Ph.coffee_light,
                            name:
                                navigatorKey.currentContext!.localizations.cafe,
                            // 'Cafe'
                          ),
                          TransactionCategory(
                              icon: La.plane,
                              name: navigatorKey
                                  .currentContext!.localizations.travel
                              // 'Travel'
                              ),
                          TransactionCategory(
                            icon: Ph.lightbulb_filament_light,
                            name: navigatorKey
                                .currentContext!.localizations.utility,
                            // 'Utility'
                          ),
                          TransactionCategory(
                              icon: Ic.round_face_2,
                              name: navigatorKey
                                  .currentContext!.localizations.care
                              // 'Care'
                              ),
                          TransactionCategory(
                              icon: Ic.outline_tv,
                              name: navigatorKey
                                  .currentContext!.localizations.devices
                              //  'Devices'
                              ),
                          TransactionCategory(
                              icon: Ph.fork_knife_fill,
                              name: navigatorKey
                                  .currentContext!.localizations.food
                              // 'Food'
                              ),
                          TransactionCategory(
                            icon: Ph.shopping_cart_thin,
                            name: navigatorKey
                                .currentContext!.localizations.shopping,
                            // 'Shopping'
                          ),
                          TransactionCategory(
                              icon: MdiLight.truck,
                              name: navigatorKey
                                  .currentContext!.localizations.transport
                              //  'Transport'
                              ),
                        ]);
                        await navigatorKey.currentState!
                            .pushReplacement(MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ));
                      }
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
