part of 'widgets.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final Function()? callback;
  final Color? color;
  final double size;
  final bool isUnderlined;
  const AppTextButton({
    required this.text,
    required this.callback,
    this.size = AppSizes.bodySmallest,
    this.color,
    this.isUnderlined = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: callback,
      child: AppText(
        text: text,
        decoration:
            isUnderlined ? TextDecoration.underline : TextDecoration.none,
        color: color,
        size: size,
      ),
    );
  }
}
