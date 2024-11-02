import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/sign_up/presentation/verify_phone_number_screen.dart';
import 'package:savery/main.dart';

import '../../sign_in/presentation/sign_in_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool showPassword = false;

  bool? _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(
            child: Column(
              children: [
                AppText(
                  text: 'CREATE ACCOUNT',
                  color: AppColors.primary,
                  weight: FontWeight.bold,
                  size: AppSizes.heading6,
                ),
                Gap(10),
                AppText(
                  text:
                      'Fill your information below or register with your social account',
                  textAlign: TextAlign.center,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const Gap(30),
          const RequiredText('Name'),
          const Gap(12),
          AppTextFormField(
            controller: _nameController,
            hintText: 'Anna Smith',
          ),
          const Gap(
            20,
          ),
          const RequiredText('Email'),
          const Gap(
            12,
          ),
          AppTextFormField(
            controller: _emailController,
            hintText: 'annasmith@gmail.com',
          ),
          const Gap(
            20,
          ),
          const RequiredText('Password'),
          const Gap(12),
          AppTextFormField(
            controller: _passwordController,
            hintText: '* * * * * * * *',
            textColor: Colors.white,
            suffixIcon: FaIcon(showPassword
                ? FontAwesomeIcons.eye
                : FontAwesomeIcons.eyeSlash),
          ),
          const Gap(10),
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Checkbox(
                  // colo: AppColors.neutral200,
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value;
                    });
                  },
                ),
              ),
              const Gap(4),
              const AppText(text: 'Agree With'),
              SizedBox(
                // color: Colors.amber,
                width: 137,
                child: TextButton(
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                  child: const AppText(
                    text: 'Terms and Conditions',
                    decoration: TextDecoration.underline,
                    color: AppColors.primary,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const Gap(30),
          AppGradientButton(
            text: 'Sign Up',
            callback: () => navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (context) => const VerifyPhoneNumberScreen(),
            )),
          ),
          const Gap(
            40,
          ),
          const Row(
            children: [
              Expanded(child: Divider()),
              Gap(10),
              AppText(
                text: 'Or Register with',
                color: AppColors.neutral500,
              ),
              Gap(10),
              Expanded(child: Divider()),
            ],
          ),
          const Gap(
            30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularIconButton(
                  icon: FontAwesomeIcons.facebookF, color: Colors.blue[900]),
              const Gap(20),
              const CircularIconButton(
                icon: FontAwesomeIcons.google,
                // color: null,
              ),
              const Gap(20),
              const CircularIconButton(
                icon: FontAwesomeIcons.apple,
                color: Colors.black,
              ),
            ],
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppText(text: "Already have an account?"),
              const Gap(3),
              SizedBox(
                height: 20,
                width: 41,
                child: TextButton(
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                  onPressed: () =>
                      navigatorKey.currentState!.push(MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  )),
                  child: const AppText(
                    text: "Sign In",
                    decoration: TextDecoration.underline,
                    color: AppColors.primary,
                  ),
                ),
              )
            ],
          ),
        ]),
      ),
    );
  }
}
