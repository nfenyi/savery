part of 'widgets.dart';

class AppGradientButton extends ConsumerWidget {
  final String text;
  final double? textSize;
  final Color textColor;
  final FontWeight textWeight;
  final FontStyle textStyle;
  final TextDecoration textDecoration;
  final VoidCallback? callback;
  final Color? buttonColor;
  final Color loaderColor;
  final double loaderSize;
  final double width;
  final double height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? icon;
  final bool iconFirst;
  final double borderRadius;
  final bool isLoading;
  final BoxDecoration? decoration;
  final Alignment alignment;
  final bool isSecondary;
  const AppGradientButton({
    super.key,
    required this.text,
    this.callback,
    this.textSize,
    this.width = double.infinity,
    this.padding,
    this.margin,
    this.icon,
    this.decoration,
    this.height = 55.0,
    this.borderRadius = 10.0,
    this.iconFirst = false,
    this.isLoading = false,
    this.isSecondary = false,
    this.textColor = Colors.white,
    this.buttonColor,
    this.loaderColor = Colors.white,
    this.loaderSize = 30.0,
    this.textWeight = FontWeight.w500,
    this.textStyle = FontStyle.normal,
    this.textDecoration = TextDecoration.none,
    this.alignment = Alignment.center,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: callback,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Color.fromARGB(
              255,
              224,
              6,
              135,
            ),
            AppColors.primary,
          ]),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          padding: padding,
          width: width,
          height: height,
          alignment: Alignment.center,
          child: isLoading
              ? AppLoader(
                  color: (ref.watch(themeProvider) == 'System' &&
                              MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark) ||
                          ref.watch(themeProvider) == 'Dark'
                      ? const Color.fromARGB(255, 104, 88, 131)
                      : AppColors.primary,
                )
              : icon == null
                  ? AppText(
                      text: text,
                      size: textSize ?? AppSizes.bodySmaller,
                      color: isSecondary ? buttonColor : textColor,
                      weight: textWeight,
                      style: textStyle,
                      decoration: textDecoration,
                    )
                  : iconFirst
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              icon!,
                              const Gap(5),
                              AppText(
                                text: text,
                                size: textSize ?? AppSizes.bodySmaller,
                                color: isSecondary ? buttonColor : textColor,
                                weight: textWeight,
                                style: textStyle,
                                decoration: textDecoration,
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              text: text,
                              size: textSize ?? AppSizes.bodySmaller,
                              color: isSecondary ? buttonColor : textColor,
                              weight: textWeight,
                              style: textStyle,
                              decoration: textDecoration,
                            ),
                            const Gap(20),
                            icon!,
                          ],
                        ),
        ),
      ),
    );
  }
}
