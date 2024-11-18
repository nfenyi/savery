import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/main_screen/presentation/main_screen.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_constants.dart';
import '../../sign_in/user_info/models/user_model.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool showPassword = false;

  final _defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(
        color: AppColors.neutral300,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  late final _focusedPinTheme = _defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary));

  bool _hasTimedOut = false;

  @override
  void dispose() {
    super.dispose();
    _pinController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          AppTextButton(
            callback: () async {
              User user = FirebaseAuth.instance.currentUser!;

              await Hive.box<AppUser>(AppBoxes.user).add(AppUser(
                  uid: user.uid,
                  displayName: user.displayName,
                  email: user.email,
                  photoUrl: user.photoURL,
                  phoneNumber: user.phoneNumber));

              return navigatorKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (r) {
                return false;
              });
            },
            text: 'Skip',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'ENTER CODE',
                    color: AppColors.primary,
                    weight: FontWeight.bold,
                    size: AppSizes.heading6,
                  ),
                  const Gap(5),
                  const AppText(
                    text:
                        "We've sent an SMS with an activation code to phone +374 99123 123",
                    // textAlign: TextAlign.left,
                    color: Colors.grey,
                  ),
                  const Gap(60),
                  Pinput(
                    length: 6,
                    defaultPinTheme: _defaultPinTheme,
                    focusedPinTheme: _focusedPinTheme,
                    submittedPinTheme: _defaultPinTheme,
                    controller: _pinController,
                    onCompleted: (value) {},
                  ),
                  const Gap(60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTextButton(
                        text: 'Send code again',
                        callback: _hasTimedOut ? () {} : null,
                        color: _hasTimedOut
                            ? AppColors.primary
                            : AppColors.neutral300,
                      ),
                      TimerCountdown(
                        spacerWidth: 0,
                        enableDescriptions: false,
                        format: CountDownTimerFormat.minutesSeconds,
                        endTime: DateTime.now().add(
                          const Duration(
                            minutes: 2,
                          ),
                        ),
                        onEnd: () {
                          setState(() {
                            _hasTimedOut = true;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              AppGradientButton(
                text: 'Verify',
                callback: () async {
                  User user = FirebaseAuth.instance.currentUser!;

                  //because phone number has been added to firebase user account
                  await Hive.box<AppUser>(AppBoxes.user).add(AppUser(
                      uid: user.uid,
                      displayName: user.displayName,
                      email: user.email,
                      photoUrl: user.photoURL,
                      phoneNumber: user.phoneNumber));
                  await navigatorKey.currentState!.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()), (r) {
                    return false;
                  });
                },
              ),
            ]),
      ),
    );
  }
}
