import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/main.dart';
import 'package:savery/themes/themes.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'App Settings',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: AppText(text: 'Theme'),
            trailing: ThemeDropdownButton(),
          )
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
        hint: const AppText(
          text: 'GHS',
          overflow: TextOverflow.ellipsis,
          color: Colors.grey,
        ),
        iconStyleData: const IconStyleData(
          icon: FaIcon(
            FontAwesomeIcons.chevronDown,
            color: AppColors.primary,
          ),
          iconSize: 12.0,
        ),
        items: ['System', 'Light', 'Dark']
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: AppSizes.bodySmaller,
                      fontWeight: FontWeight.w500,
                      // color: Colors.grey,
                    ),
                  ),
                ))
            .toList(),
        value: theme == ThemeMode.system
            ? 'System'
            : theme == ThemeMode.light
                ? 'Light'
                : 'Dark',
        onChanged: (value) async {
          // setState(() {
          //   _accounts[index].currency = value;
          //   _accounts[index].save();
          //   // _accountsBox.values[index];
          // });
          ref.read(themeProvider.notifier).changeTheme(value);
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
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40.0,
        ),
      ),
    );
  }
}
