import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:gap/gap.dart';
import 'package:pinput/pinput.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/main_screen/presentation/main_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _phoneNumberController = TextEditingController();
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
            callback: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (r) {
              return false;
            }),
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
                callback: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (r) {
                  return false;
                }),
              ),
            ]),
      ),
    );
  }
}
