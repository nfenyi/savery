import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/main.dart';

import '../../../app_functions/app_functions.dart';
import '../../my_budgets/presentation/my_budgets_screen.dart';
import '../models/account.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  Account? _selectedAccount;

  DateTime _dateHolder = DateTime.now();

  final List<Budget> _budgets = [];

  @override
  Widget build(BuildContext context) {
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
                      navigatorKey.currentState!.push(MaterialPageRoute(
                        builder: (context) => const MyBillsScreen(),
                      ));
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
                                    text: 'My Budgets',
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
          const AppText(
            text: 'Latest added',
            weight: FontWeight.bold,
            size: AppSizes.bodySmall,
          ),
          const Gap(5),
          const AppText(
            text: 'Today',
            color: Colors.grey,
          ),
          const Gap(5),
          (_selectedAccount != null)
              ? SizedBox(
                  height: Adaptive.h(40),
                  child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.horizontalPaddingSmall),
                      itemBuilder: (context, index) {
                        final budget = _budgets[index];

                        return Container(
                          color: Colors.grey,
                          child: Row(
                            // mainAxisAlignment: ,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: 50,
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: (budget.type == BudgetType.savings)
                                      ? const Icon(
                                          FontAwesomeIcons.paperPlane,
                                          color: AppColors.primary,
                                        )
                                      : (budget.type == BudgetType.goal)
                                          ? const Icon(
                                              FontAwesomeIcons.heart,
                                              color: AppColors.primary,
                                            )
                                          : const Icon(
                                              FontAwesomeIcons.listCheck,
                                              color: AppColors.primary,
                                            ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppText(
                                          text:
                                              budget.transactionCategory.name),
                                      AppText(text: budget.amount.toString())
                                    ],
                                  ),
                                  budget.type == BudgetType.goal
                                      ? Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      Container(
                                                        color: Colors
                                                            .blue.shade300,
                                                        width: 40,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AppText(
                                                  text: 'saved \$600/20%',
                                                  color: Colors.green,
                                                ),
                                                AppText(
                                                  text: 'left \$2400',
                                                  color: Colors.red,
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                AppText(
                                                  text: '\$435 (43%)',
                                                  color: Colors.green,
                                                ),
                                                AppText(
                                                  text: 'l3/30 day',
                                                  color: Colors.red,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        color: Colors
                                                            .grey.shade300,
                                                      ),
                                                      Container(
                                                        color: Colors
                                                            .blue.shade300,
                                                        width: 40,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        if (_selectedAccount!.transactions[index].createdAt !=
                            _dateHolder) {
                          _dateHolder =
                              _selectedAccount!.transactions[index].createdAt;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(5),
                              AppText(
                                  text: AppFunctions.formatDate(
                                      _selectedAccount!
                                          .transactions[index].createdAt
                                          .toString(),
                                      format: r'j M Y')),
                              const Gap(5),
                            ],
                          );
                        } else {
                          return const Gap(10);
                        }
                      },
                      itemCount: _selectedAccount!.transactions.length),
                )
              : Container()
        ],
      ),
    );
  }
}
