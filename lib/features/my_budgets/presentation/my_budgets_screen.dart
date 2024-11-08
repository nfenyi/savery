import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';

class MyBillsScreen extends ConsumerStatefulWidget {
  const MyBillsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyBillsScreenState();
}

class _MyBillsScreenState extends ConsumerState<MyBillsScreen> {
  final List<Budget> _budgets = [];
  List<Budget> _bills = [];

  @override
  void initState() {
    super.initState();
    _bills = _budgets
        .where(
          (budget) => budget.type == BudgetType.bill,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'My Bills',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
          children: [
            const Gap(30),
            DottedBorder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: AppColors.primary,
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle, color: AppColors.primary,
                      // size: 5,
                    ),
                    Gap(5),
                    AppText(
                      text: 'Create New Bill',
                      weight: FontWeight.bold,
                      size: AppSizes.heading6,
                    ),
                  ],
                )),
            const Gap(20),
            (_bills.isNotEmpty)
                ? Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final bill = _bills[index];
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
                                  child: const Icon(
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
                                      AppText(text: bill.name),
                                      AppText(text: bill.amount.toString())
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                  color: Colors.grey.shade300,
                                                ),
                                                Container(
                                                  color: Colors.blue.shade300,
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
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
