import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/sign_in/providers/providers.dart';
import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/main.dart';

class ResendResetLinkScreen extends ConsumerStatefulWidget {
  final String email;
  const ResendResetLinkScreen(this.email, {super.key});

  @override
  ConsumerState<ResendResetLinkScreen> createState() =>
      _ResendResetLinkScreenState();
}

class _ResendResetLinkScreenState extends ConsumerState<ResendResetLinkScreen> {
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
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // const AppText(
                  //   text: 'Enter your email',
                  //   color: AppColors.primary,
                  //   weight: FontWeight.bold,
                  //   size: AppSizes.heading6,
                  // ),
                  // const Gap(5),
                  AppText(
                    text: navigatorKey
                        .currentContext!.localizations.reset_link_sent_message,
                    // 'A reset email has been sent to you. Please click on the link in the mail to reset your password.',
                    // textAlign: TextAlign.left,
                    color: Colors.grey,
                  ),
                  // const Gap(30),
                ]),
                Column(
                  children: [
                    AppGradientButton(
                      text: navigatorKey
                          .currentContext!.localizations.resend_reset_link,
                      //  'Resend Reset Link',
                      callback: () async {
                        await ref
                            .read(authStateProvider.notifier)
                            .sendResetLink(widget.email, ref);
                      },
                    ),
                    AppTextButton(
                        text: navigatorKey.currentContext!.localizations.log_in,
                        // 'Log In',
                        callback: () async {
                          await navigatorKey.currentState!.pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()),
                              (r) {
                            return false;
                          });
                        }),
                    AppText(
                      text: navigatorKey.currentContext!.localizations
                          .dont_receive_mail_notice,
                      // 'If you still do not receive the mail, please go back and check the email address you provided.',
                      textAlign: TextAlign.center,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}
