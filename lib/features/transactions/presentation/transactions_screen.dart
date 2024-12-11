import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/extensions/context_extenstions.dart';
// import 'package:savery/features/main_screen/app_background_check_provider/app_background_check_provider.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_assets.dart';
import '../../../app_functions/app_functions.dart';
import '../../../themes/themes.dart';
import '../../sign_in/user_info/models/user_model.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final Account initAccount;
  const TransactionsScreen({required this.initAccount, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String? _selectedFilter = 'All';
  // String? _selectedSortBy = 'Sort by date';
  late Account _selectedAccount;
  // final _userBox = Hive.box<AppUser>(AppBoxes.user);
  late List<AccountTransaction> _reversedTransactions;
  // late List<AccountTransaction>? _transactionsHolder;

  // int? _periodFilter = 1;
  // String _selectedTransactionTypeFilter = 'All';
  final DateTime dateTimeNow = DateTime.now();
  late DateTime? _dateHolder;
  late String? _currency;
  late final List<String> _filters;
  late List<AccountTransaction> _filteredReversedTransactions;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.initAccount;
    // _selectedAccountName = _selectedAccount.name;
    _reversedTransactions = _selectedAccount.transactions!.reversed.toList();
    _filteredReversedTransactions = _reversedTransactions;
    _currency = _selectedAccount.currency ?? 'GHS';
    _filters = [
      'All',
      'Income',
      ...Hive.box<TransactionCategory>(AppBoxes.transactionsCategories)
          .values
          .map(
            (e) => e.name,
          ),
    ];
    // _transactionsHolder = _reversedTransactions
    //     ?.where((element) =>
    //         (element.date.day == dateTimeNow.day) &&
    //         (element.date.difference(dateTimeNow) < const Duration(days: 1)))
    //     .toList();
  }

  @override
  Widget build(BuildContext context) {
    _dateHolder = _selectedAccount.transactions?.reversed.first.date;

    //  _selectedAccount = _userBox.values.first.accounts?.first;
    // _selectedAccountName = _selectedAccount.name;
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        title: AppText(
          text: navigatorKey.currentContext!.localizations.transactions,
          // 'Transactions',
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
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                alignment: Alignment.center,
                isExpanded: true,
                hint: const AppText(
                  text: 'filter by...',
                  textAlign: TextAlign.center,

                  // isFetching ? 'Please wait...' : "Select...",

                  overflow: TextOverflow.ellipsis,
                ),
                iconStyleData: const IconStyleData(
                  icon: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: AppColors.neutral900,
                  ),
                  iconSize: 12.0,
                ),
                items: _filters
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: AppText(
                            text: item,
                            textAlign: TextAlign.center,
                            size: AppSizes.bodySmaller,
                            weight: FontWeight.w500,
                            color: AppColors.neutral900,
                          ),
                        ))
                    .toList(),
                value: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value;
                    if (_selectedFilter == 'All') {
                      _filteredReversedTransactions = _reversedTransactions;
                    } else if (_selectedFilter == 'Income') {
                      _filteredReversedTransactions = _reversedTransactions
                          .where(
                            (element) => element.type == 'Income',
                          )
                          .toList();
                    } else if (_selectedFilter == null) {
                    } else {
                      _filteredReversedTransactions = _reversedTransactions
                          .where(
                            (element) =>
                                element.category?.name == _selectedFilter,
                          )
                          .toList();
                    }
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: AppSizes.dropDownBoxHeight,
                  padding: const EdgeInsets.only(right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    // border: Border.all(
                    //   width: 1.0,
                    //   color: AppColors.neutral300,
                    // ),
                    borderRadius: BorderRadius.circular(20.0),
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
            const Gap(10),
            if (_filteredReversedTransactions.isNotEmpty)
              AppText(
                textAlign: TextAlign.left,
                text: (dateTimeNow.day == _dateHolder?.day)
                    ? context.localizations.today
                    : (dateTimeNow.weekday - _dateHolder!.weekday == 1)
                        ? navigatorKey.currentContext!.localizations.yesterday
                        // 'Yesterday'
                        : (dateTimeNow.difference(_dateHolder!).inDays > 7)
                            ? AppFunctions.formatDate(_dateHolder!.toString(),
                                format: r'l')
                            : AppFunctions.formatDate(_dateHolder!.toString(),
                                format: r'j M'),
              ),
            const Gap(10),
            // (_transactionsHolder != null && _transactionsHolder!.isNotEmpty)
            //     ?
            (_filteredReversedTransactions.isNotEmpty)
                ? Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          final transaction =
                              _filteredReversedTransactions[index];
                          return Container(
                            decoration: BoxDecoration(
                                color: (ref.watch(themeProvider) == 'System' &&
                                            MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark) ||
                                        ref.watch(themeProvider) == 'Dark'
                                    ? const Color.fromARGB(255, 39, 32, 39)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              // tileColor: Colors.grey.shade100,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                    padding: const EdgeInsets.all(10),
                                    width: 50,
                                    color: ((ref.watch(themeProvider) ==
                                                'System') &&
                                            (MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark))
                                        ? AppColors.primaryDark.withOpacity(0.1)
                                        : AppColors.primary.withOpacity(0.1),
                                    child: transaction.category == null
                                        ? FaIcon(
                                            FontAwesomeIcons.coins,
                                            color: ((ref.watch(themeProvider) ==
                                                        'System') &&
                                                    (MediaQuery
                                                            .platformBrightnessOf(
                                                                context) ==
                                                        Brightness.dark))
                                                ? AppColors.primaryDark
                                                : AppColors.primary,
                                          )
                                        : Iconify(
                                            transaction.category!.icon,
                                            color: ((ref.watch(themeProvider) ==
                                                        'System') &&
                                                    (MediaQuery
                                                            .platformBrightnessOf(
                                                                context) ==
                                                        Brightness.dark))
                                                ? AppColors.primaryDark
                                                : AppColors.primary,
                                          )),
                              ),
                              title: AppText(
                                  text: transaction.type == 'Income'
                                      ? navigatorKey
                                          .currentContext!.localizations.income
                                      // "Income"
                                      : transaction.category!.name),
                              subtitle: AppText(
                                text: transaction.description,
                                color: Colors.grey,
                              ),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AppText(
                                    text:
                                        '${transaction.type == 'Income' ? '+' : '-'} $_currency ${transaction.amount.toString()}',
                                    color: transaction.type == 'Income'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  AppText(
                                    text: AppFunctions.formatDate(
                                        transaction.date.toString(),
                                        format: r'g:i A'),
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          if (_filteredReversedTransactions[index + 1]
                                  .date
                                  .difference(_dateHolder!) >
                              const Duration(days: 7)) {
                            // _dateHolder =
                            //     value.transactions?[index].date;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(5),
                                AppText(
                                    text: AppFunctions.formatDate(
                                        _filteredReversedTransactions[index + 1]
                                            .date
                                            .toString(),
                                        format: r'j M Y')),
                                const Gap(5),
                              ],
                            );
                          } else {
                            final transactionDay =
                                _filteredReversedTransactions[index + 1]
                                    .date
                                    .weekday;

                            if (_dateHolder!.weekday == transactionDay) {
                              // logger.d(reversedTransactions[index].description);
                              return const Gap(10);
                            } else {
                              _dateHolder =
                                  _filteredReversedTransactions[index + 1].date;
                              // logger.d(reversedTransactions[index].description);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(5),
                                  AppText(
                                    text: _filteredReversedTransactions[index + 1]
                                                .date
                                                .weekday ==
                                            1
                                        ? context.localizations.monday
                                        : _filteredReversedTransactions[index + 1]
                                                    .date
                                                    .weekday ==
                                                2
                                            ? context.localizations.tuesday
                                            : _filteredReversedTransactions[index + 1]
                                                        .date
                                                        .weekday ==
                                                    3
                                                ? context
                                                    .localizations.wednesday
                                                : _filteredReversedTransactions[
                                                                index + 1]
                                                            .date
                                                            .weekday ==
                                                        4
                                                    ? context
                                                        .localizations.thursday
                                                    : _filteredReversedTransactions[
                                                                    index + 1]
                                                                .date
                                                                .weekday ==
                                                            5
                                                        ? context.localizations
                                                            .friday
                                                        : _filteredReversedTransactions[index + 1]
                                                                    .date
                                                                    .weekday ==
                                                                6
                                                            ? context
                                                                .localizations
                                                                .saturday
                                                            : context
                                                                .localizations
                                                                .sunday,
                                  ),
                                  const Gap(5),
                                ],
                              );
                            }
                          }
                        },
                        itemCount: _filteredReversedTransactions.length),
                  )
                : Expanded(
                    child: Center(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(AppAssets.emptyList, height: 200),
                        const AppText(text: 'No such transactions.'),
                        Gap(Adaptive.h(20)),
                      ],
                    )),
                  )
          ],
        ),
      ),
    );
  }
}
