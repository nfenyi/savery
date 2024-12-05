part of 'widgets.dart';

class AppButton extends ConsumerWidget {
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
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? icon;
  final bool iconFirst;
  final double borderRadius;
  final bool isLoading;
  final BoxDecoration? decoration;
  final Alignment alignment;
  final bool isSecondary;
  const AppButton({
    super.key,
    required this.text,
    this.callback,
    this.textSize,
    this.width,
    this.padding,
    this.margin,
    this.icon,
    this.decoration,
    this.height = 45.0,
    this.borderRadius = 8.0,
    this.iconFirst = false,
    this.isLoading = false,
    this.isSecondary = false,
    this.textColor = Colors.white,
    // this.buttonColor = AppColors.primary,
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
    return InkWell(
      onTap: callback,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        margin: margin,
        alignment: alignment,
        decoration: decoration ??
            BoxDecoration(
                color: isSecondary
                    ? Colors.transparent
                    : buttonColor ??
                        ((ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary),
                borderRadius: BorderRadius.circular(borderRadius),
                border: isSecondary
                    ? Border.all(
                        width: 1,
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary)
                    : null),
        child: isLoading
            ? const AppLoader()
            : icon == null
                ? AppText(
                    text: text,
                    size: textSize ?? AppSizes.bodySmaller,
                    color: isSecondary
                        ? buttonColor ??
                            ((ref.watch(themeProvider) == 'System' &&
                                        MediaQuery.platformBrightnessOf(
                                                context) ==
                                            Brightness.dark) ||
                                    ref.watch(themeProvider) == 'Dark'
                                ? AppColors.primaryDark
                                : AppColors.primary)
                        : textColor,
                    weight: textWeight,
                    style: textStyle,
                    decoration: textDecoration,
                  )
                : iconFirst
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon!,
                          const Gap(1.0),
                          AppText(
                            text: text,
                            size: textSize ?? AppSizes.bodySmaller,
                            color: isSecondary
                                ? buttonColor ??
                                    ((ref.watch(themeProvider) == 'System' &&
                                                MediaQuery.platformBrightnessOf(
                                                        context) ==
                                                    Brightness.dark) ||
                                            ref.watch(themeProvider) == 'Dark'
                                        ? AppColors.primaryDark
                                        : AppColors.primary)
                                : textColor,
                            weight: textWeight,
                            style: textStyle,
                            decoration: textDecoration,
                          ),
                        ],
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
                          const Gap(8.0),
                          icon!,
                        ],
                      ),
      ),
    );
  }
}
