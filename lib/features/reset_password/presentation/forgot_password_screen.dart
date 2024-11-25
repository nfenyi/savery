import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/reset_password/presentation/resend_reset_link_screen.dart';
import 'package:savery/features/sign_in/providers/providers.dart';
import 'package:savery/main.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Expanded(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      text: 'Forgot Password?',
                      color: AppColors.primary,
                      weight: FontWeight.bold,
                      size: AppSizes.heading6,
                    ),
                    const Gap(5),
                    const AppText(
                      text:
                          'We will send you a reset link. Make sure the email you provide is the same as the one used to create your account.',
                      // textAlign: TextAlign.left,
                      color: Colors.grey,
                    ),
                    const Gap(30),
                    const RequiredText('Email'),
                    const Gap(12),
                    Form(
                      key: _formKey,
                      child: AppTextFormField(
                        controller: _emailController,
                        hintText: 'johndoe@gmail.com',
                        validator: FormBuilderValidators.compose([
                          // FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                    ),
                  ],
                ),
                AppGradientButton(
                  text: 'Send',
                  callback: () async {
                    if (_formKey.currentState!.validate()) {
                      await ref.read(authStateProvider.notifier).sendResetLink(
                            _emailController.text.trim(),
                          );
                      await navigatorKey.currentState!.push(MaterialPageRoute(
                        builder: (context) =>
                            ResendResetLinkScreen(_emailController.text.trim()),
                      ));
                    }
                  },
                ),
              ]),
        ),
      ),
    );
  }
}
