import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/onboarding/onboarding_texts.dart';
import 'package:savery/features/onboarding/presentation/widgets.dart';
import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/main.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Box box = Hive.box('application');
  double? currentPage = 0.0;
  final _pageController = PageController(initialPage: 0);
  // final _indicatorController = PageController(initialPage: 0);
  // final _imagePageController = PageController(initialPage: 0);
  // final _textWidgetPageController = PageController(initialPage: 0);
  final List<OnboardingText> _onboardingTexts = [
    OnboardingText(
        headerText: "Save for your dreams!",
        bodyText:
            "Set financial goals. save money. and buy stocks. All the financial tools for your goals in one place"),
    OnboardingText(
        headerText: "Quick analysis of all",
        bodyText:
            "All expenses by cards ate reflected automatically in the application. and the analytics system helps to Control them"),
    OnboardingText(
        headerText: "Tips to optimize spendings!",
        bodyText:
            "The system notices where you're slipping on the budget and tells you how to optimize costs"),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          AppTextButton(
            text: 'Skip',
            callback: () {
              box.put('onboarded', true);
              navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
              );
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
                                decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Color.fromARGB(
                                        255,
                                        174,
                                        145,
                                        233,
                                      ),
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
                                decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Color.fromARGB(
                                        255,
                                        174,
                                        145,
                                        233,
                                      ),
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
                                decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Color.fromARGB(
                                        255,
                                        174,
                                        145,
                                        233,
                                      ),
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
                    onDotClicked: (index) {
                      _pageController.animateToPage(index,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeIn);
                    },
                    controller: _pageController,
                    effect: const SlideEffect(
                        activeDotColor: Colors.black,
                        dotHeight: 6,
                        radius: 200,
                        dotWidth: 6,
                        paintStyle: PaintingStyle.fill,
                        dotColor: Color.fromARGB(255, 93, 69, 142)),
                    count: _onboardingTexts.length),
                const Gap(30),
                AppGradientButton(
                  text: currentPage != 2 ? 'NEXT' : 'GET STARTED',
                  callback: () {
                    if (currentPage != 2) {
                      _pageController.nextPage(
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeIn);
                    } else {
                      box.put('onboarded', true);
                      navigatorKey.currentState!
                          .pushReplacement(MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ));
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


// 