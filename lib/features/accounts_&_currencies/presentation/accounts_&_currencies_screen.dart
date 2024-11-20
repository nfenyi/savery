import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/accounts_&_currencies/services/api_constants.dart';
import 'package:savery/features/accounts_&_currencies/services/api_services.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  final RequestResponse currencyResponse;
  const CurrencyScreen({super.key, required this.currencyResponse});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  late List<Account> _accounts;

  final List<String> _currencies = ['GHS', '\$', '£', '€'];

  double _dollarRate = 0;
  double _poundRate = 0;
  double _euroRate = 0;

  @override
  void initState() {
    super.initState();
    _accounts = _accountsBox.values.toList();
    if (widget.currencyResponse.status == RequestStatus.success) {
      final rates = widget.currencyResponse.payload['rates'];
      _dollarRate = rates['USD'];
      _euroRate = rates['EUR'];
      _poundRate = rates['GBP'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const AppText(
          text: 'Accounts & Currencies',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
          children: [
            Visibility(
              visible: _accounts.isNotEmpty,
              replacement: Expanded(
                child: Center(
                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      //TODO: fix all animations and center them
                      Lottie.asset(AppAssets.noAccount, width: 150),
                      const Gap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppText(text: 'Please '),
                          InkWell(
                            onTap: () {
                              navigatorKey.currentState!.pop();
                            },
                            child: Ink(
                              child: const AppText(
                                text: 'create an account',
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const AppText(text: ' first.'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'Transactions',
                    weight: FontWeight.bold,
                    size: AppSizes.bodySmall,
                  ),
                  SizedBox(
                    height: Adaptive.h(20),
                    child: ListView.builder(
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final account = _accounts[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButtonHideUnderline(
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
                                  items: _currencies
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
                                  value: account.currency ?? 'GHS',
                                  onChanged: (value) async {
                                    setState(() {
                                      _accounts[index].currency = value;
                                      _accounts[index].save();
                                      // _accountsBox.values[index];
                                    });
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
                              ),
                              const Gap(45),
                              InkWell(
                                onTap: () async {
                                  final shouldDelete = await showAppInfoDialog(
                                      context,
                                      title:
                                          'Are you sure you want to delete ${account.name}?',
                                      cancelCallbackFunction: () =>
                                          navigatorKey.currentState!.pop(true),
                                      cancelText: 'Yes',
                                      confirmText: 'Cancel');
                                  if (shouldDelete == true) {
                                    await _accountsBox.deleteAt(index);
                                    setState(() {
                                      _accounts = _accountsBox.values.toList();
                                    });
                                  }
                                },
                                child: Ink(
                                  child: const Icon(
                                    FontAwesomeIcons.trashCan,
                                    color: Colors.red,
                                    size: 15,
                                  ),
                                ),
                              )
                            ],
                          ),
                          leading: Image.asset(
                            AppAssets.account,
                            width: 20,
                          ),
                          title: Text(account.name),
                        );
                      },
                    ),
                  ),
                  const Gap(10),
                  const AppText(
                    text: 'Exchange Rates',
                    weight: FontWeight.bold,
                    size: AppSizes.bodySmall,
                  ),
                  const Gap(5),
                  (widget.currencyResponse.status == RequestStatus.success)
                      ? SizedBox(
                          height: Adaptive.h(30),
                          child: Scrollbar(
                            child: ListView(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  leading: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 11),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.deepPurple.shade100,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: const FaIcon(
                                      FontAwesomeIcons.dollarSign,
                                      size: 15,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  title: const Text('Dollar'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppText(
                                        text: (1 / _dollarRate)
                                            .toStringAsFixed(3),
                                        size: AppSizes.bodySmall,
                                      ),
                                      const Gap(5),
                                      const AppText(text: 'GHS'),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  leading: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 11),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.deepPurple.shade100,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: const FaIcon(
                                      FontAwesomeIcons.sterlingSign,
                                      size: 15,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  title: const Text('Pound'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppText(
                                        text:
                                            (1 / _poundRate).toStringAsFixed(3),
                                        size: AppSizes.bodySmall,
                                      ),
                                      const Gap(5),
                                      const AppText(text: 'GHS'),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  leading: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 11),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.deepPurple.shade100,
                                      ),
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    child: const FaIcon(
                                      FontAwesomeIcons.euroSign,
                                      color: Colors.deepPurple,
                                      size: 15,
                                    ),
                                  ),
                                  title: const Text(
                                    'Euro',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AppText(
                                        text:
                                            (1 / _euroRate).toStringAsFixed(3),
                                        size: AppSizes.bodySmall,
                                      ),
                                      const Gap(5),
                                      const AppText(text: 'GHS'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      : Center(
                          child: SizedBox(
                            width: Adaptive.w(60),
                            child: Column(
                              children: [
                                const Gap(20),
                                Image.asset(
                                  AppAssets.noInternet,
                                  height: Adaptive.h(20),
                                ),
                                const AppText(
                                  text:
                                      'Could not retrieve rates. Please check your internet connection',
                                  textAlign: TextAlign.center,
                                )
                              ],
                            ),
                          ),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
