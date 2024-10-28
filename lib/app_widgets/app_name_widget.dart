part of 'widgets.dart';

class AppNameWidget extends StatelessWidget {
  const AppNameWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const AppText(
      text: 'SAVERY',
      color: AppColors.primary,
      weight: FontWeight.w900,
      size: AppSizes.heading1,
    );
  }
}
