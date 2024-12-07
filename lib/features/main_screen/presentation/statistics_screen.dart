import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/sign_in/user_info/providers/providers.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../themes/themes.dart';
import '../../sign_in/user_info/models/user_model.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  int? _periodFilter = 1;
  String? _selectedAccountName;
  String? _selectedSortBy = 'Sort by date';
  late Account? _selectedAccount;

  //income
  Map<String, Map<String, dynamic>> _yearIncomeMap = {};
  Map<String, Map<String, dynamic>> _dayIncomeMap = {};
  Map<String, Map<String, dynamic>> _weekIncomeMap = {};
  Map<String, Map<String, dynamic>> _monthIncomeMap = {};
  Map<String, Map<String, dynamic>> _allIncomeMap = {};
  double _overallYearIncome = 0;
  double _overallDayIncome = 0;
  double _overallWeekIncome = 0;
  double _overallMonthIncome = 0;
  double _overallIncome = 0;

  //expense
  Map<String, Map<String, dynamic>> _yearExpenseMap = {};
  Map<String, Map<String, dynamic>> _dayExpenseMap = {};
  Map<String, Map<String, dynamic>> _weekExpenseMap = {};
  Map<String, Map<String, dynamic>> _monthExpenseMap = {};
  Map<String, Map<String, dynamic>> _allExpenseMap = {};
  double _overallYearExpense = 0;
  double _overallDayExpense = 0;
  double _overallWeekExpense = 0;
  double _overallMonthExpense = 0;
  double _overallExpense = 0;

  bool _inIncomeView = true;
  late Iterable<AccountTransaction>? _reversedTransactions;
  late Map<String, Map> _transactionsHolder;

  final _dateTimeNow = DateTime.now();
  late final AnimationController _animationController;
  final _descriptionString = 'description';
  final _amountString = 'amount';
  final _categoryString = 'category';

  late final String _appStateUid;

  @override
  void initState() {
    super.initState();
    _appStateUid = Hive.box(AppBoxes.appState).get('currentUser');
    _selectedAccount = ref
        .read(userProvider.notifier)
        .user(_appStateUid)
        .accounts
        ?.firstOrNull;
    _selectedAccountName = _selectedAccount?.name;
    _reversedTransactions = _selectedAccount?.transactions?.reversed;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));

    if (_reversedTransactions != null) {
      for (final transaction in _reversedTransactions!) {
        if ((transaction.date.day == _dateTimeNow.day)) {
          final hour = _getTransactionHour(transaction.date);
          final amount = transaction.amount;
          final type = transaction.type;

          if (type == context.localizations.income) {
            _dayIncomeMap[hour] = {
              _amountString:
                  (_dayIncomeMap[hour]?[_amountString] ?? 0) + amount,
              _descriptionString: transaction.description
            };
          } else {
            _dayExpenseMap[hour] = {
              _amountString: _dayExpenseMap[hour]
                      ?[transaction.category!.name] ??
                  0 + amount,
              _descriptionString: transaction.description,
              _categoryString: transaction.category,
            };
          }
          if (transaction == _reversedTransactions?.last) {
            _overallDayIncome = _dayIncomeMap.values.fold(
              0,
              (previousValue, element) =>
                  previousValue + element[_amountString],
            );
            _overallDayExpense = _dayExpenseMap.values.fold(
                0,
                (previousValue, element) =>
                    previousValue + element[_amountString]);
          }
        } else {
          _overallDayIncome = _dayIncomeMap.values.fold(
            0,
            (previousValue, element) => previousValue + element[_amountString],
          );
          _overallDayExpense = _dayExpenseMap.values.fold(
              0,
              (previousValue, element) =>
                  previousValue + element[_amountString]);
          break;
        }
      }
    }

    _transactionsHolder = _dayIncomeMap;
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppUser user = ref.watch(userProvider).user(_appStateUid);
    // _selectedAccount =
    //     ref.watch(userProvider.notifier).user.accounts?.firstOrNull;
    return user.accounts != null && user.accounts!.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    alignment: Alignment.center,
                    isExpanded: true,
                    hint: AppText(
                      text: context.localizations.accounts,
                      //  'Accounts',
                      overflow: TextOverflow.ellipsis,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: FaIcon(
                        FontAwesomeIcons.chevronDown,
                        // color: AppColors.neutral900,
                      ),
                      iconSize: 12.0,
                    ),
                    items: user.accounts
                        ?.map((item) => DropdownMenuItem(
                              value: item.name,
                              child: Text(
                                item.name,
                                style: GoogleFonts.manrope(
                                  fontSize: AppSizes.bodySmaller,
                                  fontWeight: FontWeight.w500,
                                  color: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark) ||
                                          ref.watch(themeProvider) == 'Dark'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ))
                        .toList(),
                    value: _selectedAccountName,
                    onChanged: (value) {
                      //to prevent unnecessary redrawing of graphs and listview
                      if (value != _selectedAccountName) {
                        setState(() {
                          _selectedAccountName = value;
                          _selectedAccount = user.accounts?.firstWhere(
                            (element) => element.name == value,
                          );
                          _periodFilter = 1;
                          _reversedTransactions =
                              _selectedAccount?.transactions?.reversed;

                          //income
                          _yearIncomeMap = {};
                          _dayIncomeMap = {};
                          _weekIncomeMap = {};
                          _monthIncomeMap = {};
                          _allIncomeMap = {};
                          _overallYearIncome = 0;
                          _overallWeekIncome = 0;
                          _overallMonthIncome = 0;
                          _overallIncome = 0;

                          //expense
                          _yearExpenseMap = {};
                          _dayExpenseMap = {};
                          _weekExpenseMap = {};
                          _monthExpenseMap = {};
                          _allExpenseMap = {};
                          _overallYearExpense = 0;
                          _overallWeekExpense = 0;
                          _overallMonthExpense = 0;
                          _overallExpense = 0;
                          if (_reversedTransactions != null) {
                            for (final transaction in _reversedTransactions!) {
                              if ((transaction.date.day == _dateTimeNow.day)
                                  //  &&
                                  //     (transaction.date.difference(dateTimeNow) <
                                  //         const Duration(days: 1)
                                  //         )
                                  ) {
                                final hour =
                                    _getTransactionHour(transaction.date);
                                final amount = transaction.amount;
                                final type = transaction.type;
                                if (type == context.localizations.income) {
                                  _dayIncomeMap[hour] = {
                                    _amountString: (_dayIncomeMap[hour]
                                                ?[_amountString] ??
                                            0) +
                                        amount,
                                    _descriptionString: transaction.description
                                  };
                                } else {
                                  _dayExpenseMap[hour] = {
                                    _amountString: _dayExpenseMap[hour]
                                            ?[_amountString] ??
                                        0 + amount,
                                    _descriptionString: transaction.description,
                                    _categoryString: transaction.category,
                                  };
                                }
                              } else {
                                _overallDayIncome = _dayIncomeMap.values.fold(
                                  0,
                                  (previousValue, element) =>
                                      previousValue + element[_amountString],
                                );
                                _overallDayExpense = _dayExpenseMap.values.fold(
                                    0,
                                    (previousValue, element) =>
                                        previousValue + element[_amountString]);
                                break;
                              }
                            }
                          }
                          _transactionsHolder = _dayIncomeMap;

                          _selectedSortBy == context.localizations.sort_by_date;
                          _inIncomeView = true;
                        });
                      }
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
                          // width: 1.0,
                          color: AppColors.neutral300,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 350,
                      elevation: 1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
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
                ),
                const Gap(10),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoSlidingSegmentedControl(
                        backgroundColor: (ref.watch(themeProvider) ==
                                        'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? const Color.fromARGB(255, 32, 25, 33)
                            : Colors.grey.shade100,
                        thumbColor: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        children: {
                          0: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText(
                                  text: 'All',
                                  isWhite: _periodFilter == 0 ? true : false,
                                ),
                                const Gap(4),
                                FaIcon(
                                  Icons.cloud_outlined,
                                  color: _periodFilter == 0
                                      ? Colors.white
                                      : Colors.black,
                                  size: 12,
                                )
                              ]),
                          1: AppText(
                            text: context.localizations.day,
                            //  'Day',
                            isWhite: _periodFilter == 1 ? true : false,
                          ),
                          2: AppText(
                            text: context.localizations.week,
                            //  'Week',
                            isWhite: _periodFilter == 2 ? true : false,
                          ),
                          3: AppText(
                            text: context.localizations.month,
                            // 'Month',
                            isWhite: _periodFilter == 3 ? true : false,
                          ),
                          4: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppText(
                                  text: context.localizations.year,
                                  // 'Year',
                                  isWhite: _periodFilter == 4 ? true : false,
                                ),
                                const Gap(4),
                                FaIcon(
                                  Icons.cloud_outlined,
                                  color: _periodFilter == 4
                                      ? Colors.white
                                      : Colors.black,
                                  size: 12,
                                )
                              ])
                        },
                        groupValue: _periodFilter,
                        onValueChanged: (value) {
                          setState(() {
                            _periodFilter = value;
                            if (value == 1) {
                              if (_dayIncomeMap.isEmpty &&
                                  _dayExpenseMap.isEmpty) {
                                if (_reversedTransactions != null) {
                                  for (final transaction
                                      in _reversedTransactions!) {
                                    if (transaction.date.day ==
                                        _dateTimeNow.day) {
                                      final hour =
                                          _getTransactionHour(transaction.date);
                                      final amount = transaction.amount;
                                      final type = transaction.type;
                                      if (type ==
                                          context.localizations.income) {
                                        _dayIncomeMap[hour] = {
                                          _amountString: (_dayIncomeMap[hour]
                                                      ?[_amountString] ??
                                                  0) +
                                              amount,
                                          _descriptionString:
                                              transaction.description
                                        };
                                      } else {
                                        _dayExpenseMap[hour] = {
                                          _amountString: _dayExpenseMap[hour]
                                                  ?[_amountString] ??
                                              0 + amount,
                                          _descriptionString:
                                              transaction.description,
                                          _categoryString: transaction.category,
                                        };
                                      }
                                    } else {
                                      _overallDayIncome =
                                          _dayIncomeMap.values.fold(
                                        0,
                                        (previousValue, element) =>
                                            previousValue +
                                            element[_amountString],
                                      );
                                      _overallDayExpense = _dayExpenseMap.values
                                          .fold(
                                              0,
                                              (previousValue, element) =>
                                                  previousValue +
                                                  element[_amountString]);
                                      break;
                                    }
                                  }
                                }
                              }

                              if (_inIncomeView) {
                                _transactionsHolder = _dayIncomeMap;
                              } else {
                                _transactionsHolder = _dayExpenseMap;
                              }
                            } else if (value == 2) {
                              if (_weekIncomeMap.isEmpty &&
                                  _weekExpenseMap.isEmpty) {
                                if (_reversedTransactions != null) {
                                  for (final transaction
                                      in _reversedTransactions!) {
                                    if (
                                        // (transaction.date.day == dateTimeNow.day) &&
                                        (transaction.date
                                                .difference(_dateTimeNow) <
                                            const Duration(days: 7))) {
                                      final day = _getTransactionDay(
                                          transaction.date, context);
                                      final amount = transaction.amount;
                                      final type = transaction.type;
                                      if (type == 'Income') {
                                        _weekIncomeMap[day] = {
                                          _amountString: (_weekIncomeMap[day]
                                                      ?[_amountString] ??
                                                  0) +
                                              amount,
                                          _descriptionString:
                                              transaction.description
                                        };
                                      } else {
                                        _weekExpenseMap[day] = {
                                          _amountString: _weekExpenseMap[day]
                                                  ?[_amountString] ??
                                              0 + amount,
                                          _descriptionString:
                                              transaction.description,
                                          _categoryString: transaction.category,
                                        };
                                      }
                                      if (transaction ==
                                          _reversedTransactions?.last) {
                                        _overallWeekIncome =
                                            _weekIncomeMap.values.fold(
                                          0,
                                          (previousValue, element) =>
                                              previousValue +
                                              element[_amountString],
                                        );
                                        _overallWeekExpense =
                                            _weekExpenseMap.values.fold(
                                                0,
                                                (previousValue, element) =>
                                                    previousValue +
                                                    element[_amountString]);
                                      }
                                    } else {
                                      _overallWeekIncome =
                                          _weekIncomeMap.values.fold(
                                        0,
                                        (previousValue, element) =>
                                            previousValue +
                                            element[_amountString],
                                      );
                                      _overallWeekExpense =
                                          _weekExpenseMap.values.fold(
                                              0,
                                              (previousValue, element) =>
                                                  previousValue +
                                                  element[_amountString]);
                                      break;
                                    }
                                  }
                                }
                              }
                              if (_inIncomeView) {
                                _transactionsHolder = _weekIncomeMap;
                              } else {
                                _transactionsHolder = _weekExpenseMap;
                              }
                            } else if (value == 3) {
                              if (_monthIncomeMap.isEmpty &&
                                  _monthExpenseMap.isEmpty) {
                                if (_reversedTransactions != null) {
                                  for (final transaction
                                      in _reversedTransactions!) {
                                    if (transaction.date.month ==
                                        _dateTimeNow.month) {
                                      final week = _getTransactionWeek(
                                          transaction.date, context);
                                      final amount = transaction.amount;
                                      final type = transaction.type;
                                      if (type == 'Income') {
                                        _monthIncomeMap[week] = {
                                          _amountString: (_monthIncomeMap[week]
                                                      ?[_amountString] ??
                                                  0) +
                                              amount,
                                          _descriptionString:
                                              transaction.description
                                        };
                                      } else {
                                        _monthExpenseMap[week] = {
                                          _amountString: _monthExpenseMap[week]
                                                  ?[_amountString] ??
                                              0 + amount,
                                          _descriptionString:
                                              transaction.description,
                                          _categoryString: transaction.category,
                                        };
                                      }
                                      if (transaction ==
                                          _reversedTransactions?.last) {
                                        _overallMonthIncome =
                                            _monthIncomeMap.values.fold(
                                          0,
                                          (previousValue, element) =>
                                              previousValue +
                                              element[_amountString],
                                        );
                                        _overallMonthExpense =
                                            _monthExpenseMap.values.fold(
                                                0,
                                                (previousValue, element) =>
                                                    previousValue +
                                                    element[_amountString]);
                                      }
                                    } else {
                                      _overallMonthIncome =
                                          _monthIncomeMap.values.fold(
                                        0,
                                        (previousValue, element) =>
                                            previousValue +
                                            element[_amountString],
                                      );
                                      _overallMonthExpense =
                                          _monthExpenseMap.values.fold(
                                              0,
                                              (previousValue, element) =>
                                                  previousValue +
                                                  element[_amountString]);
                                      break;
                                    }
                                  }
                                }
                              }
                              if (_inIncomeView) {
                                // _transactionsList =
                                //     _monthIncomeMap.entries.toList();
                                _transactionsHolder = _monthIncomeMap;
                              } else {
                                // _transactionsList =
                                //     _monthExpenseMap.entries.toList();
                                _transactionsHolder = _monthExpenseMap;
                              }
                            } else if (_periodFilter == 4) {
                              if (_yearIncomeMap.isEmpty &&
                                  _yearExpenseMap.isEmpty) {
                                if (_reversedTransactions != null) {
                                  for (final transaction
                                      in _reversedTransactions!) {
                                    if ((transaction.date.month ==
                                            _dateTimeNow.month)
                                        //this part may not be needed as transactions are stored in order
                                        //so the for loop will break on the first instance where month != month
                                        //...so it won't have the chance to process transactions where year != year
                                        &&
                                        (transaction.date.year ==
                                            _dateTimeNow.year)) {
                                      final month = _getTransactionMonth(
                                          context, transaction.date);
                                      final amount = transaction.amount;
                                      final type = transaction.type;
                                      if (type == 'Income') {
                                        _yearIncomeMap[month.toString()] = {
                                          _amountString:
                                              (_yearIncomeMap[month.toString()]
                                                          ?[_amountString] ??
                                                      0) +
                                                  amount,
                                          _descriptionString:
                                              transaction.description
                                        };
                                      } else {
                                        _yearExpenseMap[month.toString()] = {
                                          _amountString:
                                              _yearExpenseMap[month.toString()]
                                                      ?[_amountString] ??
                                                  0 + amount,
                                          _descriptionString:
                                              transaction.description,
                                          _categoryString: transaction.category,
                                        };
                                      }
                                      if (transaction ==
                                          _reversedTransactions?.last) {
                                        _overallYearIncome =
                                            _yearIncomeMap.values.fold(
                                          0,
                                          (previousValue, element) =>
                                              previousValue +
                                              element[_amountString],
                                        );
                                        _overallYearExpense =
                                            _yearExpenseMap.values.fold(
                                                0,
                                                (previousValue, element) =>
                                                    previousValue +
                                                    element[_amountString]);
                                      }
                                    } else {
                                      _overallYearIncome =
                                          _yearIncomeMap.values.fold(
                                        0,
                                        (previousValue, element) =>
                                            previousValue +
                                            element[_amountString],
                                      );
                                      _overallYearExpense =
                                          _yearExpenseMap.values.fold(
                                              0,
                                              (previousValue, element) =>
                                                  previousValue +
                                                  element[_amountString]);
                                      break;
                                    }
                                  }
                                }
                              }
                              if (_inIncomeView) {
                                _transactionsHolder = _yearIncomeMap;
                              } else {
                                _transactionsHolder = _yearExpenseMap;
                              }
                            } else if (_periodFilter == 0) {
                              if (_allIncomeMap.isEmpty &&
                                  _allExpenseMap.isEmpty) {
                                if (_reversedTransactions != null) {
                                  for (final transaction
                                      in _reversedTransactions!) {
                                    if (transaction.date.year ==
                                        _dateTimeNow.year) {
                                      final year =
                                          transaction.date.year.toString();
                                      final amount = transaction.amount;
                                      final type = transaction.type;
                                      if (type == 'Income') {
                                        _allIncomeMap[year] = {
                                          _amountString: (_allIncomeMap[year]
                                                      ?[_amountString] ??
                                                  0) +
                                              amount,
                                          _descriptionString:
                                              transaction.description
                                        };
                                      } else {
                                        _allExpenseMap[year] = {
                                          _amountString: _allExpenseMap[year]
                                                  ?[_amountString] ??
                                              0 + amount,
                                          _descriptionString:
                                              transaction.description,
                                          _categoryString: transaction.category,
                                        };
                                      }
                                      if (transaction ==
                                          _reversedTransactions?.last) {
                                        _overallIncome =
                                            _allIncomeMap.values.fold(
                                          0,
                                          (previousValue, element) =>
                                              previousValue +
                                              element[_amountString],
                                        );
                                        _overallExpense = _allExpenseMap.values
                                            .fold(
                                                0,
                                                (previousValue, element) =>
                                                    previousValue +
                                                    element[_amountString]);
                                      }
                                    } else {
                                      _overallIncome =
                                          _allIncomeMap.values.fold(
                                        0,
                                        (previousValue, element) =>
                                            previousValue +
                                            element[_amountString],
                                      );
                                      _overallExpense = _allExpenseMap.values
                                          .fold(
                                              0,
                                              (previousValue, element) =>
                                                  previousValue +
                                                  element[_amountString]);
                                      break;
                                    }
                                  }
                                }
                              }
                              if (_inIncomeView) {
                                _transactionsHolder = _allIncomeMap;
                              } else {
                                _transactionsHolder = _allExpenseMap;
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const Gap(10),

                // Consumer(builder: (context, ref, child) {
                // final account = ref.watch(userProvider).user.accounts?.firstWhere(
                //       (element) => element.name == _selectedAccount?.name,
                //     );
                // return
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: _inIncomeView
                                          ? ((ref.watch(themeProvider) ==
                                                      'System') &&
                                                  (MediaQuery
                                                          .platformBrightnessOf(
                                                              context) ==
                                                      Brightness.dark))
                                              ? AppColors.primaryDark
                                              : AppColors.primary
                                          : AppColors.neutral100),
                                  borderRadius: BorderRadius.circular(20))),
                          onPressed: () {
                            if (!_inIncomeView) {
                              setState(() {
                                _inIncomeView = true;
                                if (_periodFilter == 0) {
                                  _transactionsHolder = _allIncomeMap;
                                } else if (_periodFilter == 1) {
                                  _transactionsHolder = _dayIncomeMap;
                                } else if (_periodFilter == 2) {
                                  _transactionsHolder = _weekIncomeMap;
                                } else if (_periodFilter == 3) {
                                  _transactionsHolder = _monthIncomeMap;
                                } else {
                                  _transactionsHolder = _yearIncomeMap;
                                }
                              });
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Iconsax.arrow_down,
                                    color: AppColors.neutral500,
                                    size: 15,
                                  ),
                                  AppText(
                                    text: context.localizations.income,
                                    // 'Income',
                                    color: AppColors.neutral500,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText(
                                    text:
                                        //use to test for reactivity
                                        // '${account?.balance} +${_periodFilter == 0 ? _overallIncome : _periodFilter == 1 ? _overallDayIncome : _periodFilter == 2 ? _overallWeekIncome : _periodFilter == 3 ? _overallMonthIncome : _overallYearIncome} ${_selectedAccount?.currency ?? 'GHS'}',
                                        '+${_periodFilter == 0 ? _overallIncome : _periodFilter == 1 ? _overallDayIncome : _periodFilter == 2 ? _overallWeekIncome : _periodFilter == 3 ? _overallMonthIncome : _overallYearIncome} ${_selectedAccount?.currency ?? 'GHS'}',
                                    size: AppSizes.heading5,
                                    color: Colors.green,
                                    weight: FontWeight.w500,
                                  ),
                                ],
                              )
                            ],
                          )),
                    ),
                    const Gap(10),
                    Expanded(
                      child: TextButton(
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: !_inIncomeView
                                          ? ((ref.watch(themeProvider) ==
                                                      'System') &&
                                                  (MediaQuery
                                                          .platformBrightnessOf(
                                                              context) ==
                                                      Brightness.dark))
                                              ? AppColors.primaryDark
                                              : AppColors.primary
                                          : AppColors.neutral100),
                                  borderRadius: BorderRadius.circular(20))),
                          onPressed: () {
                            if (_inIncomeView) {
                              setState(() {
                                _inIncomeView = false;

                                if (_periodFilter == 0) {
                                  _transactionsHolder = _allExpenseMap;
                                } else if (_periodFilter == 1) {
                                  _transactionsHolder = _dayExpenseMap;
                                } else if (_periodFilter == 2) {
                                  _transactionsHolder = _weekExpenseMap;
                                } else if (_periodFilter == 3) {
                                  _transactionsHolder = _monthExpenseMap;
                                } else {
                                  _transactionsHolder = _yearExpenseMap;
                                }
                              });
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Iconsax.arrow_up_3,
                                    size: 15,
                                    color: AppColors.neutral500,
                                  ),
                                  AppText(
                                    text: context.localizations.expenses,
                                    // 'Expenses',
                                    color: AppColors.neutral500,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AppText(
                                    text:
                                        '-${_periodFilter == 0 ? _overallExpense : _periodFilter == 1 ? _overallDayExpense : _periodFilter == 2 ? _overallWeekExpense : _periodFilter == 3 ? _overallMonthExpense : _overallYearExpense} ${_selectedAccount?.currency ?? 'GHS'}',
                                    size: AppSizes.heading5,
                                    color: Colors.red.shade300,
                                    weight: FontWeight.w500,
                                  ),
                                ],
                              )
                            ],
                          )),
                    ),
                  ],
                )
                // ;
                // }
                // )
                ,
                const Gap(10),
                if (_inIncomeView)
                  // if (_transactionsList != null && _transactionsList!.isNotEmpty)
                  if (_transactionsHolder.isNotEmpty)
                    SfCartesianChart(
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      // loadMoreIndicatorBuilder:(context, direction) =>   getLoadMoreViewBuilder(context, direction),
                      primaryXAxis: const CategoryAxis(
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      primaryYAxis: const NumericAxis(
                        majorGridLines: MajorGridLines(width: 0),
                        // minimum: 0,
                        // maximum: 40,
                        // interval: 10,
                      ),
                      series: <CartesianSeries<MapEntry<String, Map>, String>>[
                        ColumnSeries<MapEntry<String, Map>, String>(
                            width: 0.1,
                            dataSource: [
                              ..._transactionsHolder.entries.toList().reversed
                            ],
                            xValueMapper: (MapEntry data, index) => data.key,
                            yValueMapper: (MapEntry data, index) =>
                                data.value[_amountString],
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                            // name: 'Gold',
                            color: Colors.deepPurple[200])
                      ],
                    ),

                if (!_inIncomeView)
                  if (_transactionsHolder.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 170,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              alignment: Alignment.centerRight,
                              hint: AppText(
                                text: context.localizations.sort_by,
                                //  'Sort by',
                                // color: ((ref.watch(themeProvider) == 'System' ||
                                //             ref.watch(themeProvider) ==
                                //                 'Dark') &&
                                //         (MediaQuery.platformBrightnessOf(
                                //                 context) ==
                                //             Brightness.dark))
                                //     ? App
                                //     : AppColors.primary,
                                color: AppColors.neutral300,
                                overflow: TextOverflow.ellipsis,
                              ),
                              iconStyleData: IconStyleData(
                                icon: FaIcon(
                                  FontAwesomeIcons.chevronDown,
                                  color: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark) ||
                                          ref.watch(themeProvider) == 'Dark'
                                      ? AppColors.primaryDark
                                      : AppColors.primary,
                                ),
                                iconSize: 12.0,
                              ),
                              items: [
                                context.localizations.sort_by_date,
                                context.localizations.sort_by_categories,
                                // 'Sort by date',
                                // 'Sort by categories',
                              ]
                                  .map((item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: GoogleFonts.manrope(
                                            fontSize: AppSizes.bodySmaller,
                                            fontWeight: FontWeight.w500,
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
                                        ),
                                      ))
                                  .toList(),
                              value: _selectedSortBy,
                              onChanged: (value) {
                                if (value != _selectedSortBy) {
                                  setState(() {
                                    _selectedSortBy = value;
                                  });
                                }
                              },
                              buttonStyleData: ButtonStyleData(
                                height: AppSizes.dropDownBoxHeight,
                                padding: const EdgeInsets.only(right: 10.0),
                                decoration: BoxDecoration(
                                  color: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark) ||
                                          ref.watch(themeProvider) == 'Dark'
                                      ? const Color.fromARGB(255, 32, 25, 33)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 350,
                                elevation: 1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
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
                          ),
                        ),
                      ],
                    ),
                // const Gap(5),
                if (!_inIncomeView)
                  // if (_transactionsList != null && _transactionsList!.isNotEmpty)
                  if (_transactionsHolder.isNotEmpty)
                    _selectedSortBy == context.localizations.sort_by_categories
                        // 'Sort by categories'
                        ? SfCircularChart(
                            margin: const EdgeInsets.all(0),
                            // tooltipBehavior: TooltipBehavior(enable: true),
                            // annotations: <CircularChartAnnotation>[
                            //   const CircularChartAnnotation(
                            //       angle: 200,
                            //       radius: '80%',
                            //       widget: Text('Circular Chart')),
                            //   const CircularChartAnnotation(
                            //       angle: 60,
                            //       radius: '80%',
                            //       widget: Text('Circular Chart')),
                            //   const CircularChartAnnotation(
                            //       angle: 100,
                            //       radius: '80%',
                            //       widget: Text('Circular Chart')),
                            // ],
                            // backgroundColor: Colors.green,
                            // legend: const Legend(isVisible: true, isResponsive: true),
                            series: <CircularSeries>[
                              DoughnutSeries<MapEntry, String>(
                                enableTooltip: true,
                                // explodeAll: true,
                                groupMode: CircularChartGroupMode.point,
                                groupTo: 3, explode: true, explodeAll: true,
                                explodeOffset: '3%',
                                dataSource:
                                    // List.generate(serviceTypeCounts.length,
                                    //               (index) {
                                    //             String type =
                                    //                 serviceTypeCounts.keys.elementAt(index);
                                    //             Map<String, dynamic> data =
                                    //                 serviceTypeCounts[type]!;
                                    //             int count = data['count'] as int;
                                    //             Color color = data['color'] as Color;

                                    //             return ChartData(type, count, color);
                                    //           }),
                                    [
                                  ..._transactionsHolder.entries,
                                  // ChartData('Jan', 50, Colors.brown),
                                  // ChartData('Feb', 10, Colors.blue),
                                  // ChartData('March', 70, Colors.red),
                                ],
                                xValueMapper: (MapEntry data, _) => data.key,
                                yValueMapper: (MapEntry data, index) =>
                                    data.value[_amountString],
                                pointColorMapper: (MapEntry data, _) =>
                                    getCategoryColor(
                                        data.value[_categoryString].name,
                                        context),
                                innerRadius: '40%',
                                dataLabelSettings: DataLabelSettings(
                                    builder: (data, point, series, pointIndex,
                                            seriesIndex) =>
                                        AppText(
                                          text:
                                              '${(data.value[_amountString] / _periodFilter == 0 ? _overallIncome : _periodFilter == 1 ? _overallDayIncome : _periodFilter == 2 ? _overallWeekIncome : _periodFilter == 3 ? _overallMonthIncome : _overallYearIncome) * 100}%',
                                          size: AppSizes.bodySmall,
                                          color: getCategoryColor(
                                              data.value[_categoryString].name,
                                              context),
                                        ),
                                    // dataLabelSettings:  DataLabelSettings(builder: (data, point, series, pointIndex, seriesIndex) => AppText(text: '${(data/{_selectedAccount!.expenses}) * 100}'),
                                    isVisible: true,
                                    useSeriesColor: true,
                                    connectorLineSettings:
                                        const ConnectorLineSettings(
                                            color: Colors.white),
                                    labelPosition:
                                        ChartDataLabelPosition.outside),
                              ),
                            ],
                          )
                        : SfCartesianChart(
                            borderColor: Colors.transparent,
                            borderWidth: 0,
                            // loadMoreIndicatorBuilder:(context, direction) =>   getLoadMoreViewBuilder(context, direction),
                            primaryXAxis: const CategoryAxis(
                              majorGridLines: MajorGridLines(width: 0),
                            ),
                            primaryYAxis: const NumericAxis(
                              majorGridLines: MajorGridLines(width: 0),
                              // minimum: 0,
                              // maximum: 40,
                              // interval: 10,
                            ),
                            series: <CartesianSeries<MapEntry<String, Map>,
                                String>>[
                              ColumnSeries<MapEntry<String, Map>, String>(
                                  width: 0.1,
                                  dataSource: [
                                    ..._transactionsHolder.entries
                                        .toList()
                                        .reversed
                                  ],
                                  xValueMapper: (MapEntry data, index) =>
                                      data.key,
                                  yValueMapper: (MapEntry data, index) =>
                                      data.value[_amountString],
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      topRight: Radius.circular(5)),
                                  // name: 'Gold',
                                  color: Colors.deepPurple[200])
                            ],
                          ),
                const Gap(5),
                (_transactionsHolder.isNotEmpty)
                    ? Expanded(
                        child: ListView.separated(
                            separatorBuilder: (context, index) => const Gap(5),
                            itemBuilder: (context, index) {
                              final transaction =
                                  _transactionsHolder.entries.elementAt(index);
                              return Container(
                                decoration: BoxDecoration(
                                    color: (ref.watch(themeProvider) ==
                                                    'System' &&
                                                MediaQuery.platformBrightnessOf(
                                                        context) ==
                                                    Brightness.dark) ||
                                            ref.watch(themeProvider) == 'Dark'
                                        ? const Color.fromARGB(255, 39, 32, 39)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  // shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(15)),
                                  // tileColor: Colors.grey.shade100,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width: 50,
                                        color: _inIncomeView
                                            ? ((ref.watch(themeProvider) ==
                                                        'System') &&
                                                    (MediaQuery.platformBrightnessOf(context) ==
                                                        Brightness.dark))
                                                ? AppColors.primaryDark
                                                    .withOpacity(0.1)
                                                : AppColors.primary
                                                    .withOpacity(0.1)
                                            : _selectedSortBy ==
                                                    context.localizations
                                                        .sort_by_date
                                                // 'Sort by date'
                                                ? ((ref.watch(themeProvider) ==
                                                            'System') &&
                                                        (MediaQuery.platformBrightnessOf(
                                                                context) ==
                                                            Brightness.dark))
                                                    ? AppColors.primaryDark
                                                        .withOpacity(0.1)
                                                    : AppColors.primary
                                                        .withOpacity(0.1)
                                                : getCategoryColor(
                                                        transaction
                                                            .value[_categoryString]
                                                            .name,
                                                        context)!
                                                    .withOpacity(0.1),
                                        child: _inIncomeView
                                            ? Icon(
                                                FontAwesomeIcons.coins,
                                                color: ((ref.watch(
                                                                themeProvider) ==
                                                            'System') &&
                                                        (MediaQuery
                                                                .platformBrightnessOf(
                                                                    context) ==
                                                            Brightness.dark))
                                                    ? AppColors.primaryDark
                                                    : AppColors.primary,
                                              )
                                            : Iconify(
                                                transaction
                                                    .value[_categoryString]
                                                    .icon,
                                                color: _selectedSortBy ==
                                                        'Sort by date'
                                                    ? ((ref.watch(themeProvider) ==
                                                                'System') &&
                                                            (MediaQuery.platformBrightnessOf(
                                                                    context) ==
                                                                Brightness
                                                                    .dark))
                                                        ? AppColors.primaryDark
                                                        : AppColors.primary
                                                    : getCategoryColor(
                                                        transaction
                                                            .value[
                                                                _categoryString]
                                                            .name,
                                                        context),
                                              )),
                                  ),
                                  title: AppText(
                                    text: _inIncomeView
                                        ? context.localizations.income
                                        // "Income"
                                        : transaction
                                            .value[_categoryString].name,
                                  ),
                                  subtitle: AppText(
                                    text: transaction.key,
                                    //  (_periodFilter == 1) ?
                                    //     _getTransactionHour(transaction):  (_periodFilter == 2) ? _getTransactionDayFullName(transaction): ? (_periodFilter == 3)? _getTransactionWeek(transaction): (_periodFilter == 4)? _getTransactionMonth(transaction.key): transaction.value[_descriptionString],
                                    color: Colors.grey,
                                  ),
                                  trailing: AppText(
                                    text:
                                        '${_inIncomeView ? '+' : '-'} ${_selectedAccount?.currency ?? 'GHS'} ${transaction.value[_amountString].toString()}',
                                    size: AppSizes.body,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                            itemCount: _transactionsHolder.length),
                      )
                    : Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(AppAssets.noStatistics,
                                  repeat: false,
                                  controller: _animationController,
                                  frameRate: const FrameRate(60),
                                  onLoaded: (composition) {
                                // Configure the AnimationController with the duration of the
                                // Lottie file and start the animation.
                                _animationController
                                  ..duration = _animationController.duration
                                  ..forward();
                              }, height: 180, fit: BoxFit.fill),
                              AppText(
                                  text: _periodFilter == 0
                                      ? _inIncomeView
                                          ? context.localizations.no_incomes
                                          // 'No Incomes'
                                          : context.localizations.no_expenses
                                      //  'No Expenses'
                                      : _inIncomeView
                                          ? context.localizations
                                              .no_incomes_during_this_period
                                          // 'No Incomes during this period.'
                                          : context.localizations
                                              .no_expenses_during_this_period
                                  // 'No Expenses during this period'
                                  ),
                              SizedBox(
                                height: Adaptive.h(20),
                              )
                            ],
                          ),
                        ),
                      )
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      Lottie.asset(AppAssets.noStatistics,
                          repeat: false,
                          controller: _animationController,
                          frameRate: const FrameRate(60),
                          onLoaded: (composition) {
                        // Configure the AnimationController with the duration of the
                        // Lottie file and start the animation.
                        _animationController
                          ..duration = _animationController.duration
                          ..forward();
                      }, height: 180, fit: BoxFit.fill),
                      AppText(text: context.localizations.no_transactions_yet
                          //  'No transactions made yet'
                          ),
                      SizedBox(
                        height: Adaptive.h(10),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Color? getCategoryColor(String name, BuildContext context) {
    if (name == context.localizations.gifts) {
      return Colors.orange[400];
    } else if (name == context.localizations.health) {
      return Colors.green[400];
    } else if (name == context.localizations.car) {
      return Colors.red;
    } else if (name == context.localizations.game) {
      return Colors.teal;
    } else if (name == context.localizations.cafe) {
      return Colors.blueGrey;
    } else if (name == context.localizations.travel) {
      return Colors.brown;
    } else if (name == context.localizations.utility) {
      return Colors.lime[800];
    } else if (name == context.localizations.care) {
      return Colors.pink[400];
    } else if (name == context.localizations.devices) {
      return Colors.blue[100];
    } else if (name == context.localizations.food) {
      return AppColors.primaryDark;
    } else if (name == context.localizations.shopping) {
      return Colors.blue[900];
    } else if (name == context.localizations.transport) {
      return Colors.grey;
    } else {
      return getRandomColor();
    }
  }

  Color getRandomColor() {
    final random = Random();
    final red = random.nextInt(256); // Random value between 0 and 255
    final green = random.nextInt(256);
    final blue = random.nextInt(256);

    return Color.fromARGB(
        255, red, green, blue); // Alpha value set to 255 (fully opaque)
  }

  String _getTransactionHour(DateTime date) {
    switch (date.hour) {
      case < 13:
        return '${date.hour}am';

      default:
        return '${date.hour - 12}pm';
    }
  }

  String _getTransactionDay(DateTime date, BuildContext context) {
    switch (date.weekday) {
      case 1:
        return context.localizations.monday.substring(0, 3);
      case 2:
        return context.localizations.tuesday.substring(0, 3);
      case 3:
        return context.localizations.wednesday.substring(0, 3);
      case 4:
        return context.localizations.thursday.substring(0, 3);
      case 5:
        return context.localizations.friday.substring(0, 3);
      case 6:
        return context.localizations.saturday.substring(0, 3);

      default:
        return context.localizations.sunday.substring(0, 3);
    }
  }

  String _getTransactionDayFullName(String day) {
    switch (day) {
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      case 'Sat':
        return 'Saturday';

      default:
        return 'Sunday';
    }
  }

  String _getTransactionWeek(DateTime date, BuildContext context) {
    switch (date.day) {
      case < 8:
        return context.localizations.week1;
      case > 7 && < 15:
        return context.localizations.week2;
      case > 14 && < 22:
        return context.localizations.week3;
      case > 21 && < 29:
        return context.localizations.week4;

      default:
        return context.localizations.week5;
    }
  }

  String _getTransactionMonth(BuildContext context, DateTime date) {
    switch (date.month) {
      case 1:
        return context.localizations.january.substring(0, 3);
      case 2:
        return context.localizations.february.substring(0, 3);
      case 3:
        return context.localizations.march.substring(0, 3);
      case 4:
        return context.localizations.april.substring(0, 3);
      case 5:
        return context.localizations.may.substring(0, 3);
      case 6:
        return context.localizations.june.substring(0, 3);
      case 7:
        return context.localizations.july.substring(0, 3);
      case 8:
        return context.localizations.august.substring(0, 3);
      case 9:
        return context.localizations.september.substring(0, 3);
      case 10:
        return context.localizations.october.substring(0, 3);
      case 11:
        return context.localizations.november.substring(0, 3);

      default:
        return context.localizations.december.substring(0, 3);
    }
  }

//   Widget getLoadMoreViewBuilder(
//      BuildContext context, ChartSwipeDirection direction) {
//     if (direction == ChartSwipeDirection.end) {
//       return FutureBuilder<String>(
//         future: _updateData(), /// Adding data by updateDataSource method
//         builder:
//          (BuildContext futureContext, AsyncSnapshot<String> snapShot) {
//           return snapShot.connectionState != ConnectionState.done
//               ? const CircularProgressIndicator()
//               : SizedBox.fromSize(size: Size.zero);
//         },
//     );
//     } else {
//       return SizedBox.fromSize(size: Size.zero);
//     }
// }
}
