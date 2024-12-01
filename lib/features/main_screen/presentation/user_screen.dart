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
import 'package:savery/features/accounts_&_currencies/presentation/accounts_n_currencies_screen.dart';
import 'package:savery/features/accounts_&_currencies/services/api_services.dart';
import 'package:savery/features/app_settings/presentation/app_settings_screen.dart';
import 'package:savery/features/categories/presentation/categories_screen.dart';
import 'package:savery/features/main_screen/models/settings.dart';
import 'package:savery/features/sign_in/providers/providers.dart';
import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';
import 'package:savery/themes/themes.dart';

import '../../../app_constants/app_assets.dart';
import '../../../app_constants/app_colors.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final _userBox = Hive.box<AppUser>(AppBoxes.user);
  late final List<Setting> _personalSettings;

  @override
  void initState() {
    super.initState();
    _personalSettings = [
      Setting(
        icon: Iconsax.notification,
        name: "Notifications",
      ),
      Setting(
          icon: Icons.settings_outlined,
          name: "Settings",
          callback: () {
            navigatorKey.currentState!.push(
                MaterialPageRoute(builder: (context) => const AppSettings()));
          }),
      Setting(
          icon: Iconsax.grid_2,
          name: "Categories",
          callback: () {
            navigatorKey.currentState!.push(MaterialPageRoute(
                builder: (context) => const CategoriesScreen()));
          }),
      Setting(
          icon: FontAwesomeIcons.chartLine,
          name: "Accounts & Currencies",
          callback: () async {
            showLoadingDialog(
                description: 'Fetching exchange rates...', ref: ref);
            final response = await ApiServices().fetchExchangeRates();
            navigatorKey.currentState!.pop();
            navigatorKey.currentState!.push(MaterialPageRoute(
              builder: (context) => CurrencyScreen(
                currencyResponse: response,
              ),
            ));
          }),
      Setting(
        icon: Iconsax.message,
        name: "Support",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Adaptive.h(18),
            width: double.infinity,
            decoration: BoxDecoration(
                color: ((ref.watch(themeProvider) == 'System' ||
                            ref.watch(themeProvider) == 'Dark') &&
                        (MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark))
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
                          height: 120,
                          width: 120,
                        ),
                      ),
                      CircleAvatar(
                        maxRadius: 58,
                        minRadius: 58,
                        backgroundImage: const AssetImage(
                          AppAssets.noProfile,
                        ),
                        foregroundImage: _userBox.values.first.photoUrl != null
                            ? NetworkImage(_userBox.values.first.photoUrl!)
                            : null,
                      ),
                    ],
                  ),
                  const Gap(10),
                  AppText(
                    text: _userBox.values.first.displayName!,
                    color: Colors.white,
                    size: AppSizes.bodySmall,
                  ),
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
                const AppText(
                  text: 'Personal Settings',
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
                    await ref.read(authStateProvider.notifier).logOut();
                    if (ref.read(authStateProvider).userId == null) {
                      await navigatorKey.currentState!.pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const SignInScreen()), (r) {
                        return false;
                      });
                    }
                  },
                  contentPadding: const EdgeInsets.all(0),
                  dense: true,
                  leading: const Icon(
                    Iconsax.logout,
                    color: Colors.red,
                  ),
                  title: const AppText(
                    text: 'Log Out',
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
}
