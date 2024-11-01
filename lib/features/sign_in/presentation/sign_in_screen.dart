import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/sign_in/backend/authentcator.dart';
import 'package:savery/features/sign_up/presentation/create_account_screen.dart';

import '../../main_screen/presentation/main_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final authenticator = const Authenticator();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool showPassword = false;

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
                AppNameWidget(),
                AppText(
                  text: 'Simplify your expenses',
                  color: Colors.grey,
                ),
                Gap(20),
                AppText(
                  text: 'SIGN IN',
                  color: AppColors.primary,
                  weight: FontWeight.bold,
                  size: AppSizes.heading6,
                ),
              ],
            ),
          ),
          const Gap(25),
          const RequiredText('Name'),
          const Gap(12),
          AppTextFormField(
            controller: _nameController,
            hintText: 'Anna Smith',
          ),
          const Gap(
            20,
          ),
          const RequiredText('Password'),
          const Gap(12),
          AppTextFormField(
            controller: _passwordController,
            hintText: '* * * * * * * *',
            obscureText: true,
            textColor: Colors.white,
            suffixIcon: FaIcon(showPassword
                ? FontAwesomeIcons.eye
                : FontAwesomeIcons.eyeSlash),
          ),
          const Gap(10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: const AppText(
                text: 'Forgot Password?',
                decoration: TextDecoration.underline,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
          ),
          const Gap(30),
          AppGradientButton(
            text: 'Sign In',
            callback: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (r) {
              return false;
            }),
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
                callback: () async {
                  await authenticator.logInWithFacebook(context);
                },
                icon: FontAwesomeIcons.facebookF,
                color: Colors.blue[900],
              ),
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
              const AppText(text: "Don't have an account?"),
              SizedBox(
                height: 20,
                width: 47,
                child: TextButton(
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CreateAccountScreen(),
                  )),
                  child: const AppText(
                    text: "Sign Up",
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
