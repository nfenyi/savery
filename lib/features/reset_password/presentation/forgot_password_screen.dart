import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/reset_password/presentation/resend_reset_link_screen.dart';
import 'package:savery/features/sign_in/providers/providers.dart';
import 'package:savery/main.dart';

import '../../../themes/themes.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.horizontalPaddingSmall),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: navigatorKey
                          .currentContext!.localizations.forgot_password,
                      //  'Forgot Password?',
                      color: (ref.watch(themeProvider) == 'System' &&
                                  MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark) ||
                              ref.watch(themeProvider) == 'Dark'
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      weight: FontWeight.bold,
                      size: AppSizes.heading6,
                    ),
                    const Gap(5),
                    AppText(
                      text: navigatorKey.currentContext!.localizations
                          .reset_link_sending_notice,
                      // 'We will send you a reset link. Make sure the email you provide is the same as the one used to create your account.',
                      // textAlign: TextAlign.left,
                      // color: Colors.grey,
                    ),
                    const Gap(30),
                    RequiredText(
                      navigatorKey.currentContext!.localizations.email,
                      // 'Email'
                    ),
                    const Gap(12),
                    Form(
                      key: _formKey,
                      child: AppTextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'johndoe@gmail.com',
                        validator: FormBuilderValidators.compose([
                          // FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    AppGradientButton(
                      text: navigatorKey.currentContext!.localizations.send,
                      //  'Send',
                      isLoading: _isLoading,
                      callback: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          await ref
                              .read(authStateProvider.notifier)
                              .sendResetLink(_emailController.text.trim(), ref);
                          // .timeout(const Duration(seconds: 20),
                          //     onTimeout: () => 'timeout');
                          setState(() {
                            _isLoading = false;
                          });
                          await navigatorKey.currentState!
                              .push(MaterialPageRoute(
                            builder: (context) => ResendResetLinkScreen(
                                _emailController.text.trim()),
                          ));
                        }
                      },
                    ),
                    const Gap(25)
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
