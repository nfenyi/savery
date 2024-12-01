import 'package:dotted_border/dotted_border.dart' as d_border;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/main_screen/presentation/main_screen.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';
import 'package:savery/themes/themes.dart';

import '../../sign_in/user_info/providers/providers.dart';

// import '../../main_screen/streams/streams.dart';

class MyExpenseBudgetScreen extends ConsumerStatefulWidget {
  final Account? account;
  const MyExpenseBudgetScreen({
    this.account,
    super.key,
  });

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

  // final _userBox = Hive.box<AppUser>(AppBoxes.user);
  // final _budgetBox = Hive.box<Budget>(AppBoxes.budgets);
  // late HiveList<Budget> _budgets;
  DateTime _currentDate = DateTime.now();
  String? _selectedAccountName;
  late Account _selectedAccount;
  // final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  final _transactionCategories =
      Hive.box<TransactionCategory>(AppBoxes.transactionsCategories).values;

  late final List<String> _accountNames;

  final Map<String, double> _mappedTransactions = {};
  late String _currency;

  @override
  void initState() {
    super.initState();

    final accounts = ref.read(userProvider).user.accounts;
    _selectedAccount = widget.account ?? accounts!.first;
    _currency = _selectedAccount.currency ?? 'GHS';
    _selectedAccountName = _selectedAccount.name;

    _expenseBudgets = _selectedAccount.budgets
        ?.where(
          (element) => element.type == BudgetType.expenseBudget,
        )
        .toList();

    _accountNames = accounts!
        .map(
          (e) => e.name,
        )
        .toList();

    if (_selectedAccount.transactions != null) {
      for (final transaction in _selectedAccount.transactions!.reversed) {
        late Budget assignedBudget;
        if (transaction.type == 'Expense' &&
            _expenseBudgets != null &&
            _expenseBudgets!.any(
              (element) {
                assignedBudget =
                    element; //will be used if any is true to execute the body
                return element.category!.name == transaction.category!.name;
              },
            )) {
          if (transaction.date.difference(_currentDate).inDays <
              assignedBudget.duration) {
            _mappedTransactions[transaction.category!.name] =
                (_mappedTransactions[transaction.category!.name] ?? 0) +
                    transaction.amount;
          } else {
            break;
          }
          if (assignedBudget.createdAt.difference(_currentDate).inDays !=
              assignedBudget.duration) {
            assignedBudget.createdAt = _currentDate;
            //"these reset after the set duration is past"
            //this is an async function though:
            assignedBudget.save();
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _budgetNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HiveList<Account>? accounts = ref.watch(userProvider).user.accounts;
    _currentDate = DateTime.now();
    List<Budget>? consumerSavingsBudget =
        ref.watch(userProvider).savings(_selectedAccount)?.toList();
    List<Budget>? consumerExpenseBudgets =
        ref.watch(userProvider).expenseBudgets(_selectedAccount)?.toList();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()), (r) {
            return false;
          });
        });
      },
      child: Scaffold(
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (consumerExpenseBudgets == null)
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
                  )),
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
                iconStyleData: IconStyleData(
                  icon: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: ((ref.watch(themeProvider) == 'System' ||
                                ref.watch(themeProvider) == 'Dark') &&
                            (MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark))
                        ? AppColors.primaryDark
                        : AppColors.primary,
                  ),
                  iconSize: 12.0,
                ),
                items: _accountNames
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: AppSizes.bodySmaller,
                              fontWeight: FontWeight.w500,
                              color: ((ref.watch(themeProvider) == 'System') &&
                                      (MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark))
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ))
                    .toList(),
                value: _selectedAccountName,
                onChanged: (value) {
                  if (_selectedAccountName != value) {
                    setState(() {
                      _selectedAccountName = value;
                      _selectedAccount = accounts!.firstWhere(
                          (element) => element.name == _selectedAccountName);
                      _currency = _selectedAccount.currency ?? 'GHS';
                      _expenseBudgets = _selectedAccount.budgets
                          ?.where(
                            (element) =>
                                element.type == BudgetType.expenseBudget,
                          )
                          .toList();

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
                                  return element.category!.name ==
                                      transaction.category!.name;
                                },
                              )) {
                            if (transaction.date
                                    .difference(_currentDate)
                                    .inDays <
                                assignedBudget.duration) {
                              _mappedTransactions[transaction.category!.name] =
                                  (_mappedTransactions[
                                              transaction.category!.name] ??
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
                    color: ((ref.watch(themeProvider) == 'System' ||
                                ref.watch(themeProvider) == 'Dark') &&
                            (MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark))
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
            ),
            const Gap(30),
            InkWell(
              onTap: () async {
                final setState = await showCreateBudgetDialog(
                    context, consumerExpenseBudgets);
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
                  _expenseBudgets = accounts
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
                    color: ((ref.watch(themeProvider) == 'System' ||
                                ref.watch(themeProvider) == 'Dark') &&
                            (MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark))
                        ? AppColors.primaryDark
                        : AppColors.primary,
                    borderType: d_border.BorderType.RRect,
                    radius: const Radius.circular(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: ((ref.watch(themeProvider) == 'System' ||
                                      ref.watch(themeProvider) == 'Dark') &&
                                  (MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark))
                              ? AppColors.primaryDark
                              : AppColors.primary,
                          // size: 5,
                        ),
                        const Gap(5),
                        const AppText(
                          text: 'Create New Budget',
                          weight: FontWeight.bold,
                          size: AppSizes.heading6,
                        ),
                      ],
                    )),
              ),
            ),
            (consumerExpenseBudgets != null &&
                    consumerExpenseBudgets.isNotEmpty)
                ? Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Gap(20),
                        Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) => const Gap(10),
                            itemCount: consumerExpenseBudgets.length,
                            itemBuilder: (context, index) {
                              final expenseBudget =
                                  consumerExpenseBudgets[index];

                              final double value = _mappedTransactions[
                                          expenseBudget.category!.name] !=
                                      null
                                  ? _mappedTransactions[
                                          expenseBudget.category!.name]! /
                                      expenseBudget.amount
                                  : 0;
                              final formattedValue =
                                  (value * 100).toStringAsFixed(1);
                              final savingsFraction =
                                  consumerSavingsBudget![index].amount /
                                      expenseBudget.amount;
                              final savingsRegionWidth = savingsFraction * 70;
                              if (value > 1) {
                                Future.delayed(const Duration(seconds: 3), () {
                                  showInfoToast(
                                      seconds: 5,
                                      'Seems you have gone overbudget for ${expenseBudget.category!.name}. Please increase the ${expenseBudget.category!.name} budget so your balance can be tracked accordingly.',
                                      context: navigatorKey.currentContext!);
                                });
                              }

                              return InkWell(
                                onTap: () async {
                                  await _showUpdateDialog(
                                      context: context, budget: expenseBudget);
                                },
                                child: Ink(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 20,
                                        left: 15,
                                        right: 15,
                                        bottom: consumerSavingsBudget[index]
                                                    .amount !=
                                                0
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: 50,
                                            color: ((ref.watch(themeProvider) ==
                                                        'System') &&
                                                    (MediaQuery
                                                            .platformBrightnessOf(
                                                                context) ==
                                                        Brightness.dark))
                                                ? AppColors.primaryDark
                                                    .withOpacity(0.1)
                                                : AppColors.primary
                                                    .withOpacity(0.1),
                                            child: Iconify(
                                              expenseBudget.category!.icon,
                                              color: ((ref.watch(
                                                              themeProvider) ==
                                                          'System') &&
                                                      (MediaQuery
                                                              .platformBrightnessOf(
                                                                  context) ==
                                                          Brightness.dark))
                                                  ? AppColors.primaryDark
                                                  : AppColors.primary,
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
                                                    text: expenseBudget
                                                        .category!.name,
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
                                                            '$_currency ${_mappedTransactions[expenseBudget.category!.name] ?? 0}  ($formattedValue %)',
                                                        color: Colors.green,
                                                      ),
                                                      AppText(
                                                        text:
                                                            '${expenseBudget.createdAt.difference(_currentDate).inDays + 1}/${expenseBudget.duration} day',
                                                        color: ((ref.watch(
                                                                        themeProvider) ==
                                                                    'System') &&
                                                                (MediaQuery.platformBrightnessOf(
                                                                        context) ==
                                                                    Brightness
                                                                        .dark))
                                                            ? AppColors
                                                                .primaryDark
                                                            : AppColors.primary,
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
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                // Container(
                                                                //   width: Adaptive.w(70 -
                                                                //       savingsRegionWidth),
                                                                //   decoration:
                                                                //       const BoxDecoration(
                                                                //     color: Colors
                                                                //         .transparent,
                                                                //   ),
                                                                // ),
                                                                Container(
                                                                  width: Adaptive.w(
                                                                      savingsRegionWidth),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topRight:
                                                                          Radius.circular(
                                                                              20),
                                                                      bottomRight:
                                                                          Radius.circular(
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
                                                          color: value >= 1
                                                              ? Colors.red
                                                              : AppColors
                                                                  .primary
                                                                  .withOpacity(
                                                                      0.7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          value: value < 1
                                                              ? value
                                                              : 1),
                                                    ]),
                                                  ),
                                                  if (consumerSavingsBudget[
                                                              index]
                                                          .amount !=
                                                      0)
                                                    Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          (value <=
                                                                  (1 -
                                                                      savingsFraction))
                                                              ? const AppText(
                                                                  text:
                                                                      'saving',
                                                                  style: FontStyle
                                                                      .italic,
                                                                  color: Colors
                                                                      .green,
                                                                )
                                                              : const Text('🙁')
                                                        ])
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(AppAssets.emptyList, height: 200),
                      const AppText(text: 'No expense budgets added yet')
                    ],
                  )),
          ]),
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
                          fontWeight: FontWeight.w500,
                          color: ((ref.watch(themeProvider) == 'System') &&
                                  (MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark))
                              ? AppColors.primaryDark
                              : AppColors.primary,
                        ),
                        isExpanded: true,
                        hint: const AppText(
                          text: 'Select a category',
                          overflow: TextOverflow.ellipsis,
                          color: Colors.grey,
                        ),
                        iconStyleData: IconStyleData(
                          icon: FaIcon(
                            FontAwesomeIcons.chevronDown,
                            color: ((ref.watch(themeProvider) == 'System' ||
                                        ref.watch(themeProvider) == 'Dark') &&
                                    (MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark))
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                          iconSize: 12.0,
                        ),
                        items: _transactionCategories
                            .map((item) => DropdownMenuItem(
                                  value: item.name,
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: AppSizes.bodySmaller,
                                      fontWeight: FontWeight.w500,
                                      color: ((ref.watch(themeProvider) ==
                                                  'System') &&
                                              (MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark))
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedCategory,
                        onChanged: (value) {
                          if (expenseBudgets != null) {
                            if (expenseBudgets.any(
                                (element) => element.category!.name == value)) {
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
                            color: ((ref.watch(themeProvider) == 'System' ||
                                        ref.watch(themeProvider) == 'Dark') &&
                                    (MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark))
                                ? const Color.fromARGB(255, 32, 25, 33)
                                : Colors.white,
                            border: Border.all(
                              // width: 1.0,
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
                child: AppText(
                  text: 'OK',
                  color: ((ref.watch(themeProvider) == 'System' ||
                              ref.watch(themeProvider) == 'Dark') &&
                          (MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark))
                      ? AppColors.primaryDark
                      : AppColors.primary,
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
                        iconStyleData: IconStyleData(
                          icon: FaIcon(
                            FontAwesomeIcons.chevronDown,
                            color: ((ref.watch(themeProvider) == 'System' ||
                                        ref.watch(themeProvider) == 'Dark') &&
                                    (MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark))
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                          iconSize: 12.0,
                        ),
                        items: _transactionCategories
                            .map((item) => DropdownMenuItem(
                                  value: item.name,
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: AppSizes.bodySmaller,
                                      fontWeight: FontWeight.w500,
                                      color: ((ref.watch(themeProvider) ==
                                                  'System') &&
                                              (MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark))
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ))
                            .toList(),
                        value: selectedCategory,
                        onChanged: (value) {
                          if (expenseBudgets != null) {
                            if (expenseBudgets.any(
                                (element) => element.category!.name == value)) {
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
                            color: ((ref.watch(themeProvider) == 'System' ||
                                        ref.watch(themeProvider) == 'Dark') &&
                                    (MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark))
                                ? const Color.fromARGB(255, 32, 25, 33)
                                : Colors.white,
                            border: Border.all(
                              // width: 1.0,
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
                    await ref.read(userProvider.notifier).addExpenseBudget(
                        selectedAccount: _selectedAccount,
                        currentDate: _currentDate,
                        selectedCategory: _transactionCategories.firstWhere(
                          (element) => element.name == selectedCategory,
                        ),
                        expenseAmount: _expenseAmountController.text,
                        expenseCoverage: _expenseCoverageController.text);
                    selectedCategory = null;
                    _budgetNameController.clear();
                    _expenseAmountController.clear();
                    _expenseCoverageController.clear();
                    navigatorKey.currentState!.pop();

                    //
                  }
                },
                child: AppText(
                  text: 'OK',
                  color: ((ref.watch(themeProvider) == 'System' ||
                              ref.watch(themeProvider) == 'Dark') &&
                          (MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark))
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<dynamic> _showUpdateDialog(
      {required BuildContext context, required Budget budget}) {
    _expenseAmountController.text =
        budget.amount == 0 ? '' : budget.amount.toString();
    _expenseCoverageController.text = budget.duration.toString();
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            content: StatefulBuilder(builder: (context, setState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const RequiredText('Goal'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _expenseAmountController,
                      hintText: '0.0',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const Gap(12),
                    const RequiredText('Amount'),
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
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const Gap(12),
                    const RequiredText('Estimated Date'),
                    const Gap(12),
                  ],
                ),
              );
            }),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {}
                },
                child: AppText(
                  text: 'Update',
                  color: ((ref.watch(themeProvider) == 'System' ||
                              ref.watch(themeProvider) == 'Dark') &&
                          (MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark))
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          );
        } else {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            content: StatefulBuilder(
              builder: (context, setState) => Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          text: budget.category!.name,
                          size: AppSizes.bodySmaller,
                          weight: FontWeight.bold,
                        ),
                        InkWell(
                          onTap: () async => await _showDeleteDialog(budget),
                          child: Ink(
                            //wrapping with a bigger sizedbox to make the delete button easier to tap
                            child: const SizedBox(
                              width: 18,
                              child: Icon(
                                FontAwesomeIcons.trashCan,
                                color: Colors.red,
                                size: 15,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Gap(20),
                    const RequiredText('Expense Amount'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _expenseAmountController,
                      hintText: '0.0',
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
                    await ref.read(userProvider.notifier).updateExpenseBudget(
                        selectedAccount: _selectedAccount,
                        budget: budget,
                        newDuration: int.parse(_expenseCoverageController.text),
                        parsedAmount:
                            double.parse(_expenseAmountController.text));

                    navigatorKey.currentState!.pop();
                  }
                },
                child: AppText(
                  text: 'Update',
                  color: ((ref.watch(themeProvider) == 'System' ||
                              ref.watch(themeProvider) == 'Dark') &&
                          (MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark))
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _showDeleteDialog(Budget budget) async {
    await showAppInfoDialog(
      context,
      ref,
      title:
          'Are you sure you want to delete this ${budget.category!.name} budget?',
      confirmText: 'No',
      cancelText: 'Yes',
      cancelCallbackFunction: () async {
        await ref.read(userProvider.notifier).deleteExpenseBudget(
            budget: budget, selectedAccount: _selectedAccount);
        navigatorKey.currentState!.pop();
        navigatorKey.currentState!.pop();
      },
    );
  }
}
