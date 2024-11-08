part of '../widgets.dart';

Future<dynamic> showAppInfoDialog(BuildContext context,
    {required String title,
    String? description,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
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
            color: AppColors.neutral900,
            weight: FontWeight.w600,
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
                color: AppColors.primary,
                weight: FontWeight.w600,
              ),
            ),
            CupertinoDialogAction(
              onPressed: cancelCallbackFunction ??
                  () {
                    navigatorKey.currentState!.pop();
                  },
              child: AppText(
                text: cancelText,
                color: Colors.red,
                weight: FontWeight.w600,
              ),
            ),
          ],
        );
      } else {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: Colors.white,
          title: AppText(
            text: title,
            size: AppSizes.bodySmall,
            color: title == 'Success' ? Colors.green : AppColors.neutral900,
            weight: FontWeight.w600,
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
                color: AppColors.primary,
                weight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: cancelCallbackFunction ??
                  () {
                    navigatorKey.currentState!.pop();
                  },
              child: AppText(
                text: cancelText,
                color: AppColors.primary,
                weight: FontWeight.w600,
              ),
            ),
          ],
        );
      }
    },
  );
}
