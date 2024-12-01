part of 'widgets.dart';

class AppLoader extends ConsumerWidget {
  final Color? color;
  final double size;
  final Color secondRingColor;
  final Color thirdRingColor;

  const AppLoader({
    super.key,
    this.thirdRingColor = AppColors.neutral300,
    this.color,
    this.secondRingColor = Colors.pink,
    this.size = 30.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: LoadingAnimationWidget.discreteCircle(
        secondRingColor: secondRingColor,
        thirdRingColor: thirdRingColor,
        color: color ??
            (((ref.watch(themeProvider) == 'System' ||
                        ref.watch(themeProvider) == 'Dark') &&
                    (MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark))
                ? AppColors.primaryDark
                : AppColors.primary),
        size: size,
      ),
    );
  }
}
