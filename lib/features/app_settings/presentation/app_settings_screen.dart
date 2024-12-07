import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:restart_app/restart_app.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/main_screen/state/localization.dart';

import 'package:savery/themes/themes.dart';

// import '../../sign_in/user_info/models/user_model.dart';

class AppSettings extends StatefulWidget {
  final bool enableBiometrics;
  const AppSettings({super.key, required this.enableBiometrics});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  late bool _userEnabledBiometrics;
  // final _userBox = Hive.box<AppUser>(AppBoxes.users);

  @override
  void initState() {
    super.initState();
    _userEnabledBiometrics = Hive.box(AppBoxes.appState)
        .get('enableBiometrics', defaultValue: false);

    // _user = userBox.values.firstWhere(
    //   (element) => element.uid == _appStateUid,
    // );
  }

  @override
  Widget build(BuildContext context) {
    // logger.d(Hive.box(AppBoxes.appState).get('currentUser'));
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: context.localizations.app_settings,
          //  'App Settings',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: AppText(
                text: context.localizations.theme
                // 'Theme'
                ,
                size: AppSizes.bodySmall),
            trailing: const ThemeDropdownButton(),
          ),
          ListTile(
            title: AppText(
                text: context.localizations.language,

                // 'Language',
                size: AppSizes.bodySmall),
            trailing: const LanguageDropdownButton(),
          ),
          Visibility(
            visible: (widget.enableBiometrics),
            child: ListTile(
              title: AppText(
                  text: context.localizations.enable_biometrics,

                  //  'Enable biometrics',
                  size: AppSizes.bodySmall),
              trailing: Switch.adaptive(
                  value: _userEnabledBiometrics,
                  onChanged: (newValue) async {
                    await Hive.box(AppBoxes.appState)
                        .put('enableBiometrics', newValue);
                    setState(() {
                      _userEnabledBiometrics = newValue;
                    });
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeDropdownButton extends ConsumerWidget {
  const ThemeDropdownButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        iconStyleData: const IconStyleData(
          icon: FaIcon(
            FontAwesomeIcons.chevronDown,
          ),
          iconSize: 12.0,
        ),
        items: ['System', 'Light', 'Dark']
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: AppSizes.bodySmaller,
                      fontWeight: FontWeight.w500,
                      color: (ref.watch(themeProvider) == 'System' &&
                                  MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark) ||
                              ref.watch(themeProvider) == 'Dark'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ))
            .toList(),
        value: theme,
        onChanged: (value) async {
          // setState(() {
          //   _accounts[index].currency = value;
          //   _accounts[index].save();
          //   // _accountsBox.values[index];
          // });
          await ref.read(themeProvider.notifier).changeTheme(value);
        },
        buttonStyleData: ButtonStyleData(
          height: AppSizes.dropDownBoxHeight,
          padding: const EdgeInsets.only(right: 10.0),
          decoration: BoxDecoration(
            color: (ref.watch(themeProvider) == 'System' &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark) ||
                    ref.watch(themeProvider) == 'Dark'
                ? const Color.fromARGB(255, 32, 25, 33)
                : Colors.white,
            border: Border.all(
              width: 1.0,
              color: AppColors.neutral300,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 350,
          elevation: 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: (ref.watch(themeProvider) == 'System' &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark) ||
                    ref.watch(themeProvider) == 'Dark'
                ? const Color.fromARGB(255, 32, 25, 33)
                : Colors.white,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40.0,
        ),
      ),
    );
  }
}

class LanguageDropdownButton extends ConsumerWidget {
  const LanguageDropdownButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String language = ref.watch(languageProvider);
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        iconStyleData: const IconStyleData(
          icon: FaIcon(
            FontAwesomeIcons.chevronDown,
          ),
          iconSize: 12.0,
        ),
        items: [
          'English',
          'Français',
        ]
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: AppSizes.bodySmaller,
                      fontWeight: FontWeight.w500,
                      color: (ref.watch(themeProvider) == 'System' &&
                                  MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark) ||
                              ref.watch(themeProvider) == 'Dark'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ))
            .toList(),
        value: language,
        onChanged: (value) async {
          if (value != null && value != ref.watch(languageProvider)) {
            await ref.read(languageProvider.notifier).changeLanguage(value);
            await Restart.restartApp(
              // Customizing the notification message only on iOS
              notificationTitle: 'Restarting App',
              notificationBody: 'Please tap here to open the app again.',
            );
          }
        },
        buttonStyleData: ButtonStyleData(
          height: AppSizes.dropDownBoxHeight,
          padding: const EdgeInsets.only(right: 10.0),
          decoration: BoxDecoration(
            // color: Colors.grey.shade100,
            border: Border.all(
              width: 1.0,
              color: AppColors.neutral300,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 350,
          elevation: 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: (ref.watch(themeProvider) == 'System' &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark) ||
                    ref.watch(themeProvider) == 'Dark'
                ? const Color.fromARGB(255, 32, 25, 33)
                : Colors.white,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40.0,
        ),
      ),
    );
  }
}
