import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/main_screen/presentation/main_screen.dart';
import 'package:savery/features/sign_up/presentation/create_account_screen.dart';

import 'otp_screen.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  const VerifyPhoneNumberScreen({super.key});

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  final _phoneNumberController = TextEditingController();
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          AppTextButton(
            callback: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainScreen(),
                ),
              );
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
                    text: 'Verify your phone number',
                    color: AppColors.primary,
                    weight: FontWeight.bold,
                    size: AppSizes.heading6,
                  ),
                  const Gap(5),
                  const AppText(
                    text:
                        'We will send you code to make sure account is secure',
                    // textAlign: TextAlign.left,
                    color: Colors.grey,
                  ),
                  const Gap(30),
                  const RequiredText('Phone number'),
                  const Gap(12),
                  AppTextFormField(
                    controller: _phoneNumberController,
                    hintText: '050 942 8913',
                  ),
                ],
              ),
              AppButton(
                text: 'Send',
                callback: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const OTPScreen(),
                )),
              ),
            ]),
      ),
    );
  }
}
