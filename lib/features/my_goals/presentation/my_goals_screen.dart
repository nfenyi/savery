import 'package:dotted_border/dotted_border.dart' as d_border;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/main.dart';

import '../../../app_widgets/app_text.dart';
import '../../main_screen/streams/streams.dart';
import '../../sign_in/user_info/models/user_model.dart';

class MyGoalsScreen extends StatefulWidget {
  const MyGoalsScreen({super.key});

  @override
  State<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends State<MyGoalsScreen> {
  String? _selectedAccountName;
  final _accounts = Hive.box<Account>('accounts');
  late final List<String> _accountNames;
  List<Budget>? _goals = [];
  final _formKey = GlobalKey<FormState>();
  final _userBox = Hive.box<AppUser>(AppBoxes.user);
  final _budgetBox = Hive.box<Budget>(AppBoxes.budgets);
  late DateTime _currentDate;

  final _goalNameController = TextEditingController();
  final _goalAmountController = TextEditingController();
  final _goalEstimationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedAccountName = _accounts.values.first.name;
    _accountNames = _accounts.values
        .map(
          (e) => e.name,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    _currentDate = DateTime.now();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const AppText(
          text: 'My Goals',
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
                  setState(() {
                    _selectedAccountName = value;
                    _goals = _accounts.values
                        .firstWhere(
                            (element) => element.name == _selectedAccountName)
                        .budgets
                        ?.where(
                          (element) => element.type == BudgetType.expenseBudget,
                        )
                        .toList();
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: AppSizes.dropDownBoxHeight,
                  padding: const EdgeInsets.only(right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
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
            const Gap(20),
            const AppText(text: 'Savings Bucket'),
            const Gap(5),
            LinearProgressIndicator(
              backgroundColor: AppColors.neutral100,
              borderRadius: BorderRadius.circular(5),
              color: Colors.green,
              value: 0.3,
              minHeight: 10,
            ),
            const Gap(40),
            Ink(
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
                        text: 'Create New Goal',
                        weight: FontWeight.bold,
                        size: AppSizes.heading6,
                      ),
                    ],
                  )),
            ),
            const Gap(30),
            StreamBuilder<List<Budget>>(
                stream: budgetStream(
                    selectedAccount: _selectedAccountName,
                    type: BudgetType.goal),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoader();
                  } else {
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      return Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            InkWell(
                              onTap: () async {
                                final setState = await showCreateBudgetDialog(
                                    context, snapshot.data!);
                                if (setState) {
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
                                  setState(() {
                                    _goals = _userBox.values.first.accounts
                                        ?.firstWhere(
                                          (element) =>
                                              element.name ==
                                              _selectedAccountName,
                                        )
                                        .budgets
                                        ?.where(
                                          (budget) =>
                                              budget.type ==
                                              BudgetType.expenseBudget,
                                        )
                                        .toList();
                                  });
                                }
                                // else {
                                //   logger.d('not in setstate');
                                // }
                              },
                              child: Ink(
                                child: d_border.DottedBorder(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    color: AppColors.primary,
                                    borderType: d_border.BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            const Gap(20),
                            Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const Gap(10),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final expenseBudget = snapshot.data![index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 15),
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
                                            child: const Icon(
                                              FontAwesomeIcons.circleCheck,
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
                                                  // AppText(
                                                  //   text:
                                                  //       expenseBudget.category,
                                                  //   weight: FontWeight.bold,
                                                  //   size: AppSizes.bodySmall,
                                                  // ),
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
                                                      const AppText(
                                                        text: 'Ghc',
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
                                                  const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // AppText(
                                                      //   text:
                                                      //       'GHc${_savingAmounts[index]}  (${((_savingAmounts[index] / expenseBudget.amount) * 100).floor()}%)',
                                                      //   color: Colors.green,
                                                      // ),
                                                      // AppText(
                                                      //   text:
                                                      //       '${expenseBudget.createdAt.difference(_currentDate).inDays}/${expenseBudget.duration} day',
                                                      //   color:
                                                      //       AppColors.primary,
                                                      // ),
                                                    ],
                                                  ),
                                                  const Gap(5),
                                                  SizedBox(
                                                    width: Adaptive.w(70),
                                                    child:
                                                        LinearProgressIndicator(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      color: AppColors.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      value: 0.5,
                                                    ),
                                                  ),
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
                          Lottie.asset(AppAssets.emptyGoalList, height: 200),
                          const AppText(text: 'No goals created yet')
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
          return CupertinoAlertDialog(
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RequiredText('Goal'),
                  const Gap(12),
                  AppTextFormField(
                    controller: _goalNameController,
                    hintText: '50.05',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const Gap(12),
                  const RequiredText('Amount'),
                  const Gap(12),
                  AppTextFormField(
                    controller: _goalAmountController,
                    hintText: '50.05',
                    keyboardType: TextInputType.number,
                    suffixIcon: const AppText(
                      text: 'GHc',
                      color: Colors.grey,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const Gap(12),
                  const RequiredText('Estimated Time'),
                  const Gap(12),
                  AppTextFormField(
                    controller: _goalAmountController,
                    hintText: '30',
                    keyboardType: TextInputType.number,
                    suffixIcon: const AppText(text: 'days', color: Colors.grey),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    navigatorKey.currentState!.pop(true);
                    _goalNameController.clear();
                    _goalAmountController.clear();
                    _goalEstimationController.clear();
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
                    const RequiredText('Bill Amount'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _goalAmountController,
                      hintText: '50.05',
                      keyboardType: TextInputType.number,
                      suffixIcon: const AppText(
                        text: 'GHc',
                        color: Colors.grey,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const Gap(12),
                    const RequiredText('Bill Coverage Duration'),
                    const Gap(12),
                    AppTextFormField(
                      controller: _goalEstimationController,
                      hintText: '50.05',
                      keyboardType: TextInputType.number,
                      suffixIcon: const AppText(
                        text: 'days',
                        color: Colors.grey,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
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
                        amount: double.parse(_goalAmountController.text),
                        type: BudgetType.goal,
                        createdAt: _currentDate,
                        duration: int.parse(_goalEstimationController.text)));

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
                    _goalNameController.clear();
                    _goalAmountController.clear();
                    _goalEstimationController.clear();
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
