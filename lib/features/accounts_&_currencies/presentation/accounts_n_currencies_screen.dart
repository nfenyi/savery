import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
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
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/accounts_&_currencies/services/api_constants.dart';
import 'package:savery/features/accounts_&_currencies/services/api_services.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';
import 'package:html/dom.dart' as dom;
// import 'package:savery/utils/view_model_result.dart';

import '../../../themes/themes.dart';

class AccountsnCurrenciesScreen extends ConsumerStatefulWidget {
  final RequestResponse currencyResponse;
  const AccountsnCurrenciesScreen({super.key, required this.currencyResponse});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<AccountsnCurrenciesScreen> {
  final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  late List<Account> _accounts;

  final List<String> _currencies = ['GHS', '\$', '£', '€'];

  late final String _dollarRate;
  late final String _poundRate;
  late final String _euroRate;

  @override
  void initState() {
    super.initState();
    _accounts = _accountsBox.values.toList();
    if (widget.currencyResponse.status == RequestStatus.success) {
      dom.Document html = dom.Document.html(widget.currencyResponse.payload);

      final rates = html
          .querySelectorAll('#p')
          .map((element) => element.innerHtml.trim())
          .toList();
      // final rates = widget.currencyResponse.payload;
      _dollarRate = rates[0];
      _euroRate = rates[1];
      _poundRate = rates[2];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppText(
            text: context.localizations.accounts_n_currencies,
            weight: FontWeight.bold,
            size: AppSizes.bodySmall,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.horizontalPaddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: context.localizations.accounts,
                weight: FontWeight.bold,
                size: AppSizes.bodySmall,
              ),
              _accounts.isEmpty
                  ? Center(
                      child: Column(
                        children: [
                          Lottie.asset(AppAssets.noAccount, height: 100),
                          AppText(
                            text: context.localizations.no_accounts,
                            size: AppSizes.bodySmaller,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          ListView.builder(
                            shrinkWrap: true,
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
                                        iconStyleData: IconStyleData(
                                          icon: FaIcon(
                                            FontAwesomeIcons.chevronDown,
                                            color: (ref.watch(themeProvider) ==
                                                            'System' &&
                                                        MediaQuery
                                                                .platformBrightnessOf(
                                                                    context) ==
                                                            Brightness.dark) ||
                                                    ref.watch(themeProvider) ==
                                                        'Dark'
                                                ? AppColors.primaryDark
                                                : AppColors.primary,
                                          ),
                                          iconSize: 12.0,
                                        ),
                                        items: _currencies
                                            .map((item) => DropdownMenuItem(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: TextStyle(
                                                      fontSize:
                                                          AppSizes.bodySmaller,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: ((ref.watch(
                                                                      themeProvider) ==
                                                                  'System') &&
                                                              (MediaQuery.platformBrightnessOf(
                                                                      context) ==
                                                                  Brightness
                                                                      .dark))
                                                          ? Colors.white
                                                          : Colors.black,
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
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          decoration: BoxDecoration(
                                            color: ((ref.watch(themeProvider) ==
                                                            'System' ||
                                                        ref.watch(
                                                                themeProvider) ==
                                                            'Dark') &&
                                                    (MediaQuery
                                                            .platformBrightnessOf(
                                                                context) ==
                                                        Brightness.dark))
                                                ? const Color.fromARGB(
                                                    255, 32, 25, 33)
                                                : Colors.white,

                                            // color: Colors.grey.shade100,
                                            border: Border.all(
                                              width: 1.0,
                                              color: AppColors.neutral300,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        dropdownStyleData: DropdownStyleData(
                                          maxHeight: 350,
                                          elevation: 1,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: ((ref.watch(themeProvider) ==
                                                            'System' ||
                                                        ref.watch(
                                                                themeProvider) ==
                                                            'Dark') &&
                                                    (MediaQuery
                                                            .platformBrightnessOf(
                                                                context) ==
                                                        Brightness.dark))
                                                ? const Color.fromARGB(
                                                    255, 32, 25, 33)
                                                : Colors.white,
                                          ),
                                        ),
                                        menuItemStyleData:
                                            const MenuItemStyleData(
                                          height: 40.0,
                                        ),
                                      ),
                                    ),
                                    const Gap(45),
                                    InkWell(
                                      onTap: () async {
                                        await showAppInfoDialog(context, ref,
                                            isWarning: true,
                                            title: context.localizations
                                                .delete_account_warning_message(
                                                    account.name),
                                            // 'Are you sure you want to delete ${account.name}?',
                                            cancelText: 'No',
                                            confirmCallbackFunction: () async {
                                          await _accountsBox.deleteAt(index);
                                          setState(() {
                                            _accounts =
                                                _accountsBox.values.toList();
                                          });
                                          navigatorKey.currentState!.pop();
                                        }, confirmText: 'Yes');
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
                                leading: SvgPicture.asset(
                                  AppAssets.account,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                    ((ref.watch(themeProvider) == 'System') &&
                                            (MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark))
                                        ? Colors.white
                                        : Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                title: Text(account.name),
                              );
                            },
                          ),
                        ]),
              const Gap(50),
              AppText(
                text: context.localizations.exchange_rates,
                // 'Exchange Rates',
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
                              title: Text(
                                context.localizations.dollar,
                                // 'Dollar'
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText(
                                    text: _dollarRate,
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
                              title: Text(context.localizations.pound
                                  // 'Pound'
                                  ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText(
                                    text: _poundRate,
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
                              title: Text(context.localizations.euro
                                  // 'Euro',
                                  ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppText(
                                    text: _euroRate,
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
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: ((ref.watch(themeProvider) ==
                                            'System') &&
                                        (MediaQuery.platformBrightnessOf(
                                                context) ==
                                            Brightness.dark))
                                    ? const Color.fromARGB(255, 236, 233, 241)
                                    : Colors.white,
                              ),
                              child: Image.asset(
                                AppAssets.noInternet,
                                height: Adaptive.h(20),
                              ),
                            ),
                            const Gap(10),
                            AppText(
                              text: widget.currencyResponse.payload,
                              //  context.localizations
                              //     .exchange_rates_fetch_failure_message,
                              // 'Could not retrieve rates. Please check your internet connection',
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    )
            ],
          ),
        ));
  }
}
