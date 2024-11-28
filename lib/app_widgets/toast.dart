part of 'widgets.dart';

void showInfoToast(String message,
    {int seconds = 3, required context, Color color = AppColors.neutral900}) {
  FToast fToast = FToast();
  fToast.init(context);
  Widget toast = IntrinsicWidth(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(
            FontAwesomeIcons.circleExclamation,
            color: Colors.white,
            size: 13.0,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AppText(
              text: message,
              size: 13.0,
              color: Colors.white,
              weight: FontWeight.w500,
              softWrap: true,
            ),
          ),
        ],
      ),
    ),
  );
  fToast.showToast(
    child: toast,
    toastDuration: Duration(seconds: seconds),
    gravity: ToastGravity.TOP,
  );
}
