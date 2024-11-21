import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';

import '../../../app_functions/app_functions.dart';
import '../../main_screen/presentation/widgets.dart';
import '../../sign_in/user_info/models/user_model.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final Account initAccount;
  const TransactionsScreen({required this.initAccount, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late String _selectedAccountName;
  String? _selectedSortBy = 'Sort by date';
  late Account _selectedAccount;
  final _userBox = Hive.box<AppUser>(AppBoxes.user);
  late Iterable<AccountTransaction>? _reversedTransactions;
  late List<AccountTransaction>? _transactionsHolder;

  int? _periodFilter = 1;
  String _selectedTransactionTypeFilter = 'All';
  final DateTime dateTimeNow = DateTime.now();
  late DateTime? _dateHolder;
  late String? _currency;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.initAccount;
    _selectedAccountName = _selectedAccount.name;
    _reversedTransactions = _selectedAccount.transactions?.reversed;
    _currency = _selectedAccount.currency ?? 'GHS';
    _transactionsHolder = _reversedTransactions
        ?.where((element) =>
            (element.date.day == dateTimeNow.day) &&
            (element.date.difference(dateTimeNow) < const Duration(days: 1)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    //put at a better place:
    DateTime dateTimeNow = DateTime.now();
    // logger.d(_reversedTransactions);
    // logger.d(_transactionsHolder);

    _dateHolder = _selectedAccount.transactions?.reversed.first.date;
    //  _selectedAccount = _userBox.values.first.accounts?.first;
    // _selectedAccountName = _selectedAccount.name;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppText(text: 'Transactions'),
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
                  text: 'Accounts',
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
                items: _userBox.values.first.accounts!
                    .map(
                      (e) => e.name,
                    )
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
                value: _selectedAccountName,
                onChanged: (value) {
                  setState(() {
                    _selectedAccountName = value!;
                    _selectedAccount =
                        _userBox.values.first.accounts!.firstWhere(
                      (element) => element.name == value,
                    );

                    _reversedTransactions =
                        _selectedAccount.transactions!.reversed;

                    _transactionsHolder = _reversedTransactions
                        ?.where((element) =>
                            (element.date.day == dateTimeNow.day) &&
                            (element.date.difference(dateTimeNow) <
                                const Duration(days: 1)))
                        .toList();
                    _periodFilter = 1;
                    _selectedTransactionTypeFilter = 'All';
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
            Row(
              children: [
                Expanded(
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: Colors.grey.shade100,
                    thumbColor: AppColors.primary,
                    children: {
                      0: AppText(
                        text: 'All',
                        isWhite: _periodFilter == 0 ? true : false,
                      ),
                      1: AppText(
                        text: 'Day',
                        isWhite: _periodFilter == 1 ? true : false,
                      ),
                      2: AppText(
                        text: 'Week',
                        isWhite: _periodFilter == 2 ? true : false,
                      ),
                      3: AppText(
                        text: 'Month',
                        isWhite: _periodFilter == 3 ? true : false,
                      ),
                      4: AppText(
                        text: 'Year',
                        isWhite: _periodFilter == 4 ? true : false,
                      ),
                    },
                    groupValue: _periodFilter,
                    onValueChanged: (value) {
                      setState(() {
                        _periodFilter = value;
                        if (_selectedAccount.transactions != null) {
                          if (_periodFilter == 0) {
                            if (_selectedTransactionTypeFilter == 'All') {
                              _transactionsHolder =
                                  _reversedTransactions?.toList();
                            } else if (_selectedTransactionTypeFilter ==
                                'Income') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where(
                                    (element) => element.type == 'Income',
                                  )
                                  .toList();
                            } else {
                              _transactionsHolder = _reversedTransactions
                                  ?.where(
                                    (element) => element.type == 'Expense',
                                  )
                                  .toList();
                            }
                          } else if (_periodFilter == 1) {
                            if (_selectedTransactionTypeFilter == 'All') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      element.date.day == dateTimeNow.day &&
                                      element.date.difference(dateTimeNow) <
                                          const Duration(days: 1))
                                  .toList();
                            } else if (_selectedTransactionTypeFilter ==
                                'Income') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      element.date.day == dateTimeNow.day &&
                                      element.date.difference(dateTimeNow) <
                                          const Duration(days: 1))
                                  .where(
                                    (element) => element.type == 'Income',
                                  )
                                  .toList();
                            } else {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      element.date.day == dateTimeNow.day &&
                                      element.date.difference(dateTimeNow) <
                                          const Duration(days: 1))
                                  .where(
                                    (element) => element.type == 'Expense',
                                  )
                                  .toList();
                            }
                          } else if (_periodFilter == 2) {
                            if (_selectedTransactionTypeFilter == 'All') {
                              _transactionsHolder = _reversedTransactions
                                  //TODO: Implement a better function so iteration stops right when the seventh day of
                                  //transactions has been fetched.
                                  //maybe use the firstWhere where on false values are added to an outside list and the search
                                  //is terminated when true is emitted by the firstWhere function
                                  ?.where(
                                    (element) =>
                                        element.date.difference(dateTimeNow) <
                                        const Duration(days: 7),
                                  )
                                  .toList();
                            } else if (_selectedTransactionTypeFilter ==
                                'Income') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where(
                                    (element) =>
                                        element.date.difference(dateTimeNow) <
                                        const Duration(days: 7),
                                  )
                                  .where(
                                    (element) => element.type == 'Income',
                                  )
                                  .toList();
                            } else {
                              _transactionsHolder = _reversedTransactions
                                  ?.where(
                                    (element) =>
                                        element.date.difference(dateTimeNow) <
                                        const Duration(days: 7),
                                  )
                                  .where(
                                    (element) => element.type == 'Expense',
                                  )
                                  .toList();
                            }
                          } else if (_periodFilter == 3) {
                            if (_selectedTransactionTypeFilter == 'All') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      (element.date.year == dateTimeNow.year) &&
                                      (element.date.month == dateTimeNow.month))
                                  .toList();
                            } else if (_selectedTransactionTypeFilter ==
                                'Income') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      (element.date.month ==
                                          dateTimeNow.month) &&
                                      (element.date.year == dateTimeNow.year))
                                  .where(
                                    (element) => element.type == 'Income',
                                  )
                                  .toList();
                            } else {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      (element.date.month ==
                                          dateTimeNow.month) &&
                                      (element.date.year == dateTimeNow.year))
                                  .where(
                                    (element) => element.type == 'Expense',
                                  )
                                  .toList();
                            }
                          } else {
                            if (_selectedTransactionTypeFilter == 'All') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      element.date.year == dateTimeNow.year)
                                  .toList();
                            } else if (_selectedTransactionTypeFilter ==
                                'Income') {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      element.date.year == dateTimeNow.year)
                                  .where(
                                    (element) =>
                                        element.type ==
                                        _selectedTransactionTypeFilter,
                                  )
                                  .toList();
                            } else {
                              _transactionsHolder = _reversedTransactions
                                  ?.where((element) =>
                                      element.date.year == dateTimeNow.year)
                                  .where(
                                    (element) =>
                                        element.type ==
                                        _selectedTransactionTypeFilter,
                                  )
                                  .toList();
                            }
                          }
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    borderRadius: 20,
                    callback: () {
                      setState(() {
                        _selectedTransactionTypeFilter = 'All';
                        if (_periodFilter == 0) {
                          _transactionsHolder = _reversedTransactions?.toList();
                        } else if (_periodFilter == 1) {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  (element.date.day == dateTimeNow.day) &&
                                  (element.date.difference(dateTimeNow) <
                                      const Duration(days: 1)))
                              .toList();
                        } else if (_periodFilter == 2) {
                          _transactionsHolder = _reversedTransactions
                              ?.where(
                                (element) =>
                                    element.date.difference(dateTimeNow) <
                                    const Duration(days: 7),
                              )
                              .toList();
                        } else if (_periodFilter == 3) {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  (element.date.year == dateTimeNow.year) &&
                                  (element.date.month == dateTimeNow.month))
                              .toList();
                        } else {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  element.date.year == dateTimeNow.year)
                              .toList();
                        }
                      });
                    },
                    text: 'All',
                    textColor: _selectedTransactionTypeFilter == 'All'
                        ? Colors.white
                        : Colors.black,
                    buttonColor: _selectedTransactionTypeFilter == 'All'
                        ? AppColors.primary
                        : Colors.grey.shade100,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: AppButton(
                    borderRadius: 20,
                    callback: () {
                      setState(() {
                        _selectedTransactionTypeFilter = 'Income';
                        if (_periodFilter == 0) {
                          _transactionsHolder = _reversedTransactions
                              ?.where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else if (_periodFilter == 1) {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  (element.date.day == dateTimeNow.day) &&
                                  (element.date.difference(dateTimeNow) <
                                      const Duration(days: 1)))
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else if (_periodFilter == 2) {
                          _transactionsHolder = _reversedTransactions
                              ?.where(
                                (element) =>
                                    element.date.difference(dateTimeNow) <
                                    const Duration(days: 7),
                              )
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else if (_periodFilter == 3) {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  (element.date.year == dateTimeNow.year) &&
                                  (element.date.month == dateTimeNow.month))
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  element.date.year == dateTimeNow.year)
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        }
                      });
                    },
                    text: 'Incomes',
                    textColor: _selectedTransactionTypeFilter == 'Income'
                        ? Colors.white
                        : Colors.black,
                    buttonColor: _selectedTransactionTypeFilter == 'Income'
                        ? AppColors.primary
                        : Colors.grey.shade100,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: AppButton(
                    borderRadius: 20,
                    callback: () {
                      setState(() {
                        _selectedTransactionTypeFilter = 'Expense';
                        if (_periodFilter == 0) {
                          _transactionsHolder = _reversedTransactions
                              ?.where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else if (_periodFilter == 1) {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  (element.date.day == dateTimeNow.day) &&
                                  (element.date.difference(dateTimeNow) <
                                      const Duration(days: 1)))
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else if (_periodFilter == 2) {
                          _transactionsHolder = _reversedTransactions
                              ?.where(
                                (element) =>
                                    element.date.difference(dateTimeNow) <
                                    const Duration(days: 7),
                              )
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else if (_periodFilter == 3) {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  (element.date.year == dateTimeNow.year) &&
                                  (element.date.month == dateTimeNow.month))
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        } else {
                          _transactionsHolder = _reversedTransactions
                              ?.where((element) =>
                                  element.date.year == dateTimeNow.year)
                              .where(
                                (element) =>
                                    element.type ==
                                    _selectedTransactionTypeFilter,
                              )
                              .toList();
                        }
                      });
                    },
                    buttonColor: _selectedTransactionTypeFilter == 'Expense'
                        ? AppColors.primary
                        : Colors.grey.shade100,
                    text: 'Expenses',
                    textColor: _selectedTransactionTypeFilter == 'Expense'
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      alignment: Alignment.centerRight,
                      hint: const AppText(
                        text: 'Sort by',
                        color: AppColors.primary,

                        // isFetching ? 'Please wait...' : "Select...",

                        overflow: TextOverflow.ellipsis,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: FaIcon(
                          FontAwesomeIcons.chevronDown,
                          color: AppColors.primary,
                        ),
                        iconSize: 12.0,
                      ),
                      items: [
                        'Sort by date',
                        'Sort by categories',
                      ]
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.manrope(
                                    fontSize: AppSizes.bodySmaller,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: _selectedSortBy,
                      onChanged: (value) {
                        setState(() {
                          _selectedSortBy = value;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: AppSizes.dropDownBoxHeight,
                        padding: const EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                          // color: Colors.grey.shade100,
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
                ),
              ],
            ),
            const Divider(),
            if (_transactionsHolder != null && _transactionsHolder!.isNotEmpty)
              Container(
                color: Colors.white,
                child: AppText(
                    textAlign: TextAlign.left,
                    text: (DateTime.now().day == _dateHolder?.day)
                        ? 'Today'
                        : (DateTime.now().weekday - _dateHolder!.weekday == 1)
                            ? 'Yesterday'
                            : AppFunctions.formatDate(_dateHolder.toString(),
                                format: r'g:i A')),
              ),
            const Gap(10),
            (_transactionsHolder != null && _transactionsHolder!.isNotEmpty)
                ? Expanded(
                    child: ListView.separated(
                        //TODO: find a better way to implement the implementation of timestamps
                        //and remove cacheExtent property
                        cacheExtent: 1000000,
                        itemBuilder: (context, index) {
                          final transaction = _transactionsHolder![index];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            tileColor: Colors.grey.shade100,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: 50,
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    getCategoryIcon(transaction.category!),
                                    color: AppColors.primary,
                                  )),
                            ),
                            title: AppText(
                                text: transaction.type == 'Income'
                                    ? "Income"
                                    : transaction.category!),
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
                          );
                        },
                        separatorBuilder: (context, index) {
                          if (_transactionsHolder![index]
                                  .date
                                  .difference(_dateHolder!) >
                              const Duration(days: 6)) {
                            // _dateHolder =
                            //     value.transactions?[index].date;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(5),
                                AppText(
                                    text: AppFunctions.formatDate(
                                        _transactionsHolder![index]
                                            .date
                                            .toString(),
                                        format: r'j M Y')),
                                const Gap(5),
                              ],
                            );
                          } else {
                            final transactionDay =
                                _transactionsHolder![index].date.day;

                            if (_dateHolder!.day == transactionDay) {
                              return const Gap(10);
                            } else {
                              _dateHolder = _transactionsHolder![index].date;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Gap(5),
                                  AppText(
                                      text: AppFunctions.formatDate(
                                          _transactionsHolder![index]
                                              .date
                                              .toString(),
                                          format: 'l')),
                                  const Gap(5),
                                ],
                              );
                            }
                          }
                        },
                        itemCount: _transactionsHolder!.length),
                  )
                : Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(AppAssets.emptyList, height: 200),
                      AppText(
                          text: _periodFilter == 0 &&
                                  _selectedTransactionTypeFilter == 'All'
                              ? 'No transactions made on this account.'
                              : _periodFilter == 0
                                  ? 'No ${_selectedTransactionTypeFilter}s.'
                                  : _selectedTransactionTypeFilter == 'All'
                                      ? 'No transactions made during this period.'
                                      : 'No such transactions made during this period.')
                    ],
                  ))
          ],
        ),
      ),
    );
  }
}
