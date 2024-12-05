part of 'widgets.dart';

class AppNameWidget extends ConsumerWidget {
  const AppNameWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppText(
      text: 'SAVERY',
      color: ((ref.watch(themeProvider) == 'System' &&
                  MediaQuery.platformBrightnessOf(context) ==
                      Brightness.dark) ||
              ref.watch(themeProvider) == 'Dark'
          ? AppColors.primaryDark
          : AppColors.primary),
      weight: FontWeight.w900,
      size: AppSizes.heading1,
    );
  }
}
