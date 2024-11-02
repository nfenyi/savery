import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/features/main_screen/models/settings.dart';
import 'package:savery/features/sign_in/notifiers/providers/providers.dart';

import '../../../app_constants/app_assets.dart';
import '../../../app_constants/app_colors.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final List<Setting> _settings = [
    Setting(
      icon: Iconsax.notification,
      name: "Notifications",
    ),
    Setting(
      icon: Icons.settings_outlined,
      name: "Settings",
    ),
    Setting(
      icon: Iconsax.grid_2,
      name: "Categories",
    ),
    Setting(
      icon: Iconsax.personalcard,
      name: "Accounts",
    ),
    Setting(
      icon: FontAwesomeIcons.chartLine,
      name: "Currency",
    ),
    Setting(
      icon: FontAwesomeIcons.globe,
      name: "Language",
    ),
    Setting(
      icon: Iconsax.message,
      name: "Support",
    ),
    // Setting(
    //   icon: Iconsax.logout,
    //   name: "Log Out",
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Adaptive.h(18),
            width: double.infinity,
            decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
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
                      const CircleAvatar(
                        maxRadius: 58,
                        minRadius: 58,
                        backgroundImage: AssetImage(
                          AppAssets.noProfile,
                        ),
                        foregroundImage: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9QjDx088rRn46JIdmY-e_ayp5nfCM0dWLjA&s'),
                      ),
                    ],
                  ),
                  const Gap(10),
                  const AppText(
                    text: '[name]',
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
                  shrinkWrap: true,
                  itemCount: _settings.length,
                  itemBuilder: (context, index) {
                    final setting = _settings[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          color: AppColors.neutral100,
                          child: Icon(setting.icon),
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
                  onTap: () async =>
                      ref.read(authStateProvider.notifier).logOut,
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
