import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter/icons/heroicons.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/sign_in/user_info/providers/providers.dart';
import 'package:savery/main.dart';
import 'package:savery/notifications/models/notification_model.dart';
import 'package:savery/themes/themes.dart';

import '../../app_constants/app_assets.dart';
import '../../app_constants/app_colors.dart';
import '../../app_constants/app_constants.dart';
import '../../app_constants/app_sizes.dart';
import '../../app_functions/app_functions.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final appStateUid = Hive.box(AppBoxes.appState).get('currentUser');

  @override
  void initState() {
    super.initState();

    try {
      final consumerUser = ref.read(userProvider).user(appStateUid);
      final notificationsBox =
          Hive.box<AppNotification>(AppBoxes.notifications);
      if (consumerUser.notifications == null) {
        consumerUser.notifications =
            HiveList(notificationsBox, objects: [...notificationsBox.values]);
        consumerUser.save();
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dateTimeNow = DateTime.now();

    final consumerUser = ref.watch(userProvider).user(appStateUid);
    final List<AppNotification> notifications =
        consumerUser.notifications!.reversed.toList();

    return Scaffold(
        appBar: AppBar(
          title: AppText(
            text: navigatorKey.currentContext!.localizations.notifications,
            //  'Notifications',
            weight: FontWeight.bold,
            size: AppSizes.bodySmall,
          ),
        ),
        body: Column(
          children: [
            if (notifications.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: AppTextButton(
                    text: navigatorKey.currentContext!.localizations.clear,
                    // 'Clear',
                    isUnderlined: true,
                    callback: () async {
                      await showAppInfoDialog(
                        context, ref, isWarning: true,
                        confirmCallbackFunction: () {
                          setState(() {
                            consumerUser.notifications?.clear();
                          });
                          navigatorKey.currentState!.pop();
                        },
                        title: navigatorKey.currentContext!.localizations
                            .clear_current_notifications_prompt,
                        // 'Are you sure you want to clear all current notifications?',
                        cancelText:
                            navigatorKey.currentContext!.localizations.cancel,
                        //  'Cancel',
                        confirmText:
                            navigatorKey.currentContext!.localizations.yes,
                        // 'Yes'
                      );
                    }),
              ),
            Expanded(
              child: notifications.isNotEmpty
                  ? Scrollbar(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.horizontalPaddingSmall),
                        separatorBuilder: (context, index) => Divider(
                          color: (ref.watch(themeProvider) == 'System' &&
                                      MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark) ||
                                  ref.watch(themeProvider) == 'Dark'
                              ? AppColors.neutral500
                              : AppColors.neutral300,
                        ),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            titleAlignment: ListTileTitleAlignment.titleHeight,
                            trailing: AppText(
                              text: (dateTimeNow.day ==
                                      notification.sentTime?.day)
                                  ? AppFunctions.formatDate(
                                      notification.sentTime.toString(),
                                      format: r'g:i A')
                                  : (dateTimeNow
                                              .difference(
                                                  notification.sentTime!)
                                              .inDays ==
                                          1)
                                      ? navigatorKey.currentContext!
                                          .localizations.yesterday
                                      //  'Yesterday'
                                      : (dateTimeNow
                                                  .difference(
                                                      notification.sentTime!)
                                                  .inDays >
                                              7)
                                          ? AppFunctions.formatDate(
                                              notification.sentTime.toString(),
                                              format: r'l')
                                          : AppFunctions.formatDate(
                                              notification.sentTime.toString(),
                                              format: r'j M'),
                            ),
                            leading: Iconify(Heroicons.megaphone,
                                color: (ref.watch(themeProvider) == 'System' &&
                                            MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark) ||
                                        ref.watch(themeProvider) == 'Dark'
                                    ? Colors.white
                                    : AppColors.neutral500),

                            // contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            title: AppText(
                              text: notification.title ?? '⚠️',
                              size: AppSizes.bodySmall,
                            ),
                            subtitle: AppText(
                              text: notification.body ?? '',
                              maxLines: 2,
                              color: Colors.grey,
                            ),
                            isThreeLine: true,
                          );
                        },
                        itemCount: notifications.length,
                      ),
                    )
                  : Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(AppAssets.noNotifications, width: 150),
                        const Gap(10),
                        AppText(
                          text: navigatorKey
                              .currentContext!.localizations.no_notifications,
                          // 'No notifications'
                        ),
                      ],
                    )),
            ),
          ],
        ));
  }
}
