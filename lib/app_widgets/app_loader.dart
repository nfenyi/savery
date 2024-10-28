part of 'widgets.dart';

class AppLoader extends StatelessWidget {
  final Color color; // Define color variable
  final double size; // Define size variable
  final Color secondRingColor; // Define color variable

  const AppLoader({
    super.key,
    this.color = Colors.white, // Set default color to
    this.secondRingColor = Colors.pink,
    this.size = 30.0, // Set default size to 30
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LoadingAnimationWidget.discreteCircle(
        color: color,
        size: size,
      ),
    );
  }
}
