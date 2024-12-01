part of 'widgets.dart';

enum BorderType { outline, underline }

class AppTextFormField extends ConsumerWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final BorderType borderType;
  final Color? hintStyleColor;
  final String? helperText;
  final String? counterText;
  final String? suffixText;
  final bool readOnly;
  final bool? enabled;
  final double radius;
  final double constraintWidth;
  final double constraintHeight;
  final double fontSize;
  final FontWeight fontWeight;
  final double height;
  final double? paddingWidth;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final void Function(PointerDownEvent)? onTapOutside;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final double? letterSpacing;
  final bool filled;
  final Color fillColor;
  final TextInputAction? textInputAction;
  final Color? focusedBorderColor;
  final Color enabledBorderColor;
  final Color errorBorderColor;
  final Color? textColor;
  final TextAlign textAlign;
  final VoidCallback? prefixCallback;
  final VoidCallback? suffixCallback;
  final TextStyle? textStyle;
  final AutovalidateMode? autovalidateMode;

  const AppTextFormField(
      {super.key,
      this.controller,
      this.focusNode,
      this.hintText = '',
      this.borderType = BorderType.outline,
      this.hintStyleColor = AppColors.neutral500,
      this.helperText,
      this.counterText,
      this.suffixText,
      this.readOnly = false,
      this.enabled,
      this.paddingWidth,
      this.radius = 12.0,
      this.constraintWidth = 42.0,
      this.constraintHeight = 42.0,
      this.fontSize = AppSizes.bodySmaller,
      this.fontWeight = FontWeight.w500,
      this.height = AppSizes.bodySmall,
      this.validator,
      this.onChanged,
      this.onTap,
      this.autovalidateMode,
      this.onEditingComplete,
      this.onTapOutside,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.prefixIcon,
      this.suffixIcon,
      this.maxLength,
      this.maxLines = 1,
      this.minLines = 1,
      this.letterSpacing,
      this.textStyle,
      this.filled = false,
      this.fillColor = Colors.transparent,
      this.textInputAction = TextInputAction.done,
      this.focusedBorderColor,
      this.enabledBorderColor = AppColors.neutral500,
      this.errorBorderColor = Colors.red,
      this.prefixCallback,
      this.suffixCallback,
      this.textColor,
      this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.d(((ref.watch(themeProvider) == 'System') &&
        (MediaQuery.platformBrightnessOf(context) == Brightness.dark)));
    return TextFormField(
      textAlign: textAlign,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onTapOutside: onTapOutside,
      style: textStyle ??
          TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
            letterSpacing: letterSpacing,
          ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingWidth ?? AppSizes.bodySmallest,
          vertical: height,
        ),
        hintText: hintText,
        counterText: counterText,
        hintStyle: TextStyle(
          fontSize: AppSizes.bodySmaller,
          color: hintStyleColor,
          fontWeight: FontWeight.w500,
        ),
        helperText: helperText,
        suffixIcon: suffixIcon == null
            ? null
            : GestureDetector(
                onTap: suffixCallback,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    suffixIcon!,
                  ],
                ),
              ),
        prefixIcon: prefixIcon == null
            ? null
            : GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    prefixIcon!,
                  ],
                ),
              ),
        suffixText: suffixText,
        filled: filled,
        fillColor: fillColor,
        suffixStyle: const TextStyle(),
        suffixIconConstraints: BoxConstraints.tightFor(
          width: constraintWidth,
          height: constraintHeight,
        ),
        prefixIconConstraints: BoxConstraints.tightFor(
          width: constraintWidth,
          height: constraintHeight,
        ),
        disabledBorder: borderType == BorderType.outline
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: enabledBorderColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(radius),
                ),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: enabledBorderColor,
                ),
                // borderRadius: BorderRadius.all(
                //   Radius.circular(radius),
                // ),
              ),
        enabledBorder: borderType == BorderType.outline
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: enabledBorderColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(radius),
                ),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: enabledBorderColor,
                ),
                // borderRadius: BorderRadius.all(
                //   Radius.circular(radius),
                // ),
              ),
        focusedBorder: borderType == BorderType.outline
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  width: 1,
                  color: focusedBorderColor ??
                      (((ref.watch(themeProvider) == 'System') &&
                              (MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark))
                          ? AppColors.primaryDark
                          : AppColors.primary),
                ),
                // borderRadius: BorderRadius.all(
                //   Radius.circular(radius),
                // ),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: focusedBorderColor ??
                      (((ref.watch(themeProvider) == 'System') &&
                              (MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark))
                          ? AppColors.primaryDark
                          : AppColors.primary),
                ),
                // borderRadius: BorderRadius.all(
                //   Radius.circular(radius),
                // ),
              ),
        errorBorder: borderType == BorderType.outline
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: errorBorderColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(radius),
                ),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: errorBorderColor,
                ),
                // borderRadius: BorderRadius.all(
                //   Radius.circular(radius),
                // ),
              ),
        focusedErrorBorder: borderType == BorderType.outline
            ? OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: errorBorderColor,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(radius),
                ),
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: errorBorderColor,
                ),
                // borderRadius: BorderRadius.all(
                //   Radius.circular(radius),
                // ),
              ),
      ),
    );
  }
}
