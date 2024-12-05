part of '../widgets.dart';

Future<dynamic> showAppInfoDialog(BuildContext context, WidgetRef ref,
    {required String title,
    String? description,
    String confirmText = 'OK',
    String? cancelText,
    bool isWarning = false,
    void Function()? confirmCallbackFunction,
    void Function()? cancelCallbackFunction,
    bool dismissible = true}) {
  return showDialog(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return CupertinoAlertDialog(
          title: AppText(
            text: title,
            size: AppSizes.bodySmall,
            // color: AppColors.neutral900,
            // weight: FontWeight.w600,
          ),
          content: description != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: AppText(
                    text: description,
                    color: AppColors.neutral900,
                    weight: FontWeight.w500,
                    height: 1.5,
                  ),
                )
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: confirmCallbackFunction ??
                  () {
                    navigatorKey.currentState!.pop();
                  },
              child: AppText(
                text: confirmText,
                color: ((ref.watch(themeProvider) == 'System' &&
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark) ||
                        ref.watch(themeProvider) == 'Dark'
                    ? AppColors.primaryDark
                    : AppColors.primary),
                // weight: FontWeight.w600,
              ),
            ),
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: cancelCallbackFunction ??
                    () {
                      navigatorKey.currentState!.pop();
                    },
                child: AppText(
                  text: cancelText,
                  color: Colors.red,
                  // weight: FontWeight.w600,
                ),
              ),
          ],
        );
      } else {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(),
          actionsPadding: const EdgeInsets.only(bottom: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          title: AppText(
            text: title,
            size: AppSizes.bodySmall,
            color: title == 'Success' ? Colors.green : null,
            // weight: FontWeight.w600,
          ),
          content: description != null
              ? AppText(
                  text: description,
                  color: AppColors.neutral900,
                  weight: FontWeight.w500,
                  height: 1.5,
                )
              : null,
          actions: <Widget>[
            TextButton(
              onPressed: confirmCallbackFunction ??
                  () {
                    navigatorKey.currentState!.pop();
                  },
              child: AppText(
                text: confirmText,
                color: isWarning
                    ? Colors.red
                    : ((ref.watch(themeProvider) == 'System' &&
                                MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark) ||
                            ref.watch(themeProvider) == 'Dark'
                        ? AppColors.primaryDark
                        : AppColors.primary),
                // weight: FontWeight.w600,
              ),
            ),
            if (cancelText != null)
              TextButton(
                onPressed: cancelCallbackFunction ??
                    () {
                      navigatorKey.currentState!.pop();
                    },
                child: AppText(
                  text: cancelText,
                  // color: Colors.red,
                  // weight: FontWeight.w600,
                ),
              ),
          ],
        );
      }
    },
  );
}
