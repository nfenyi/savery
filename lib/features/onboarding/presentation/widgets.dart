import 'package:flutter/material.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';

class PageViewTextWidget extends StatelessWidget {
  final String headerText;
  final String bodyText;
  const PageViewTextWidget(
      {super.key, required this.headerText, required this.bodyText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: headerText,
          size: AppSizes.heading3,
          weight: FontWeight.bold,
        ),
        AppText(
          text: bodyText,
          size: AppSizes.bodySmall,
          color: AppColors.neutral300,
        ),
      ],
    );
  }
}
