import 'package:board_datetime_picker/board_datetime_picker.dart';
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
// import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_functions/app_functions.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/main.dart';

import '../../../app_widgets/app_text.dart';
import '../../../themes/themes.dart';
import '../../main_screen/state/localization.dart';
import '../../sign_in/user_info/models/user_model.dart';
import '../../sign_in/user_info/providers/providers.dart';

class MyGoalsScreen extends ConsumerStatefulWidget {
  final Account? account;
  const MyGoalsScreen({this.account, super.key});

  @override
  ConsumerState<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends ConsumerState<MyGoalsScreen> {
  String? _selectedAccountName;
  late final HiveList<Account>? _accounts;

  late final List<String>? _accountNames;
  final _formKey = GlobalKey<FormState>();

  late DateTime _currentDate;
  late Account _selectedAccount;
  late String _currency;
  late double consumerSavingsBucket;
  final _goalNameController = TextEditingController();
  final _goalFundController = TextEditingController();
  late List<ValueNotifier<bool>> _showDaysMoreList;
  late List<ValueNotifier<double>> _goalAmountList;
  final _milestoneController = TextEditingController();
  final _appStateUid = Hive.box(AppBoxes.appState).get('currentUser');

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _accounts = ref.read(userProvider).user(_appStateUid).accounts;
    _selectedAccount = widget.account ?? _accounts!.first;
    _selectedAccountName = _selectedAccount.name;
    _currency = _selectedAccount.currency ?? 'GHS';
    _accountNames = _accounts
        ?.map(
          (e) => e.name,
        )
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.account != null && _selectedAccount.balance < 0) {
        showInfoToast(
            navigatorKey
                .currentContext!.localizations.reduce_milestones_toast_info,
            // 'Reduce some milestones to reduce account deficit',
            context: navigatorKey.currentContext);
      }
    });
  }

  @override
  void dispose() {
    _goalFundController.dispose();
    _goalNameController.dispose();
    _milestoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    consumerSavingsBucket =
        ref.watch(userProvider).savingsBucket(_selectedAccount);
    HiveList<Goal>? consumerGoals =
        ref.watch(userProvider).goals(_selectedAccount);

    _currentDate = DateTime.now();
    _showDaysMoreList = [];
    _goalAmountList = [];
    for (int i = 0; i < (_selectedAccount.goals?.length ?? 0); i++) {
      _showDaysMoreList.add(ValueNotifier(true));
      _goalAmountList
          .add(ValueNotifier(_selectedAccount.goals![i].raisedAmount));
    }
    final double? bucketIndicatorThreshold = consumerGoals?.fold<double>(
        0, (previousValue, element) => previousValue + element.fund);

    // _showDaysMoreList =
    //     List.filled(_selectedAccount.goals?.length ?? 0, ValueNotifier(true));
    return Scaffold(
        appBar: AppBar(
          title: AppText(
            text: context.localizations.my_goals,
            //  'My Goals',
            weight: FontWeight.bold,
            size: AppSizes.bodySmall,
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.horizontalPaddingSmall),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (widget.account == null)
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    alignment: Alignment.center,
                    style: GoogleFonts.manrope(
                      fontSize: AppSizes.bodySmaller,
                      color: _selectedAccountName == null
                          ? Colors.grey
                          : Colors.black,
                    ),
                    isExpanded: true,
                    hint: AppText(
                      text: context.localizations.select_account,
                      // 'Select an account',
                      overflow: TextOverflow.ellipsis,
                      color: Colors.grey,
                    ),
                    iconStyleData: IconStyleData(
                      icon: FaIcon(
                        FontAwesomeIcons.chevronDown,
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                      iconSize: 12.0,
                    ),
                    items: _accountNames
                        ?.map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
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
                      setState(() {
                        _selectedAccountName = value;
                        _selectedAccount = _accounts!.firstWhere(
                          (element) => element.name == _selectedAccountName,
                        );
                        _currency = _selectedAccount.currency ?? 'GHS';
                        consumerGoals = _selectedAccount.goals;
                      });
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
                        borderRadius: BorderRadius.circular(10.0),
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
              const Gap(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      children: [
                        AppText(
                          text: '${context.localizations.savings_bucket}:',
                          // 'Savings Bucket:'
                        ),
                        const Gap(10),
                        AppText(
                            text:
                                '${_selectedAccount.currency ?? 'GHS'} $consumerSavingsBucket'),
                      ],
                    ),
                    const Gap(5),
                    // (consumerGoals != null && consumerGoals!.isNotEmpty)
                    //     ?
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.green,
                      value: (bucketIndicatorThreshold == null ||
                              bucketIndicatorThreshold == 0)
                          ? consumerSavingsBucket / 1000 < 1
                              ? consumerSavingsBucket / 1000
                              : 1
                          : consumerSavingsBucket / bucketIndicatorThreshold < 1
                              ? consumerSavingsBucket / bucketIndicatorThreshold
                              : 1,
                      minHeight: 10,
                      // )
                      // : LinearProgressIndicator(
                      //     backgroundColor: Colors.green.shade100,
                      //     borderRadius: BorderRadius.circular(5),
                      //     value: 0.0,
                      //     minHeight: 10,
                    ),
                    const Gap(40),
                    InkWell(
                      onTap: () async {
                        await showCreateGoalDialog(context, consumerGoals);
                        // if (setState == true) {
                        //   // logger.d('in setstate');
                        //   // logger.d('hello');
                        //   // logger.d(_userBox.values.first.accounts
                        //   //     ?.firstWhere(
                        //   //       (element) => element.name == _selectedAccountName,
                        //   //     )
                        //   //     .budgets
                        //   //     ?.where(
                        //   //       (budget) => budget.type == BudgetType.expenseBudget,
                        //   //     )
                        //   //     .toList());

                        //   setState(() {
                        //     consumerGoals = _user.accounts
                        //         ?.firstWhere(
                        //           (element) =>
                        //               element.name == _selectedAccountName,
                        //         )
                        //         .goals;
                        //   });
                        // }
                        // else {
                        //   logger.d('not in setstate');
                        // }
                      },
                      child: Ink(
                        child: d_border.DottedBorder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            // color: ((ref.watch(themeProvider) == 'System' ||
                            //             ref.watch(themeProvider) == 'Dark') &&
                            //         (MediaQuery.platformBrightnessOf(context) ==
                            //             Brightness.dark))
                            //     ? AppColors.primaryDark
                            //     : AppColors.primary,
                            color: Colors.green,
                            borderType: d_border.BorderType.RRect,
                            radius: const Radius.circular(10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle,
                                  // color:
                                  //     ((ref.watch(themeProvider) == 'System' ||
                                  //                 ref.watch(themeProvider) ==
                                  //                     'Dark') &&
                                  //             (MediaQuery.platformBrightnessOf(
                                  //                     context) ==
                                  //                 Brightness.dark))
                                  //         ? AppColors.primaryDark
                                  //         : AppColors.primary,
                                  color: Colors.green,
                                  // size: 5,
                                ),
                                const Gap(5),
                                AppText(
                                  text: context.localizations.create_new_goal,
                                  // 'Create New Goal',
                                  weight: FontWeight.bold,
                                  size: AppSizes.heading6,
                                ),
                              ],
                            )),
                      ),
                    ),
                    const Gap(20),
                    (consumerGoals != null && consumerGoals!.isNotEmpty)
                        ? Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const Gap(10),
                              itemCount: consumerGoals!.length,
                              itemBuilder: (context, index) {
                                final goal = consumerGoals![index];

                                // final double value =
                                //     _mappedTransactions[goal.category] != null
                                //         ? _mappedTransactions[
                                //                 goal.category]! /
                                //             goal.amount
                                //         : 0;
                                // final formattedValue =
                                //     (value * 100).toStringAsFixed(1);
                                // final savingsFraction =
                                //     _savingsAmounts[index] / goal.amount;
                                // final savingsRegionWidth =
                                //     ((savingsFraction * 100) * 70) / 100;
                                final daysMore = goal.estimatedDate
                                    .difference(_currentDate)
                                    .inDays;
//TODO: add delete and update functionality to container
                                return Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 15),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1.0,
                                            // color: AppColors.neutral300,
                                            color: Colors.green.shade100),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              width: 50,
                                              color: consumerGoals![index]
                                                          .raisedAmount >=
                                                      consumerGoals![index].fund
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : consumerGoals![index]
                                                              .raisedAmount <
                                                          consumerGoals![index]
                                                                  .fund /
                                                              2
                                                      ? Colors.red
                                                          .withOpacity(0.1)
                                                      : Colors.amber
                                                          .withOpacity(0.1),
                                              child: Icon(
                                                FontAwesomeIcons.circleCheck,
                                                color: consumerGoals![index]
                                                            .raisedAmount >=
                                                        consumerGoals![index]
                                                            .fund
                                                    ? Colors.green
                                                    : consumerGoals![index]
                                                                .raisedAmount <
                                                            consumerGoals![
                                                                        index]
                                                                    .fund /
                                                                2
                                                        ? Colors.red
                                                        : Colors.amber,
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
                                                      text: goal.name,
                                                      weight: FontWeight.bold,
                                                      size: AppSizes.bodySmall,
                                                    ),
                                                    Row(
                                                      children: [
                                                        AppText(
                                                          text: goal.fund
                                                              .toString(),
                                                          weight:
                                                              FontWeight.bold,
                                                          size: AppSizes
                                                              .bodySmall,
                                                        ),
                                                        const Gap(4),
                                                        AppText(
                                                          text: _currency,
                                                          weight:
                                                              FontWeight.bold,
                                                          size: AppSizes
                                                              .bodySmall,
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
                                                              '$_currency ${_goalAmountList[index].value}',

                                                          //  ${_mappedTransactions[goal.category!] ?? 0}  ($formattedValue

                                                          color: consumerGoals![
                                                                          index]
                                                                      .raisedAmount >=
                                                                  consumerGoals![
                                                                          index]
                                                                      .fund
                                                              ? Colors.green
                                                              : consumerGoals![
                                                                              index]
                                                                          .raisedAmount <
                                                                      consumerGoals![index]
                                                                              .fund /
                                                                          2
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .amber,
                                                        ),
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                _showDaysMoreList[
                                                                    index],
                                                            builder: (context,
                                                                value, child) {
                                                              return InkWell(
                                                                onTap: () {
                                                                  _showDaysMoreList[
                                                                          index]
                                                                      .value = !_showDaysMoreList[
                                                                          index]
                                                                      .value;
                                                                },
                                                                child: Ink(
                                                                  child:
                                                                      AppText(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    text: value
                                                                        ? '$daysMore ${context.localizations.days_more}'
                                                                        // '$daysMore days more'
                                                                        : AppFunctions.formatDate(
                                                                            goal.estimatedDate
                                                                                .toString(),
                                                                            format:
                                                                                'j M Y'),
                                                                    color: consumerGoals![index].raisedAmount >=
                                                                            consumerGoals![index]
                                                                                .fund
                                                                        ? Colors
                                                                            .green
                                                                        : daysMore <=
                                                                                0
                                                                            ? Colors.red
                                                                            : null,
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ],
                                                    ),
                                                    const Gap(5),
                                                    SizedBox(
                                                      width: Adaptive.w(70),
                                                      child:
                                                          ValueListenableBuilder<
                                                                  double>(
                                                              valueListenable:
                                                                  _goalAmountList[
                                                                      index],
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return LinearProgressIndicator(
                                                                  backgroundColor: Colors
                                                                      .grey
                                                                      .shade100
                                                                      .withOpacity(
                                                                          0.5),
                                                                  color: consumerGoals![index]
                                                                              .raisedAmount >=
                                                                          consumerGoals![index]
                                                                              .fund
                                                                      ? Colors
                                                                          .green
                                                                      : consumerGoals![index].raisedAmount <
                                                                              consumerGoals![index].fund /
                                                                                  2
                                                                          ? Colors
                                                                              .red
                                                                          : Colors
                                                                              .amber,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  value: value /
                                                                              goal
                                                                                  .fund <
                                                                          1
                                                                      ? (value /
                                                                          goal.fund)
                                                                      : 1,
                                                                );
                                                              }),
                                                    ),
                                                    // if (_savingsAmounts[index] !=
                                                    //     0)
                                                    //   Row(
                                                    //       mainAxisAlignment:
                                                    //           MainAxisAlignment
                                                    //               .end,
                                                    //       children: [
                                                    //         (value <
                                                    //                 (1 -
                                                    //                     savingsFraction))
                                                    //             ? const Text('🙂')
                                                    //             : const Text('🙁')
                                                    //       ])
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await _showUpdateDialog(
                                                context: context,
                                                goal: goal,
                                                consumerSavingsBucket:
                                                    consumerSavingsBucket);
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            width: Adaptive.w(68),
                                            height: 90,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset(AppAssets.emptyGoalList,
                                    fit: BoxFit.fitHeight, height: 250),
                                const AppText(text: 'No goals created yet'),
                              ],
                            ),
                          ),
                  ],
                ),
              )
            ])));
  }

  Future<dynamic> showCreateGoalDialog(
      BuildContext context, List<Goal>? goals) {
    //TODO: not using goals param?
    _goalFundController.clear();
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
                    RequiredText(context.localizations.goal
                        // 'Goal'
                        ),
                    const Gap(12),
                    AppTextFormField(
                      controller: _goalNameController,
                      hintText: '50.05',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const Gap(12),
                    RequiredText(context.localizations.amount
                        // 'Amount'
                        ),
                    const Gap(12),
                    AppTextFormField(
                      controller: _goalFundController,
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
                    RequiredText(context.localizations.estimated_date
                        // 'Estimated Date'
                        ),
                    const Gap(12),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          )),
                      child: ListTile(
                        title: Text(
                          _selectedDate == null
                              ? context.localizations.date
                              //  'Date'
                              : AppFunctions.formatDate(
                                  _selectedDate.toString(),
                                  format: 'j M Y, g:i A'),
                          style: GoogleFonts.manrope(
                            fontSize: AppSizes.bodySmaller,
                            // fontWeight:
                            //     _selectedDate == null ? null : FontWeight.bold,
                            color: _selectedDate == null ? Colors.grey : null,
                          ),
                        ),
                        trailing: Icon(
                          FontAwesomeIcons.calendar,
                          color: (ref.watch(themeProvider) == 'System' &&
                                      MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark) ||
                                  ref.watch(themeProvider) == 'Dark'
                              ? AppColors.primaryDark
                              : AppColors.primary,
                          size: 15,
                        ),
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        onTap: () async {
                          await showBoardDateTimePicker(
                            onChanged: (value) {
                              setState(() {
                                _selectedDate = value;
                              });
                            },
                            showDragHandle: true,
                            options: BoardDateTimeOptions(
                              languages: BoardPickerLanguages(
                                  now: context.localizations.now,
                                  today: context.localizations.today,
                                  yesterday: context.localizations.yesterday,
                                  tomorrow: context.localizations.tomorrow,
                                  locale:
                                      ref.watch(languageProvider) == 'Français'
                                          ? 'fr'
                                          : 'en'),
                              activeColor: ((ref.watch(themeProvider) ==
                                              'System' ||
                                          ref.watch(themeProvider) == 'Dark') &&
                                      (MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark))
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              // backgroundColor: Colors.white,
                              foregroundColor: ((ref.watch(themeProvider) ==
                                              'System' ||
                                          ref.watch(themeProvider) == 'Dark') &&
                                      (MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark))
                                  ? const Color.fromARGB(255, 78, 79, 91)
                                  : AppColors.neutral100,
                              // boardTitle: "Select 'TODAY' or '",
                              // boardTitleTextStyle: TextStyle(fontWeight: FontWeight.w400),
                              inputable: false,
                              pickerSubTitles: BoardDateTimeItemTitles(
                                year: context.localizations.year,
                                day: context.localizations.day,
                                hour: context.localizations.hour,
                                minute: context.localizations.minute,
                              ),
                            ),
                            context: context,
                            pickerType: DateTimePickerType.datetime,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
//                     await _goalsBox.add(Goal(
//                         name: _goalNameController.text,
//                         fund: double.parse(_goalFundController.text),
//                         createdAt: _currentDate,
//                         estimatedDate: _selectedDate!));

//                     _selectedAccount.goals = HiveList(_goalsBox);

//                     _selectedAccount.goals?.addAll(_goalsBox.values);

//                     await _selectedAccount.save();
// //TODO: check if this change trickles to the user box without explicitly adding this to the user box
// //and calling the .save() method
//                     // var temp = user.accounts!.firstWhere(
//                     //   (element) => element.name == _selectedAccountName,
//                     // );

//                     _goalNameController.clear();

//                     _selectedDate = null;
//                     navigatorKey.currentState!.pop(true);
                  }
                },
                child: AppText(
                  text: context.localizations.ok,
                  //  'OK',
                  color: (ref.watch(themeProvider) == 'System' &&
                              MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark) ||
                          ref.watch(themeProvider) == 'Dark'
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
                    RequiredText(context.localizations.goal
                        // 'Goal'
                        ),
                    const Gap(12),
                    AppTextFormField(
                      controller: _goalNameController,
                      hintText: context.localizations.goal_hint,
                      // 'New Car, Pay Debt, etc',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const Gap(12),
                    RequiredText(context.localizations.fund
                        // 'Fund'
                        ),
                    const Gap(12),
                    AppTextFormField(
                      controller: _goalFundController,
                      hintText: '10000',
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
                    RequiredText(context.localizations.estimated_date
                        // 'Estimated Date'
                        ),
                    const Gap(12),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          )),
                      child: ListTile(
                        title: Text(
                          _selectedDate == null
                              ? context.localizations.date
                              // 'Date'
                              : AppFunctions.formatDate(
                                  _selectedDate.toString(),
                                  format: 'j M Y, g:i A'),
                          style: GoogleFonts.manrope(
                            fontSize: AppSizes.bodySmaller,
                            // fontWeight:
                            //     _selectedDate == null ? null : FontWeight.bold,
                            color: _selectedDate == null ? Colors.grey : null,
                          ),
                        ),
                        trailing: Icon(
                          FontAwesomeIcons.calendar,
                          color: (ref.watch(themeProvider) == 'System' &&
                                      MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark) ||
                                  ref.watch(themeProvider) == 'Dark'
                              ? AppColors.primaryDark
                              : AppColors.primary,
                          size: 15,
                        ),
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        onTap: () async {
                          await showBoardDateTimePicker(
                            onChanged: (value) {
                              setState(() {
                                _selectedDate = value;
                              });
                            },
                            showDragHandle: true,
                            options: BoardDateTimeOptions(
                              languages: BoardPickerLanguages(
                                  now: context.localizations.now,
                                  today: context.localizations.today,
                                  yesterday: context.localizations.yesterday,
                                  tomorrow: context.localizations.tomorrow,
                                  locale:
                                      ref.watch(languageProvider) == 'Français'
                                          ? 'fr'
                                          : 'en'),
                              activeColor: ((ref.watch(themeProvider) ==
                                              'System' ||
                                          ref.watch(themeProvider) == 'Dark') &&
                                      (MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark))
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              // backgroundColor: Colors.white,
                              foregroundColor: ((ref.watch(themeProvider) ==
                                              'System' ||
                                          ref.watch(themeProvider) == 'Dark') &&
                                      (MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark))
                                  ? const Color.fromARGB(255, 78, 79, 91)
                                  : AppColors.neutral100,
                              // boardTitle: "Select 'TODAY' or '",
                              // boardTitleTextStyle: TextStyle(fontWeight: FontWeight.w400),
                              inputable: false,
                              pickerSubTitles: BoardDateTimeItemTitles(
                                year: context.localizations.year,
                                day: context.localizations.day,
                                hour: context.localizations.hour,
                                minute: context.localizations.minute,
                              ),
                            ),
                            context: context,
                            pickerType: DateTimePickerType.datetime,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await ref.read(userProvider.notifier).addGoal(
                        selectedAccount: _selectedAccount,
                        goalName: _goalNameController.text,
                        goalFund: _goalFundController.text,
                        currentDate: _currentDate,
                        selectedDate: _selectedDate!);
                    _goalNameController.clear();

                    _selectedDate = null;
                    navigatorKey.currentState!.pop(true);

                    //
                  }
                },
                child: AppText(
                  text: context.localizations.ok,
                  //  'OK',
                  color: (ref.watch(themeProvider) == 'System' &&
                              MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark) ||
                          ref.watch(themeProvider) == 'Dark'
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
      {required BuildContext context,
      required Goal goal,
      required double consumerSavingsBucket}) {
    _milestoneController.text =
        goal.raisedAmount != 0 ? goal.raisedAmount.toString() : '';
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
                    RequiredText(
                      context.localizations.goal,
                      // 'Goal'
                    ),
                    const Gap(12),
                    AppTextFormField(
                      controller: _goalNameController,
                      hintText: '50.05',
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                    ),
                    const Gap(12),
                    RequiredText(context.localizations.amount
                        // 'Amount'
                        ),
                    const Gap(12),
                    AppTextFormField(
                      controller: _milestoneController,
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
                    RequiredText(context.localizations.estimated_date
                        // 'Estimated Date'
                        ),
                    const Gap(12),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          )),
                      child: ListTile(
                        title: Text(
                          _selectedDate == null
                              ? context.localizations.date
                              // 'Date'
                              : AppFunctions.formatDate(
                                  _selectedDate.toString(),
                                  format: 'j M Y, g:i A'),
                          style: GoogleFonts.manrope(
                            fontSize: AppSizes.bodySmaller,
                            // fontWeight:
                            //     _selectedDate == null ? null : FontWeight.bold,
                            color: _selectedDate == null ? Colors.grey : null,
                          ),
                        ),
                        trailing: const Icon(
                          FontAwesomeIcons.calendar,
                          // color: AppColors.primary,
                          size: 15,
                        ),
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        onTap: () async {
                          await showBoardDateTimePicker(
                            onChanged: (value) {
                              setState(() {
                                _selectedDate = value;
                              });
                            },
                            showDragHandle: true,
                            options: BoardDateTimeOptions(
                              languages: BoardPickerLanguages(
                                  now: context.localizations.now,
                                  today: context.localizations.today,
                                  yesterday: context.localizations.yesterday,
                                  tomorrow: context.localizations.tomorrow,
                                  locale:
                                      ref.watch(languageProvider) == 'Français'
                                          ? 'fr'
                                          : 'en'),
                              activeColor: ((ref.watch(themeProvider) ==
                                              'System' ||
                                          ref.watch(themeProvider) == 'Dark') &&
                                      (MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark))
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              // backgroundColor: Colors.white,
                              foregroundColor: ((ref.watch(themeProvider) ==
                                              'System' ||
                                          ref.watch(themeProvider) == 'Dark') &&
                                      (MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark))
                                  ? const Color.fromARGB(255, 78, 79, 91)
                                  : AppColors.neutral100,
                              // boardTitle: "Select 'TODAY' or '",
                              // boardTitleTextStyle: TextStyle(fontWeight: FontWeight.w400),
                              inputable: false,
                              pickerSubTitles: BoardDateTimeItemTitles(
                                year: context.localizations.year,
                                day: context.localizations.day,
                                hour: context.localizations.hour,
                                minute: context.localizations.minute,
                              ),
                            ),
                            context: context,
                            pickerType: DateTimePickerType.datetime,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // final user = _userBox.values.first;
                    goal.raisedAmount = goal.raisedAmount +
                        double.parse(_milestoneController.text);
                    await goal.save();
                    // _selectedAccount.goals = HiveList(_goalsBox);

                    // _selectedAccount.goals?.addAll(_goalsBox.values);

                    // await _selectedAccount.save();
//TODO: check if this change trickles to the user box without explicitly adding this to the user box
//and calling the .save() method
                    // var temp = user.accounts!.firstWhere(
                    //   (element) => element.name == _selectedAccountName,
                    // );
                  }
                },
                child: AppText(
                  text: context.localizations.update
                  // 'Update'
                  ,
                  color: (ref.watch(themeProvider) == 'System' &&
                              MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark) ||
                          ref.watch(themeProvider) == 'Dark'
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
                        RequiredText(context.localizations.milestone
                            // 'Milestone'
                            ),
                        InkWell(
                          onTap: () async => await _showDeleteDialog(goal),
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
                    const Gap(25),
                    AppTextFormField(
                      controller: _milestoneController,
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
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // final user = _userBox.values.first;
                    final parsedInput = double.parse(
                        _milestoneController.text != ''
                            ? _milestoneController.text
                            : '0');
                    final double difference =
                        (parsedInput - goal.raisedAmount).abs();
                    if (parsedInput > goal.raisedAmount) {
                      if (consumerSavingsBucket == 0) {
                        showInfoToast(
                            context.localizations.empty_bucket_toast_info,
                            // 'Your savings bucket is currently empty',
                            context: context);
                      } else if (consumerSavingsBucket < difference) {
                        showInfoToast(
                            context.localizations
                                .increment_is_more_than_backet_info,
                            // 'Your increment is more than what the savings bucket can provide',
                            context: context);
                      } else if (consumerSavingsBucket >= difference) {
                        await ref.read(userProvider.notifier).increaseMilestone(
                              goal: goal,
                              parsedInput: parsedInput,
                              difference: difference,
                              selectedAccount: _selectedAccount,
                            );
                      }
                    } else {
                      await ref.read(userProvider.notifier).decreaseMilestone(
                          goal: goal,
                          parsedInput: parsedInput,
                          difference: difference,
                          selectedAccount: _selectedAccount);
                    }
                    navigatorKey.currentState!.pop();
                  }
                },
                child: AppText(
                  text: context.localizations.update,
                  //  'Update',
                  color: (ref.watch(themeProvider) == 'System' &&
                              MediaQuery.platformBrightnessOf(context) ==
                                  Brightness.dark) ||
                          ref.watch(themeProvider) == 'Dark'
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

  Future<void> _showDeleteDialog(Goal goal) async {
    await showAppInfoDialog(
      context,
      ref,
      title: 'Are you sure you want to delete this goal?',
      confirmText: 'Yes',
      cancelText: 'No',
      isWarning: true,
      confirmCallbackFunction: () async {
        await ref
            .read(userProvider.notifier)
            .deleteGoal(goal: goal, selectedAccount: _selectedAccount);
        navigatorKey.currentState!.pop();
        navigatorKey.currentState!.pop();
      },
    );
  }
}
