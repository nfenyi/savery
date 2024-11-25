part of 'widgets.dart';

class AppLoader extends StatelessWidget {
  final Color color;
  final double size;
  final Color secondRingColor;
  final Color thirdRingColor;

  const AppLoader({
    super.key,
    this.thirdRingColor = AppColors.neutral300,
    this.color = AppColors.primary,
    this.secondRingColor = Colors.pink,
    this.size = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LoadingAnimationWidget.discreteCircle(
        secondRingColor: secondRingColor,
        thirdRingColor: thirdRingColor,
        color: color,
        size: size,
      ),
    );
  }
}
