import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/my_goals/presentation/my_goals_screen.dart';
import 'package:savery/main.dart';

import '../../../app_functions/app_functions.dart';
import '../../my_budgets/presentation/my_expense_budgets_screen.dart';
import '../../my_savings/presentation/my_savings_screen.dart';
import '../../sign_in/user_info/models/user_model.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  DateTime? _dateHolder;

  final List<Budget> _budgets = Hive.box<Budget>(AppBoxes.budgets)
      .values
      .where(
        (element) => element.type == BudgetType.expenseBudget,
      )
      .toList()
      .reversed
      .toList();
  final _user = Hive.box<AppUser>(AppBoxes.user).values.first;

  @override
  void initState() {
    super.initState();
    if (_budgets.isNotEmpty) _dateHolder = _budgets.first.createdAt;
  }

  @override
  Widget build(BuildContext context) {
    // logger.d(Hive.box<Budget>(AppBoxes.budgets).values.map(
    //       (e) => e.type,
    //     ));
    // logger.d(Hive.box<Budget>(AppBoxes.budgets)
    //     .values
    //     .where(
    //       (element) => element.type == BudgetType.expenseBudget,
    //     )
    //     .toList());
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.horizontalPaddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: 'Choose the way you save...',
            size: AppSizes.heading2,
          ),
          const AppText(
            text: 'Plan your own motivation for saving!',
            size: AppSizes.body,
            style: FontStyle.italic,
          ),
          const Gap(10),
          SizedBox(
            height: Adaptive.h(30),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_user.accounts == null ||
                                _user.accounts!.isEmpty) {
                              showInfoToast('Please create an account first',
                                  context: context);
                            } else {
                              navigatorKey.currentState!.push(MaterialPageRoute(
                                builder: (context) => const MyGoalsScreen(),
                              ));
                            }
                          },
                          child: Ink(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 17, left: 17, bottom: 20, top: 4),
                                // width: Adaptive.w(40),
                                color: Colors.pink.shade600,
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.more_horiz,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                    ClipOval(
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        color: Colors.grey.shade100
                                            .withOpacity(0.6),
                                        child: const Icon(
                                          FontAwesomeIcons.paperPlane,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Gap(5),
                                    const AppText(
                                      text: 'My Goals',
                                      isWhite: true,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap(5),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (_user.accounts == null ||
                                _user.accounts!.isEmpty) {
                              showInfoToast('Please create an account first',
                                  context: context);
                            } else {
                              if (_budgets.isNotEmpty) {
                                navigatorKey.currentState!
                                    .push(MaterialPageRoute(
                                  builder: (context) => const MySavingsScreen(),
                                ));
                              } else {
                                showInfoToast(
                                    'Please create an expense budget first',
                                    context: context);
                              }
                            }
                          },
                          child: Ink(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    right: 17, left: 17, bottom: 20, top: 4),
                                // width: Adaptive.w(40),
                                color: const Color.fromARGB(255, 133, 67, 246),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.more_horiz,
                                          color: Colors.white,
                                        )
                                      ],
                                    ),
                                    ClipOval(
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        color: Colors.grey.shade100
                                            .withOpacity(0.6),
                                        child: const Icon(
                                          FontAwesomeIcons.heart,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Gap(5),
                                    const AppText(
                                      text: 'My Savings',
                                      isWhite: true,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (_user.accounts == null || _user.accounts!.isEmpty) {
                        showInfoToast('Please create an account first',
                            context: context);
                      } else {
                        navigatorKey.currentState!.push(MaterialPageRoute(
                          builder: (context) => const MyExpenseBudgetScreen(),
                        ));
                      }
                    },
                    child: Ink(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.only(
                              right: 17, left: 17, bottom: 20, top: 4),
                          // width: Adaptive.w(40),
                          color: AppColors.primary,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      color:
                                          Colors.grey.shade100.withOpacity(0.6),
                                      child: const Icon(
                                        FontAwesomeIcons.listCheck,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Gap(5),
                                  const AppText(
                                    text: 'My Expense Budgets',
                                    isWhite: true,
                                  ),
                                ],
                              ),
                              const SizedBox()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const Gap(20),
          if (_budgets.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: 'Latest added',
                  weight: FontWeight.bold,
                  size: AppSizes.bodySmall,
                ),
                const Gap(5),
                Container(
                  color: Colors.white,
                  child: AppText(
                      text: (DateTime.now().day == _dateHolder?.day)
                          ? 'Today'
                          : (DateTime.now().weekday - _dateHolder!.weekday == 1)
                              ? 'Yesterday'
                              : AppFunctions.formatDate(_dateHolder.toString(),
                                  format: r'g:i A')),
                ),
                const Gap(5),
                // Expanded(
                //   child: ListView.separated(
                //       itemBuilder: (context, index) {
                //         final budget = _budgets[index];

                //         return Container(
                //           padding: const EdgeInsets.symmetric(
                //               vertical: 20, horizontal: 15),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             border: Border.all(
                //               width: 1.0,
                //               color: AppColors.neutral300,
                //             ),
                //           ),
                //           child: Row(
                //             children: [
                //               ClipRRect(
                //                 borderRadius: BorderRadius.circular(10),
                //                 child: Container(
                //                   padding: const EdgeInsets.all(10),
                //                   width: 50,
                //                   color: AppColors.primary.withOpacity(0.1),
                //                   child: (budget.type == BudgetType.savings)
                //                       //TODO: make listview flexible or make it strictly for expense budgets
                //                       //atm _budgets being fetched are of type expense budget. check top of file
                //                       ? const Icon(
                //                           FontAwesomeIcons.paperPlane,
                //                           color: AppColors.primary,
                //                         )
                //                       : (budget.type == BudgetType.goal)
                //                           ? const Icon(
                //                               FontAwesomeIcons.heart,
                //                               color: AppColors.primary,
                //                             )
                //                           : const Icon(
                //                               FontAwesomeIcons.listCheck,
                //                               color: AppColors.primary,
                //                             ),
                //                 ),
                //               ),
                //               const Gap(10),
                //               Expanded(
                //                 child: Column(
                //                   mainAxisAlignment: MainAxisAlignment.start,
                //                   children: [
                //                     Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         AppText(
                //                           text: budget.category!,
                //                           weight: FontWeight.bold,
                //                           size: AppSizes.bodySmall,
                //                         ),
                //                         AppText(text: budget.amount.toString())
                //                       ],
                //                     ),
                //                     budget.type == BudgetType.goal
                //                         ? Column(
                //                             children: [
                //                               Row(
                //                                 children: [
                //                                   Expanded(
                //                                     child: Stack(
                //                                       children: [
                //                                         Container(
                //                                           color: Colors
                //                                               .grey.shade300,
                //                                         ),
                //                                         Container(
                //                                           color: Colors
                //                                               .blue.shade300,
                //                                           width: 40,
                //                                         ),
                //                                       ],
                //                                     ),
                //                                   ),
                //                                 ],
                //                               ),
                //                               const Row(
                //                                 mainAxisAlignment:
                //                                     MainAxisAlignment
                //                                         .spaceBetween,
                //                                 children: [
                //                                   AppText(
                //                                     text: 'saved \$600/20%',
                //                                     color: Colors.green,
                //                                   ),
                //                                   AppText(
                //                                     text: 'left \$2400',
                //                                     color: Colors.red,
                //                                   ),
                //                                 ],
                //                               )
                //                             ],
                //                           )
                //                         : Column(
                //                             children: [
                //                               const Row(
                //                                 mainAxisAlignment:
                //                                     MainAxisAlignment
                //                                         .spaceBetween,
                //                                 children: [
                //                                   AppText(
                //                                     text: '\$435 (43%)',
                //                                     color: Colors.green,
                //                                   ),
                //                                   AppText(
                //                                     text: 'l3/30 day',
                //                                     color: Colors.red,
                //                                   ),
                //                                 ],
                //                               ),
                //                               Row(
                //                                 children: [
                //                                   Expanded(
                //                                     child: Stack(
                //                                       children: [
                //                                         Container(
                //                                           color: Colors
                //                                               .grey.shade300,
                //                                         ),
                //                                         Container(
                //                                           color: Colors
                //                                               .blue.shade300,
                //                                           width: 40,
                //                                         ),
                //                                       ],
                //                                     ),
                //                                   ),
                //                                 ],
                //                               ),
                //                             ],
                //                           ),
                //                   ],
                //                 ),
                //               )
                //             ],
                //           ),
                //         );
                //       },
                //       separatorBuilder: (context, index) {
                //         if (_budgets[index].createdAt.difference(_dateHolder!) >
                //             const Duration(days: 6)) {
                //           // _dateHolder =
                //           //     value.transactions?[index].date;
                //           return Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               const Gap(5),
                //               AppText(
                //                   text: AppFunctions.formatDate(
                //                       _budgets[index].createdAt.toString(),
                //                       format: r'j M Y')),
                //               const Gap(5),
                //             ],
                //           );
                //         } else {
                //           final transactionDay = _budgets[index].createdAt.day;

                //           if (_dateHolder!.day == transactionDay) {
                //             return const Gap(10);
                //           } else {
                //             _dateHolder = _budgets[index].createdAt;
                //             return Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 const Gap(5),
                //                 AppText(
                //                     text: AppFunctions.formatDate(
                //                         _budgets[index].createdAt.toString(),
                //                         format: 'l')),
                //                 const Gap(5),
                //               ],
                //             );
                //           }
                //         }
                //       },
                //       itemCount: 4),
                // )
              ],
            ),
        ],
      ),
    );
  }
}
