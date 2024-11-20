import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../app_constants/app_constants.dart';
import '../../sign_in/user_info/models/user_model.dart';
import 'widgets.dart';

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
  Account? _selectedAccount;
  final Box<AppUser> _userBox = Hive.box(AppBoxes.user);

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

  @override
  void initState() {
    super.initState();

    _selectedAccount = _userBox.values.first.accounts?.first;
    _selectedAccountName = _selectedAccount?.name;
    _reversedTransactions = _selectedAccount?.transactions?.reversed;
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    // _periodFiltered = _reversedTransactions;
    {
      if (_reversedTransactions != null) {
        for (final transaction in _reversedTransactions!) {
          if ((transaction.date.day == _dateTimeNow.day)
              //  &&
              //     (transaction.date.difference(dateTimeNow) <
              //         const Duration(days: 1)
              //         )
              ) {
            final hour = _getTransactionHour(transaction);
            final amount = transaction.amount;
            final type = transaction.type;

            if (type == 'Income') {
              _dayIncomeMap[hour] = {
                _amountString:
                    (_dayIncomeMap[hour]?[_amountString] ?? 0) + amount,
                _descriptionString: transaction.description
              };
            } else {
              _dayExpenseMap[hour] = {
                _amountString:
                    _dayExpenseMap[hour]?[transaction.category!] ?? 0 + amount,
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
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.horizontalPaddingSmall),
      child: Visibility(
        visible: _userBox.values.first.accounts != null &&
            _userBox.values.first.accounts!.isNotEmpty,
        replacement: Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: Column(
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    Lottie.asset(AppAssets.noStatistics,
                        repeat: true,
                        controller: _animationController,
                        frameRate: const FrameRate(60),
                        onLoaded: (composition) {
                      // Configure the AnimationController with the duration of the
                      // Lottie file and start the animation.
                      _animationController
                        ..repeat(min: 0.1, max: 0.5)
                        ..duration = _animationController.duration
                        ..repeat(min: 0.1, max: 0.5)
                        ..forward();
                    }, height: 180, fit: BoxFit.fill),
                    const AppText(text: 'No transactions made yet')
                  ],
                ),
              ),
            ],
          ),
        ),
        child: Column(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                alignment: Alignment.center,
                isExpanded: true,
                hint: const AppText(
                  text: 'Accounts',
                  overflow: TextOverflow.ellipsis,
                ),
                iconStyleData: const IconStyleData(
                  icon: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: AppColors.neutral900,
                  ),
                  iconSize: 12.0,
                ),
                items: _userBox.values.first.accounts
                    ?.map(
                      (e) => e.name,
                    )
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: GoogleFonts.manrope(
                              fontSize: AppSizes.bodySmaller,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral900,
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
                      _selectedAccount =
                          _userBox.values.first.accounts?.firstWhere(
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
                            final hour = _getTransactionHour(transaction);
                            final amount = transaction.amount;
                            final type = transaction.type;
                            if (type == 'Income') {
                              _dayIncomeMap[hour] = {
                                _amountString:
                                    (_dayIncomeMap[hour]?[_amountString] ?? 0) +
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

                      _selectedSortBy == 'Sort by date';
                      _inIncomeView = true;
                    });
                  }
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
                      4: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppText(
                              text: 'Year',
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
                          if (_dayIncomeMap.isEmpty && _dayExpenseMap.isEmpty) {
                            if (_reversedTransactions != null) {
                              for (final transaction
                                  in _reversedTransactions!) {
                                if (transaction.date.day == _dateTimeNow.day) {
                                  final hour = _getTransactionHour(transaction);
                                  final amount = transaction.amount;
                                  final type = transaction.type;
                                  if (type == 'Income') {
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
                                  _overallDayIncome = _dayIncomeMap.values.fold(
                                    0,
                                    (previousValue, element) =>
                                        previousValue + element[_amountString],
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
                                    (transaction.date.difference(_dateTimeNow) <
                                        const Duration(days: 7))) {
                                  final day = _getTransactionDay(transaction);
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
                                    _overallWeekExpense = _weekExpenseMap.values
                                        .fold(
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
                                        previousValue + element[_amountString],
                                  );
                                  _overallWeekExpense =
                                      _weekExpenseMap.values
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
                                  final week = _getTransactionWeek(transaction);
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
                                        previousValue + element[_amountString],
                                  );
                                  _overallMonthExpense = _monthExpenseMap.values
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
                                  final month =
                                      _getTransactionMonth(transaction);
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
                                    _overallYearExpense = _yearExpenseMap.values
                                        .fold(
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
                                        previousValue + element[_amountString],
                                  );
                                  _overallYearExpense =
                                      _yearExpenseMap.values
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
                            _transactionsHolder = _yearIncomeMap;
                          } else {
                            _transactionsHolder = _yearExpenseMap;
                          }
                        } else if (_periodFilter == 0) {
                          if (_allIncomeMap.isEmpty && _allExpenseMap.isEmpty) {
                            if (_reversedTransactions != null) {
                              for (final transaction
                                  in _reversedTransactions!) {
                                if (transaction.date.year ==
                                    _dateTimeNow.year) {
                                  final year = transaction.date.year.toString();
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
                                        _monthIncomeMap.values.fold(
                                      0,
                                      (previousValue, element) =>
                                          previousValue +
                                          element[_amountString],
                                    );
                                    _overallExpense = _monthExpenseMap.values
                                        .fold(
                                            0,
                                            (previousValue, element) =>
                                                previousValue +
                                                element[_amountString]);
                                  }
                                } else {
                                  _overallIncome = _allIncomeMap.values.fold(
                                    0,
                                    (previousValue, element) =>
                                        previousValue + element[_amountString],
                                  );
                                  _overallExpense = _allExpenseMap.values.fold(
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
                                      ? AppColors.primary
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
                          const Row(
                            children: [
                              Icon(
                                Iconsax.arrow_down,
                                color: AppColors.neutral500,
                                size: 15,
                              ),
                              AppText(
                                text: 'Income',
                                color: AppColors.neutral500,
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                text:
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
                                      ? AppColors.primary
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
                          const Row(
                            children: [
                              Icon(
                                Iconsax.arrow_up_3,
                                size: 15,
                                color: AppColors.neutral500,
                              ),
                              AppText(
                                text: 'Expenses',
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
            ),
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
                        borderRadius: BorderRadius.circular(10),
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
                          hint: const AppText(
                            text: 'Sort by',
                            color: AppColors.primary,
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
            // const Gap(5),
            if (!_inIncomeView)
              // if (_transactionsList != null && _transactionsList!.isNotEmpty)
              if (_transactionsHolder.isNotEmpty)
                _selectedSortBy == 'Sort by categories'
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
                                getCategoryColor(data.value[_categoryString]),
                            innerRadius: '40%',
                            dataLabelSettings: DataLabelSettings(
                                builder: (data, point, series, pointIndex,
                                        seriesIndex) =>
                                    AppText(
                                      text:
                                          '${(data.value[_amountString] / _periodFilter == 0 ? _overallIncome : _periodFilter == 1 ? _overallDayIncome : _periodFilter == 2 ? _overallWeekIncome : _periodFilter == 3 ? _overallMonthIncome : _overallYearIncome) * 100}%',
                                      size: AppSizes.bodySmall,
                                      color: getCategoryColor(
                                          data.value[_categoryString]),
                                    ),
                                // dataLabelSettings:  DataLabelSettings(builder: (data, point, series, pointIndex, seriesIndex) => AppText(text: '${(data/{_selectedAccount!.expenses}) * 100}'),
                                isVisible: true,
                                useSeriesColor: true,
                                connectorLineSettings:
                                    const ConnectorLineSettings(
                                        color: Colors.white),
                                labelPosition: ChartDataLabelPosition.outside),
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
                                ..._transactionsHolder.entries.toList().reversed
                              ],
                              xValueMapper: (MapEntry data, index) => data.key,
                              yValueMapper: (MapEntry data, index) =>
                                  data.value[_amountString],
                              borderRadius: BorderRadius.circular(10),
                              // name: 'Gold',
                              color: Colors.deepPurple[200])
                        ],
                      ),
            const Gap(5),
            (_transactionsHolder.isNotEmpty)
                ? SizedBox(
                    height: Adaptive.h(22),
                    child: ListView.separated(
                        separatorBuilder: (context, index) => const Gap(5),
                        //TODO: find a better way to implement the implementation of timestamps
                        //and remove cacheExtent property
                        cacheExtent: 1000000,
                        itemBuilder: (context, index) {
                          final transaction =
                              _transactionsHolder.entries.elementAt(index);
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
                                  color: _inIncomeView
                                      ? Colors.green.withOpacity(0.1)
                                      : getCategoryColor(transaction
                                              .value[_categoryString])!
                                          .withOpacity(0.1),
                                  child: Icon(
                                    _inIncomeView
                                        ? FontAwesomeIcons.coins
                                        : getCategoryIcon(
                                            transaction.value[_categoryString]),
                                    color: _inIncomeView
                                        ? Colors.green
                                        : getCategoryColor(
                                            transaction.value[_categoryString]),
                                  )),
                            ),
                            subtitle: AppText(
                              text: _inIncomeView
                                  ? "Income"
                                  : transaction.value[_categoryString],
                              color: Colors.grey,
                            ),
                            title: (_periodFilter == 1)
                                ? AppText(
                                    text: transaction.value[_descriptionString],
                                  )
                                : AppText(
                                    text: _getTransactionDayFullName(
                                        transaction.key),
                                  ),
                            trailing: AppText(
                              text:
                                  '${_inIncomeView ? '+' : '-'} ${_selectedAccount?.currency ?? 'GHS'} ${transaction.value[_amountString].toString()}',
                              size: AppSizes.body,
                              weight: FontWeight.bold,
                            ),
                          );
                        },
                        itemCount: _transactionsHolder.length),
                  )
                : Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Column(
                          // mainAxisSize: MainAxisSize.max,
                          children: [
                            Lottie.asset(AppAssets.noStatistics,
                                repeat: true, controller: _animationController,
                                onLoaded: (composition) {
                              // Configure the AnimationController with the duration of the
                              // Lottie file and start the animation.
                              _animationController
                                ..repeat(min: 0.1, max: 0.5)
                                ..duration = _animationController.duration
                                ..forward();
                            }, height: 180, fit: BoxFit.fill),
                            AppText(
                                text: _periodFilter == 0
                                    ? _inIncomeView
                                        ? 'No Incomes'
                                        : 'No Expenses'
                                    : _inIncomeView
                                        ? 'No Incomes during this period.'
                                        : 'No Expenses during this period'),
                          ],
                        ),
                      ),
                    ],
                  ))
          ],
        ),
      ),
    );
  }

  Color? getCategoryColor(String name) {
    switch (name) {
      case 'Gifts':
        return Colors.orange[400];

      case 'Health':
        return Colors.green[400];
      case 'Car':
        return Colors.red;
      case 'Game':
        return Colors.teal;
      case 'Cafe':
        return Colors.blueGrey;

      case 'Travel':
        return Colors.brown;
      case 'Utility':
        return Colors.lime[800];
      case 'Care':
        return Colors.pink[400];
      case 'Devices':
        return Colors.blue[100];

      case 'Food':
        return AppColors.primary;
      case 'Shopping':
        return Colors.blue[900];
      case 'Transport':
        return Colors.grey;

      default:
        return Colors.black54;
    }
  }

  String _getTransactionHour(AccountTransaction transaction) {
    switch (transaction.date.hour) {
      case < 13:
        return '${transaction.date.hour}am';

      default:
        return '${transaction.date.hour - 12}pm';
    }
  }

  String _getTransactionDay(AccountTransaction transaction) {
    switch (transaction.date.weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';

      default:
        return 'Sun';
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

  String _getTransactionWeek(AccountTransaction transaction) {
    switch (transaction.date.day) {
      case < 8:
        return 'Week 1';
      case > 7 && < 15:
        return 'Week 2';
      case > 14 && < 22:
        return 'Week 3';
      case > 21 && < 29:
        return 'Week 4';

      default:
        return 'Week 5';
    }
  }

  String _getTransactionMonth(AccountTransaction transaction) {
    switch (transaction.date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';

      default:
        return 'Dec';
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
