import 'package:dotted_border/dotted_border.dart' as d_border;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/main_screen/presentation/widgets.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';

import '../../main_screen/streams/streams.dart';

class MyExpenseBudgetScreen extends ConsumerStatefulWidget {
  const MyExpenseBudgetScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MyExpenseBudgetScreenState();
}

class _MyExpenseBudgetScreenState extends ConsumerState<MyExpenseBudgetScreen> {
  List<Budget>? _expenseBudgets = [];

  final _formKey = GlobalKey<FormState>();

  final _budgetNameController = TextEditingController();
  final _expenseAmountController = TextEditingController();
  final _expenseCoverageController = TextEditingController();
  late final Iterable<Account> _accounts;
  final _userBox = Hive.box<AppUser>(AppBoxes.user);
  final _budgetBox = Hive.box<Budget>(AppBoxes.budgets);
  DateTime _currentDate = DateTime.now();
  String? _selectedAccountName;
  late List<double> _savingsAmounts;
  late Account _selectedAccount;
  final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  final _transactionCategories =
      Hive.box<TransactionCategory>(AppBoxes.transactionsCategories).values.map(
            (e) => e.name,
          );

  late final List<String> _accountNames;
  Set<String?>? _categoriess = {};
  final Map<String, double> _mappedTransactions = {};
  late String _currency;

  @override
  void initState() {
    super.initState();
    _accounts = _accountsBox.values;

    _selectedAccount = _accounts.first;
    _currency = _selectedAccount.currency ?? 'GHS';
    _selectedAccountName = _selectedAccount.name;
    _accountNames = _accounts
        .map(
          (e) => e.name,
        )
        .toList();

    _expenseBudgets = _selectedAccount.budgets
        ?.where(
          (element) => element.type == BudgetType.expenseBudget,
        )
        .toList();
    _categoriess = _selectedAccount.transactions?.map(
      (e) {
        if (e.type == 'Expense') {
          return e.category!;
        }
      },
    ).toSet();
    if (_selectedAccount.transactions != null) {
      for (final transaction in _selectedAccount.transactions!.reversed) {
        // if (_categoriess!.contains(transaction.category)) {
        //   _fetchedTransactions.add(transaction);
        // }
        late Budget assignedBudget;
        if (transaction.type == 'Expense' &&
            _expenseBudgets != null &&
            _expenseBudgets!.any(
              (element) {
                assignedBudget =
                    element; //will be used if any is true to execute the body
                return element.category == transaction.category!;
              },
            )) {
          if (transaction.date.difference(_currentDate).inDays <
              assignedBudget.duration) {
            _mappedTransactions[transaction.category!] =
                (_mappedTransactions[transaction.category] ?? 0) +
                    transaction.amount;
          } else {
            break;
          }
        }
      }
    }
    // if (_categoriess != null) {
    //   for (final category in _categoriess!) {
    //     for (final transaction in _fetchedTransactions) {
    //       _mappedTransactions[transaction.category!] = transaction;
    //     }
    //   }
    // }
  }

  @override
  void dispose() {
    super.dispose();
    _budgetNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentDate = DateTime.now();

    _savingsAmounts = Hive.box<Budget>(AppBoxes.budgets)
        .values
        .where(
          (element) => element.type == BudgetType.savings,
        )
        .map(
          (e) => e.amount,
        )
        .toList();
    // logger.d(_accounts.first.budgets);
    // logger.d(_expenseBudgets);
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'My Expense Budgets',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_budgetBox.values.isEmpty)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.grey[100],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                    Gap(7),
                    AppText(
                      text: 'These reset after the set duration is past',
                      size: AppSizes.bodySmallest,
                      // weight: FontWeight.bold,
                      // style: FontStyle.italic,
                    ),
                  ],
                ),
              ),
            const Gap(10),
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                style: GoogleFonts.manrope(
                  fontSize: AppSizes.bodySmaller,
                  fontWeight:
                      _selectedAccountName == null ? null : FontWeight.bold,
                  color:
                      _selectedAccountName == null ? Colors.grey : Colors.black,
                ),
                isExpanded: true,
                hint: const AppText(
                  text: 'Select an account',
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
                items: _accountNames
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
                value: _selectedAccountName,
                onChanged: (value) {
                  if (_selectedAccountName != value) {
                    setState(() {
                      _selectedAccountName = value;
                      _selectedAccount = _accounts.firstWhere(
                          (element) => element.name == _selectedAccountName);
                      _currency = _selectedAccount.currency ?? 'GHS';
                      _expenseBudgets = _selectedAccount.budgets
                          ?.where(
                            (element) =>
                                element.type == BudgetType.expenseBudget,
                          )
                          .toList();

                      _categoriess = _selectedAccount.transactions?.map(
                        (e) {
                          if (e.type == 'Expense') {
                            return e.category!;
                          }
                        },
                      ).toSet();
                      if (_selectedAccount.transactions != null) {
                        //
                        // for (final transaction
                        //     in _accountsBox.values.first.transactions!) {
                        //   if (_categoriess!.contains(transaction.category)) {
                        //     _fetchedTransactions.add(transaction);
                        //   }
                        // }
                        for (final transaction
                            in _selectedAccount.transactions!.reversed) {
                          // if (_categoriess!.contains(transaction.category)) {
                          //   _fetchedTransactions.add(transaction);
                          // }
                          late Budget assignedBudget;
                          if (transaction.type == 'Expense' &&
                              _expenseBudgets != null &&
                              _expenseBudgets!.any(
                                (element) {
                                  assignedBudget =
                                      element; //will be used if any is true to execute the body
                                  return element.category ==
                                      transaction.category!;
                                },
                              )) {
                            if (transaction.date
                                    .difference(_currentDate)
                                    .inDays <
                                assignedBudget.duration) {
                              _mappedTransactions[transaction.category!] =
                                  (_mappedTransactions[transaction.category] ??
                                          0) +
                                      transaction.amount;
                            } else {
                              break;
                            }
                          }
                        }
                      }
                    });
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
            const Gap(30),
            InkWell(
              onTap: () async {
                final setState =
                    await showCreateBudgetDialog(context, _expenseBudgets);
                if (setState == true) {
                  // logger.d('in setstate');
                  // logger.d('hello');
                  // logger.d(_userBox.values.first.accounts
                  //     ?.firstWhere(
                  //       (element) => element.name == _selectedAccountName,
                  //     )
                  //     .budgets
                  //     ?.where(
                  //       (budget) => budget.type == BudgetType.expenseBudget,
                  //     )
                  //     .toList());
                  //TODO: make page refresh after creating new budget
                  // setState(() {
                  _expenseBudgets = _userBox.values.first.accounts
                      ?.firstWhere(
                        (element) => element.name == _selectedAccountName,
                      )
                      .budgets
                      ?.where(
                        (budget) => budget.type == BudgetType.expenseBudget,
                      )
                      .toList();
                  // });
                }
                // else {
                //   logger.d('not in setstate');
                // }
              },
              child: Ink(
                child: d_border.DottedBorder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: AppColors.primary,
                    borderType: d_border.BorderType.RRect,
                    radius: const Radius.circular(10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                          // size: 5,
                        ),
                        Gap(5),
                        AppText(
                          text: 'Create New Budget',
                          weight: FontWeight.bold,
                          size: AppSizes.heading6,
                        ),
                      ],
                    )),
              ),
            ),
            StreamBuilder<List<Budget>>(
                stream: budgetStream(
                  selectedAccount: _selectedAccountName,
                  type: BudgetType.expenseBudget,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoader();
                  } else {
                    logger.d(snapshot);
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      return Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Gap(20),
                            Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const Gap(10),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final expenseBudget = snapshot.data![index];

                                  final double value = _mappedTransactions[
                                              expenseBudget.category] !=
                                          null
                                      ? _mappedTransactions[
                                              expenseBudget.category]! /
                                          expenseBudget.amount
                                      : 0;
                                  final formattedValue =
                                      (value * 100).toStringAsFixed(1);
                                  final savingsFraction =
                                      _savingsAmounts[index] /
                                          expenseBudget.amount;
                                  final savingsRegionWidth =
                                      ((savingsFraction * 100) * 70) / 100;

                                  return Container(
                                    padding: EdgeInsets.only(
                                        top: 20,
                                        left: 15,
                                        right: 15,
                                        bottom: _savingsAmounts[index] != 0
                                            ? 10
                                            : 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        width: 1.0,
                                        color: AppColors.neutral300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: 50,
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            child: Icon(
                                              getCategoryIcon(
                                                  expenseBudget.category),
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const Gap(10),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  AppText(
                                                    text:
                                                        expenseBudget.category!,
                                                    weight: FontWeight.bold,
                                                    size: AppSizes.bodySmall,
                                                  ),
                                                  Row(
                                                    children: [
                                                      AppText(
                                                        text: expenseBudget
                                                            .amount
                                                            .toString(),
                                                        weight: FontWeight.bold,
                                                        size:
                                                            AppSizes.bodySmall,
                                                      ),
                                                      const Gap(4),
                                                      AppText(
                                                        text: _currency,
                                                        weight: FontWeight.bold,
                                                        size:
                                                            AppSizes.bodySmall,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      AppText(
                                                        text:
                                                            '$_currency ${_mappedTransactions[expenseBudget.category!] ?? 0}  ($formattedValue %)',
                                                        color: Colors.green,
                                                      ),
                                                      AppText(
                                                        text:
                                                            '${expenseBudget.createdAt.difference(_currentDate).inDays + 1}/${expenseBudget.duration} day',
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ],
                                                  ),
                                                  const Gap(5),
                                                  SizedBox(
                                                    width: Adaptive.w(70),
                                                    height: 4,
                                                    child: Stack(children: [
                                                      SizedBox(
                                                          width: Adaptive.w(70),
                                                          child: Row(children: [
                                                            Container(
                                                              width: Adaptive.w(70 -
                                                                  savingsRegionWidth),
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Colors
                                                                    .transparent,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: Adaptive.w(
                                                                  savingsRegionWidth),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          20),
                                                                ),
                                                                color: Colors
                                                                    .yellow
                                                                    .shade900,
                                                              ),
                                                            )
                                                          ])),
                                                      LinearProgressIndicator(
                                                          backgroundColor:
                                                              Colors
                                                                  .grey.shade100
                                                                  .withOpacity(
                                                                      0.5),
                                                          color: AppColors
                                                              .primary
                                                              .withOpacity(0.7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          value: value < 1
                                                              ? value
                                                              : 1),
                                                    ]),
                                                  ),
                                                  if (_savingsAmounts[index] !=
                                                      0)
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          (value <
                                                                  (1 -
                                                                      savingsFraction))
                                                              ? const Text('🙂')
                                                              : const Text('🙁')
                                                        ])
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(AppAssets.emptyList, height: 200),
                          const AppText(text: 'No expense budgets added yet')
                        ],
                      ));
                    }
                  }
                })
          ],
        ),
      ),
    );
  }

  Future<dynamic> showCreateBudgetDialog(
      BuildContext context, List<Budget>? expenseBudgets) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          String? selectedCategory;
          return CupertinoAlertDialog(
            content: StatefulBuilder(
              builder: (context, setState) => Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RequiredText('Category'),
                    const Gap(12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        style: GoogleFonts.manrope(
                          fontSize: AppSizes.bodySmaller,
                          // fontWeight:
                          //     _selectedAccountName == null ? null : FontWeight.bold,
                          color:
                              // selectedCategory == null
                              //     ? Colors.grey :
                              Colors.black,
                        ),
                        isExpanded: true,
                        hint: const AppText(
                          text: 'Select a category',
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
                        items: _transactionCategories
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
                        value: selectedCategory,
                        onChanged: (value) {
                          if (expenseBudgets != null) {
                            if (expenseBudgets
                                .any((element) => element.category == value)) {
                              showInfoToast(
                                  'This category already exists in your list of budgets',
                                  context: context);
                              setState(() {
                                selectedCategory = null;
                              });
                            } else {
                              setState(() {
                                selectedCategory = value;
                              });
                            }
                          } else {
                            setState(() {
                              selectedCategory = value;
                            });
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
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40.0,
                        ),
                      ),
                    ),
                    const Gap(12),
                    const RequiredText('Expense Amount'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _expenseAmountController,
                      hintText: '50.05',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: AppText(
                        text: _currency,
                        color: Colors.grey,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.positiveNumber(),
                      ]),
                    ),
                    const Gap(12),
                    const RequiredText('Expense Coverage Duration'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _expenseCoverageController,
                      hintText: '30',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: const AppText(
                        text: 'days',
                        color: Colors.grey,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.integer(),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    navigatorKey.currentState!.pop(true);
                    _budgetNameController.clear();
                    _expenseAmountController.clear();
                    _expenseCoverageController.clear();
                  }
                },
                child: const AppText(
                  text: 'OK',
                  color: AppColors.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          );
        } else {
          String? selectedCategory;
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            backgroundColor: Colors.white,
            content: StatefulBuilder(
              builder: (context, setState) => Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RequiredText('Category'),
                    const Gap(12),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        style: GoogleFonts.manrope(
                          fontSize: AppSizes.bodySmaller,
                          // fontWeight:
                          //     _selectedAccountName == null ? null : FontWeight.bold,
                          color:
                              // selectedCategory == null
                              //     ? Colors.grey :
                              Colors.black,
                        ),
                        isExpanded: true,
                        hint: const AppText(
                          text: 'Select a category',
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
                        items: _transactionCategories
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
                        value: selectedCategory,
                        onChanged: (value) {
                          if (expenseBudgets != null) {
                            if (expenseBudgets
                                .any((element) => element.category == value)) {
                              showInfoToast(
                                  'This category already exists in your list of budgets',
                                  context: context);
                              setState(() {
                                selectedCategory = null;
                              });
                            } else {
                              setState(() {
                                selectedCategory = value;
                              });
                            }
                          } else {
                            setState(() {
                              selectedCategory = value;
                            });
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
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 40.0,
                        ),
                      ),
                    ),
                    const Gap(12),
                    const RequiredText('Expense Amount'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _expenseAmountController,
                      hintText: '50.05',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: AppText(
                        text: _currency,
                        color: Colors.grey,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.positiveNumber(),
                      ]),
                    ),
                    const Gap(12),
                    const RequiredText('Expense Coverage Duration'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _expenseCoverageController,
                      hintText: '30',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: const AppText(
                        text: 'days',
                        color: Colors.grey,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.integer(),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = _userBox.values.first;

                    await _budgetBox.add(Budget(
                        category: selectedCategory!,
                        amount: double.parse(_expenseAmountController.text),
                        type: BudgetType.expenseBudget,
                        createdAt: _currentDate,
                        duration: int.parse(_expenseCoverageController.text)));

                    await _budgetBox.add(Budget(
                        category: selectedCategory!,
                        amount: 0,
                        createdAt: _currentDate,
                        type: BudgetType.savings,
                        duration: int.parse(_expenseCoverageController.text)));
                    user.accounts
                        ?.firstWhere(
                            (element) => element.name == _selectedAccountName)
                        .budgets = HiveList(_budgetBox);

                    user.accounts
                        ?.firstWhere(
                            (element) => element.name == _selectedAccountName)
                        .budgets
                        ?.addAll(_budgetBox.values);

                    await user.accounts
                        ?.firstWhere(
                            (element) => element.name == _selectedAccountName)
                        .save();

                    // await user.save();
                    selectedCategory = null;
                    _budgetNameController.clear();
                    _expenseAmountController.clear();
                    _expenseCoverageController.clear();
                    navigatorKey.currentState!.pop(true);

                    //
                  }
                },
                child: const AppText(
                  text: 'OK',
                  color: AppColors.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
