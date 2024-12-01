part of '../widgets.dart';

void showLoadingDialog(
    {required String description, required WidgetRef ref}) async {
  await showDialog(
    context: navigatorKey.currentContext!,
    barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
    builder: (BuildContext context) {
      if (Platform.isIOS) {
        return CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(10.0),
              const AppLoader(),
              const Gap(20.0),
              AppText(
                text: description,
                weight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              const Gap(10.0),
            ],
          ),
        );
      } else {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(10.0),
              const AppLoader(),
              const Gap(20.0),
              AppText(
                text: description,
                weight: FontWeight.w600,
              ),
              const Gap(10.0),
            ],
          ),
        );
      }
    },
  );
}
