part of 'widgets.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final Function()? callback;
  final Color? color;
  final double size;
  const AppTextButton({
    required this.text,
    required this.callback,
    this.size = AppSizes.bodySmallest,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: callback,
      child: AppText(
        text: text,
        color: color,
        size: size,
      ),
    );
  }
}
