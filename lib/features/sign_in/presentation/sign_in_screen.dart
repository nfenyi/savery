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
import 'package:savery/features/reset_password/presentation/forgot_password_screen.dart';
import 'package:savery/features/sign_in/models/auth_state.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/features/sign_up/presentation/create_account_screen.dart';
import 'package:savery/main.dart';

import '../../../themes/themes.dart';
import '../../main_screen/presentation/main_screen.dart';
import '../providers/providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

//TODO: at this moment, someone who creates a new account can access the initial user's hive data as
//user.values.first is always taken
class _SignInScreenState extends ConsumerState<SignInScreen> {
  // late final StateNotifier _authStateProvider;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  final Box _appBox = Hive.box(AppBoxes.appState);
  final Box<AppUser> _userBox = Hive.box(AppBoxes.users);
  bool _isLoading = false;

  // @override
  // void initState() {
  //   super.initState();
  //   _authStateProvider = ref.read(authStateProvider.notifier);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
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
                const Gap(20),
                AppText(
                  text: 'SIGN IN',
                  color: ((ref.watch(themeProvider) == 'System' ||
                              ref.watch(themeProvider) == 'Dark') &&
                          (MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark))
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  weight: FontWeight.bold,
                  size: AppSizes.heading6,
                ),
              ],
            ),
          ),
          const Gap(25),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RequiredText('Email'),
                const Gap(12),
                AppTextFormField(
                    controller: _emailController,
                    hintText: 'johndoe@gmail.com',
                    autovalidateMode: AutovalidateMode.disabled,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ])),
                const Gap(
                  20,
                ),
                const RequiredText('Password'),
                const Gap(12),
                AppTextFormField(
                  controller: _passwordController,
                  hintText: '* * * * * * * *',
                  obscureText: !_showPassword,
                  autovalidateMode: AutovalidateMode.disabled,
                  validator: FormBuilderValidators.compose([
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
              ],
            ),
          ),
          const Gap(10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              child: AppText(
                text: 'Forgot Password?',
                decoration: TextDecoration.underline,
                color: ((ref.watch(themeProvider) == 'System' ||
                            ref.watch(themeProvider) == 'Dark') &&
                        (MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark))
                    ? AppColors.primaryDark
                    : AppColors.primary,
              ),
              onPressed: () async {
                await navigatorKey.currentState!.push(MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ));
              },
            ),
          ),
          const Gap(30),
          AppGradientButton(
              isLoading: _isLoading,
              text: 'Sign In',
              callback: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });
                  await ref
                      .read(authStateProvider.notifier)
                      .signInWithEmailAndPassword(
                          _emailController.text, _passwordController.text, ref);
                  if (ref.read(authStateProvider).result ==
                      AuthResult.success) {
                    await _appBox.put('authenticated', true);

                    await navigatorKey.currentState!.pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()), (r) {
                      return false;
                    });
                  }
                  setState(() {
                    _isLoading = false;
                  });
                }
                //  else {
                //   if (_emailController.text.isEmpty &&
                //       _passwordController.text.isEmpty) {
                //     showInfoToast('Fi', context: context);
                //   }
                // }
              }),
          const Gap(
            40,
          ),
          Row(
            children: [
              const Expanded(child: Divider()),
              const Gap(10),
              AppText(
                text: 'Or Log In with',
                color: ((ref.watch(themeProvider) == 'System' ||
                            ref.watch(themeProvider) == 'Dark') &&
                        (MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark))
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
              //facebook button
              CircularIconButton(
                callback: () async {
                  await ref
                      .read(authStateProvider.notifier)
                      .logInWithFacebook(ref);
                  if (ref.read(authStateProvider).result ==
                      AuthResult.success) {
                    User firebaseUser = FirebaseAuth.instance.currentUser!;
                    await _appBox.put('authenticated', true);
                    final user = AppUser(
                        uid: firebaseUser.uid,
                        displayName: firebaseUser.displayName,
                        email: firebaseUser.email,
                        phoneNumber: firebaseUser.phoneNumber);
                    await _userBox.add(user);
                    await navigatorKey.currentState!.pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()), (r) {
                      return false;
                    });
                  }
                },
                icon: FontAwesomeIcons.facebookF,
                color: ((ref.watch(themeProvider) == 'System' ||
                            ref.watch(themeProvider) == 'Dark') &&
                        (MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark))
                    ? Colors.blue[300]
                    : Colors.blue[900],
              ),
              const Gap(20),
              //google button
              CircularIconButton(
                icon: FontAwesomeIcons.google,
                // color: null,
                callback: () async {
                  await ref
                      .read(authStateProvider.notifier)
                      .logInWithGoogle(ref);
                  if (ref.read(authStateProvider).result ==
                      AuthResult.success) {
                    User firebaseUser = FirebaseAuth.instance.currentUser!;
                    await _appBox.put('authenticated', true);
                    final user = AppUser(
                        uid: firebaseUser.uid,
                        displayName: firebaseUser.displayName,
                        email: firebaseUser.email,
                        phoneNumber: firebaseUser.phoneNumber);
                    await _userBox.add(user);
                    await navigatorKey.currentState!.pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()), (r) {
                      return false;
                    });
                  }
                },
              ),
              const Gap(20),
              //TODO:Implement apple account log in later
              CircularIconButton(
                callback: () {
                  showInfoToast('Coming soon.', context: context);
                },
                icon: FontAwesomeIcons.apple,
                color: ((ref.watch(themeProvider) == 'System' ||
                            ref.watch(themeProvider) == 'Dark') &&
                        (MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark))
                    ? Colors.white
                    : Colors.black,
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
                  onPressed: () async {
                    await navigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => const CreateAccountScreen(),
                    ));
                  },
                  child: AppText(
                    text: "Sign Up",
                    decoration: TextDecoration.underline,
                    color: ((ref.watch(themeProvider) == 'System' ||
                                ref.watch(themeProvider) == 'Dark') &&
                            (MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark))
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
