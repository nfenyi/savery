part of 'widgets.dart';

class AppButton extends StatelessWidget {
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
  const AppButton({
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
  Widget build(BuildContext context) {
    // return InkWell(
    //   onTap: callback,
    //   // style: TextButton.styleFrom(
    //   //   // padding: padding,
    //   //   // margin: margin,
    //   //   alignment: alignment,

    //   //   backgroundColor: Colors.red,
    //   //   // foregroundColor: isSecondary ? buttonColor : Colors.white,
    //   //   shape: RoundedRectangleBorder(
    //   //     side: BorderSide(
    //   //         color: isSecondary ? AppColors.primary : Colors.transparent),
    //   //     borderRadius: BorderRadius.circular(borderRadius),

    //   //     // border:
    //   //     //     isSecondary ? Border.all(width: 1, color: buttonColor) : null,
    //   //   ),
    //   // ),
    //   child: Ink(
    //     // height: height,
    //     // width: width,
    //     padding: padding,
    //     decoration: const BoxDecoration(
    //       gradient: LinearGradient(
    //           begin: Alignment(-1, -0.5),
    //           end: Alignment(1, 0.5),
    //           colors: [
    //             Color.fromARGB(255, 41, 22, 37),
    //             Color.fromARGB(255, 4, 20, 45),
    //             Color.fromARGB(255, 4, 20, 45),
    //             Color.fromARGB(255, 4, 20, 45),
    //             Color.fromARGB(255, 33, 54, 53),
    //           ],
    //           stops: [
    //             0.0,
    //             0.2,
    //             0.5,
    //             0.8,
    //             1.0
    //           ]),
    //     ),
    //     child: Container(
    //       width: width,
    //       height: height,
    //       alignment: Alignment.center,
    //       child: isLoading
    //           ? const AppLoader()
    //           : icon == null
    //               ? AppText(
    //                   text: text,
    //                   size: textSize ?? AppSizes.bodySmaller,
    //                   color: isSecondary ? buttonColor : textColor,
    //                   weight: textWeight,
    //                   style: textStyle,
    //                   decoration: textDecoration,
    //                 )
    //               : iconFirst
    //                   ? Padding(
    //                       padding: const EdgeInsets.all(10.0),
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: [
    //                           icon!,
    //                           const Gutter(),
    //                           AppText(
    //                             text: text,
    //                             size: textSize ?? AppSizes.bodySmaller,
    //                             color: isSecondary ? buttonColor : textColor,
    //                             weight: textWeight,
    //                             style: textStyle,
    //                             decoration: textDecoration,
    //                           ),
    //                         ],
    //                       ),
    //                     )
    //                   : Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         AppText(
    //                           text: text,
    //                           size: textSize ?? AppSizes.bodySmaller,
    //                           color: isSecondary ? buttonColor : textColor,
    //                           weight: textWeight,
    //                           style: textStyle,
    //                           decoration: textDecoration,
    //                         ),
    //                         const Gutter(),
    //                         icon!,
    //                       ],
    //                     ),
    //     ),
    //   ),
    // );
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
            AppColors.primary
          ]),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          padding: padding,
          width: width,
          height: height,
          alignment: Alignment.center,
          child: isLoading
              ? const AppLoader()
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
