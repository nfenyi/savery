import 'package:flutter/material.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/extensions/context_extenstions.dart';

class TermsAndConditionWebview extends StatefulWidget {
  const TermsAndConditionWebview({super.key});

  @override
  State<TermsAndConditionWebview> createState() =>
      _TermsAndConditionWebviewState();
}

class _TermsAndConditionWebviewState extends State<TermsAndConditionWebview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: context.localizations.terms_and_conditions,
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
      ),
      body: const Column(),
    );
  }
}
