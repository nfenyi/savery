import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/accounts_&_currencies/presentation/accounts_n_currencies_screen.dart';
import 'package:savery/features/accounts_&_currencies/services/api_services.dart';
import 'package:savery/features/app_settings/presentation/app_settings_screen.dart';
import 'package:savery/features/categories/presentation/categories_screen.dart';
import 'package:savery/features/main_screen/models/settings.dart';
import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/features/sign_in/providers/providers.dart';
// import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';
import 'package:savery/themes/themes.dart';

import '../../../app_constants/app_assets.dart';
import '../../../app_constants/app_colors.dart';
import '../../../notifications/models/notification_model.dart';
import '../../../notifications/presentation/notifications_screen.dart';
import '../../sign_in/local_auth_api/local_auth_api.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final _userBox = Hive.box<AppUser>(AppBoxes.users);
  late final AppUser _user;
  late List<Setting> _personalSettings;
  final _appStateUid = Hive.box(AppBoxes.appState).get('currentUser');
  late final bool _isMainUser;

  @override
  void initState() {
    super.initState();
    _isMainUser = _userBox.values.first.uid ==
        Hive.box(AppBoxes.appState).get('currentUser');
    _user = _userBox.values.firstWhere(
      (element) => element.uid == _appStateUid,
    );
  }

  @override
  Widget build(BuildContext context) {
    _personalSettings = [
      Setting(
          icon: Iconsax.notification,
          name: context.localizations.notifications,
          //  "Notifications",
          callback: () async {
            await FirebaseMessaging.instance
                .getInitialMessage()
                .then(handleMessageAndNavigate);
            //navigation is being handled in handleMessageAndNavigate function
            // return navigatorKey.currentState!.push(MaterialPageRoute(
            //     builder: (context) => const NotificationsScreen()));
          }),
      Setting(
          icon: Icons.settings_outlined,
          name: context.localizations.app_settings,
          //  "App Settings",
          callback: () async {
            if (_isMainUser) {
              final bool hasBiometrics = await LocalAuthApi.hasBiometrics();
              navigatorKey.currentState!.push(MaterialPageRoute(
                  builder: (context) => AppSettings(
                        enableBiometrics: hasBiometrics,
                      )));
            } else {
              navigatorKey.currentState!.push(MaterialPageRoute(
                  builder: (context) => const AppSettings(
                        enableBiometrics: false,
                      )));
            }
          }),
      Setting(
          icon: Iconsax.grid_2,
          name: context.localizations.categories,
          //  "Categories",
          callback: () {
            navigatorKey.currentState!.push(MaterialPageRoute(
                builder: (context) => const CategoriesScreen()));
          }),
      Setting(
          icon: FontAwesomeIcons.chartLine,
          name: context.localizations.accounts_n_currencies,
          //  "Accounts & Currencies",
          callback: () async {
            showLoadingDialog(
                description: context.localizations.fetching_exchange_rates,
                // 'Fetching exchange rates...',
                ref: ref);
            final response = await ApiServices().fetchExchangeRates();
            navigatorKey.currentState!.pop();
            navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (context) => CurrencyScreen(
                currencyResponse: response,
              ),
            ));
          }),
      //TODO: commented out for now
      // Setting(
      //   icon: Iconsax.message,
      //   name: "Support",
      // ),
    ];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Adaptive.h(18),
            width: double.infinity,
            decoration: BoxDecoration(
                color: (ref.watch(themeProvider) == 'System' &&
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark) ||
                        ref.watch(themeProvider) == 'Dark'
                    ? AppColors.primaryDark
                    : AppColors.primary,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15))),
            child: Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Container(
                          color: Colors.white,
                          height: 111,
                          width: 111,
                        ),
                      ),
                      CircleAvatar(
                        maxRadius: 54,
                        minRadius: 54,
                        backgroundImage: const AssetImage(
                          AppAssets.noProfile,
                        ),
                        foregroundImage: _user.photoUrl != null
                            ? NetworkImage(_user.photoUrl!)
                            : null,
                      ),
                    ],
                  ),
                  const Gap(10),
                  AppText(
                    text: _user.displayName!,
                    color: Colors.white,
                    size: AppSizes.bodySmall,
                  ),
                  Visibility(
                    visible: !_isMainUser,
                    child: Column(
                      children: [
                        const Gap(4),
                        AppText(
                          text: context.localizations.piggy_back_user,
                          // '(piggy-back user)',
                          style: FontStyle.italic,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const Gap(20),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.horizontalPaddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: context.localizations.personal_settings,
                  // 'Personal Settings',
                  size: AppSizes.bodySmall,
                  weight: FontWeight.bold,
                ),
                const Gap(20),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _personalSettings.length,
                  itemBuilder: (context, index) {
                    final setting = _personalSettings[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      onTap: setting.callback,
                      dense: true,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          color: Colors.grey[200],
                          child: Icon(
                            setting.icon,
                          ),
                        ),
                      ),
                      title: AppText(
                        text: setting.name,
                        weight: FontWeight.w900,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.neutral300,
                        size: 20,
                      ),
                    );
                  },
                ),
                ListTile(
                  onTap: () async {
                    showLoadingDialog(
                        description: context.localizations.logging_you_out,
                        //  'Logging you out...',
                        ref: ref);
                    await ref.read(authStateProvider.notifier).logOut();
                    navigatorKey.currentState!.pop();
                    //TODO; try to make valuelistenable in main.dart listen to the 'authenticated' value in appstate box
                    //then, omit navigating to the sign in screen manually
                    // if (ref.read(authStateProvider).userId == null) {
                    //   await navigatorKey.currentState!.pushAndRemoveUntil(
                    //       MaterialPageRoute(
                    //           builder: (context) => const SignInScreen()), (r) {
                    //     return false;
                    //   });
                    // }
                    if (Hive.box(AppBoxes.appState).get('authenticated') ==
                        false) {
                      await navigatorKey.currentState!.pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()), (r) {
                        return false;
                      });
                    } else {
                      showInfoToast('Error when logging out.',
                          context: navigatorKey.currentContext!);
                    }
                  },
                  contentPadding: const EdgeInsets.all(0),
                  dense: true,
                  leading: const Icon(
                    Iconsax.logout,
                    color: Colors.red,
                  ),
                  title: AppText(
                    text: context.localizations.log_out,
                    // 'Log Out',
                    weight: FontWeight.w900,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handleMessageAndNavigate(RemoteMessage? message) async {
    if (message == null) {
      navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ));
      return;
    }
    final appStateUid = Hive.box(AppBoxes.appState).get('currentUser');
    final notificationsBox = Hive.box<AppNotification>(AppBoxes.notifications);
    final newNotification = AppNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        sentTime: message.sentTime,
        data: message.data);

    AppUser user = Hive.box<AppUser>(AppBoxes.users).values.toList().firstWhere(
          (element) => element.uid == appStateUid,
        );
    await notificationsBox.add(newNotification);

    HiveList<AppNotification>? userNotifications = user.notifications;
    userNotifications ??= HiveList(notificationsBox);
    userNotifications.add(newNotification);
    final boxNotifications = notificationsBox.values.toList();
    boxNotifications.removeLast();
    await notificationsBox.clear();
    await notificationsBox.addAll(boxNotifications);
    await user.save();

    navigatorKey.currentState!.push(MaterialPageRoute(
      builder: (context) => const NotificationsScreen(),
    ));
  }
}
