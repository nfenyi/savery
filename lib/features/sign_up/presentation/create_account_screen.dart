import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/sign_up/presentation/terms_and_condition_webview.dart';
import 'package:savery/main.dart';

import '../../../themes/themes.dart';
import '../../main_screen/presentation/main_screen.dart';
import '../../sign_in/models/auth_state.dart';
import '../../sign_in/providers/providers.dart';
import '../../sign_in/presentation/sign_in_screen.dart';
import '../../sign_in/user_info/models/user_model.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _showPassword = false;

  bool? _isChecked = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: Column(
                  children: [
                    AppText(
                      text: 'CREATE ACCOUNT',
                      color: (ref.watch(themeProvider) == 'System' &&
                                  MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark) ||
                              ref.watch(themeProvider) == 'Dark'
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      weight: FontWeight.bold,
                      size: AppSizes.heading6,
                    ),
                    const Gap(10),
                    const AppText(
                      text:
                          'Fill your information below or register with your social account',
                      textAlign: TextAlign.center,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              const Gap(30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RequiredText('Name'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _nameController,
                      hintText: 'Anna Smith',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
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
                      keyboardType: TextInputType.emailAddress,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.email(),
                      ]),
                    ),
                    const Gap(
                      20,
                    ),
                    const RequiredText('Password'),
                    const Gap(12),
                    AppTextFormField(
                      obscureText: !_showPassword,
                      controller: _passwordController,
                      hintText: '* * * * * * * *',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.password(),
                      ]),
                      suffixIcon: SizedBox(
                        child: InkWell(
                          onTap: () => setState(() {
                            _showPassword = !_showPassword;
                          }),
                          child: Ink(
                            child: FaIcon(_showPassword
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash),
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                  ],
                ),
              ),
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
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0)),
                      child: AppText(
                        text: 'Terms and Conditions',
                        decoration: TextDecoration.underline,
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                      onPressed: () {
                        navigatorKey.currentState!.push(MaterialPageRoute(
                          builder: (context) =>
                              const TermsAndConditionWebview(),
                        ));
                      },
                    ),
                  ),
                ],
              ),
              const Gap(30),
              AppGradientButton(
                text: 'Sign Up',
                callback: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  if (_formKey.currentState!.validate()) {
                    if (_isChecked == true) {
                      await ref
                          .read(authStateProvider.notifier)
                          .createAccountWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                              name: _nameController.text,
                              ref: ref);

                      if (ref.read(authStateProvider).result ==
                          AuthResult.success) {
                        User user = FirebaseAuth.instance.currentUser!;
                        await Hive.box<AppUser>(AppBoxes.users).add(AppUser(
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
                      }
                    } else {
                      showInfoToast(
                          "Please accept our Terms and Conditions to continue",
                          context: context);
                    }
                  }
                },
              ),
              const Gap(
                40,
              ),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  const Gap(10),
                  AppText(
                    text: 'Or Log In with',
                    color: (ref.watch(themeProvider) == 'System' &&
                                MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark) ||
                            ref.watch(themeProvider) == 'Dark'
                        ? AppColors.neutral300
                        : AppColors.neutral500,
                  ),
                  const Gap(10),
                  const Expanded(child: Divider()),
                ],
              ),
              const Gap(
                30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularIconButton(
                      icon: FontAwesomeIcons.facebookF,
                      color: Colors.blue[900]),
                  const Gap(20),
                  const CircularIconButton(
                    icon: FontAwesomeIcons.google,
                    // color: null,
                  ),
                  const Gap(20),
                  CircularIconButton(
                    icon: FontAwesomeIcons.apple,
                    color: (ref.watch(themeProvider) == 'System' &&
                                MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark) ||
                            ref.watch(themeProvider) == 'Dark'
                        ? Colors.white
                        : Colors.black,
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
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0)),
                      onPressed: () async => navigatorKey.currentState!
                          .pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()),
                              (r) {
                        return false;
                      }),
                      child: AppText(
                        text: "Sign In",
                        decoration: TextDecoration.underline,
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary,
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
