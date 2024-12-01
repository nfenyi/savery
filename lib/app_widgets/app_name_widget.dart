part of 'widgets.dart';

class AppNameWidget extends ConsumerWidget {
  const AppNameWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppText(
      text: 'SAVERY',
      color: ((ref.watch(themeProvider) == 'System' ||
                  ref.watch(themeProvider) == 'Dark') &&
              (MediaQuery.platformBrightnessOf(context) == Brightness.dark))
          ? AppColors.primaryDark
          : AppColors.primaryDark,
      weight: FontWeight.w900,
      size: AppSizes.heading1,
    );
  }
}
