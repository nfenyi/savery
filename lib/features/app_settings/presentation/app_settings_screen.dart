import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/main.dart';

import 'package:savery/themes/themes.dart';

import '../../sign_in/user_info/models/user_model.dart';

class AppSettings extends StatefulWidget {
  final bool enableBiometrics;
  const AppSettings({super.key, required this.enableBiometrics});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  late bool _userEnabledBiometrics;
  final _userBox = Hive.box<AppUser>(AppBoxes.users);
  // late final AppUser _user;

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
        title: const AppText(
          text: 'App Settings',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: AppText(text: 'Theme', size: AppSizes.bodySmall),
            trailing: ThemeDropdownButton(),
          ),
          const ListTile(
            title: AppText(text: 'Language', size: AppSizes.bodySmall),
            trailing: ThemeDropdownButton(),
          ),
          Visibility(
            visible: (widget.enableBiometrics),
            child: ListTile(
              title: const AppText(
                  text: 'Enable biometrics', size: AppSizes.bodySmall),
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
                      color: ((ref.watch(themeProvider) == 'System') &&
                              (MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark))
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
            color: ((ref.watch(themeProvider) == 'System' ||
                        ref.watch(themeProvider) == 'Dark') &&
                    (MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark))
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
            color: ((ref.watch(themeProvider) == 'System' ||
                        ref.watch(themeProvider) == 'Dark') &&
                    (MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark))
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
    // final theme = ref.watch(themeProvider);
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
          'French',
        ]
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: AppSizes.bodySmaller,
                      fontWeight: FontWeight.w500,
                      color: ((ref.watch(themeProvider) == 'System') &&
                              (MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark))
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ))
            .toList(),
        // value: theme == ThemeMode.system
        //     ? 'System'
        //     : theme == ThemeMode.light
        //         ? 'Light'
        //         : 'Dark',
        value: 'Enlish',
        // onChanged: (value) async {
        //   // setState(() {
        //   //   _accounts[index].currency = value;
        //   //   _accounts[index].save();
        //   //   // _accountsBox.values[index];
        //   // });
        //   // ref.read(themeProvider.notifier).changeTheme(value);
        // },
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
            color: ((ref.watch(themeProvider) == 'System' ||
                        ref.watch(themeProvider) == 'Dark') &&
                    (MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark))
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
