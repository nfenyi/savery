import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/features/my_budgets/presentation/my_expense_budgets_screen.dart';
import 'package:savery/features/my_goals/presentation/my_goals_screen.dart';
import 'package:savery/features/sign_in/user_info/providers/providers.dart';
import 'package:savery/main.dart';
import 'package:savery/themes/themes.dart';

import '../../../app_constants/app_sizes.dart';
import '../../../app_widgets/app_text.dart';
import '../../sign_in/user_info/models/user_model.dart';

class AccountCard extends ConsumerWidget {
  const AccountCard({
    super.key,
    required this.account,
    required this.appStateUid,
  });

  final Account account;
  final String appStateUid;

  @override
  Widget build(BuildContext context, ref) {
    double popupMenuHeight = 15;
    final consumerAccount =
        ref.watch(userProvider).user(appStateUid).accounts!.firstWhere(
              (element) => element.name == account.name,
            );

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: (ref.watch(themeProvider) == 'System' &&
                    MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark) ||
                ref.watch(themeProvider) == 'Dark'
            ? const LinearGradient(colors: [
                Color.fromARGB(255, 172, 84, 136),
                Color.fromARGB(255, 122, 91, 183)
              ])
            : const LinearGradient(colors: [
                Color.fromARGB(255, 224, 130, 186),
                Color.fromARGB(255, 156, 117, 233)
              ]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              AppText(
                text: consumerAccount.name,
                isWhite: true,
                weight: FontWeight.bold,
                size: AppSizes.heading6,
              ),
              const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
          const Gap(5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (consumerAccount.balance >= 0)
                const AppText(
                  text: 'Unbudgeted Balance',
                  isWhite: true,
                ),
              if (consumerAccount.balance < 0)
                const AppText(
                  text: 'Deficit',
                  isWhite: true,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text:
                        '${consumerAccount.currency ?? 'GHS'} ${consumerAccount.balance}',
                    isWhite: true,
                  ),
                  Row(
                    children: [
                      const Gap(10),
                      if (consumerAccount.balance == 0 &&
                          consumerAccount.income != 0)
                        const Text('👍'),
                      if (consumerAccount.balance > 0)
                        PopupMenuButton<int>(
                          color: Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          elevation: 1,

                          // surfaceTintColor: Colors.black.withOpacity(0.05),
                          // color: Colors.black.withOpacity(0.05),
                          offset: Offset.fromDirection(180, -30),
                          onSelected: (value) async {
                            switch (value) {
                              case 0:
                                navigatorKey.currentState!
                                    .push(MaterialPageRoute(
                                  builder: (context) => MyExpenseBudgetScreen(
                                    account: consumerAccount,
                                  ),
                                ));
                                break;
                              default:
                                await ref
                                    .read(userProvider.notifier)
                                    .addBalanceToBucket(
                                        selectedAccount: consumerAccount);
                                break;
                            }
                          },
                          itemBuilder: (context) =>

                              // menuWidth: 150,
                              // menuItemExtent: 40,
                              // blurSize: 0,
                              // blurBackgroundColor:
                              //     Colors.black.withOpacity(0.00000000005),
                              // openWithTap: true,
                              // onPressed: () {},
                              [
                            PopupMenuItem<int>(
                              height: popupMenuHeight,
                              value: 0,
                              child: AppText(
                                text: 'Budget',
                                color: (ref.watch(themeProvider) == 'System' &&
                                            MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark) ||
                                        ref.watch(themeProvider) == 'Dark'
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              height: popupMenuHeight,
                              value: 1,

                              child: const AppText(
                                text: 'Add to Bucket',
                                color: Colors.green,
                              ),
                              // onPressed: () {

                              // },
                            ),
                          ],
                          child: AppText(
                            text: 'Delegate',
                            color: Colors.green[200],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      if (consumerAccount.balance < 0)
                        PopupMenuButton<int>(
                          color: Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          elevation: 1,

                          // surfaceTintColor: Colors.black.withOpacity(0.05),
                          // color: Colors.black.withOpacity(0.05),
                          offset: Offset.fromDirection(180, -30),
                          onSelected: (value) async {
                            switch (value) {
                              case 0:
                                navigatorKey.currentState!
                                    .push(MaterialPageRoute(
                                  builder: (context) => MyExpenseBudgetScreen(
                                    account: consumerAccount,
                                  ),
                                ));
                                break;
                              default:
                                navigatorKey.currentState!
                                    .push(MaterialPageRoute(
                                  builder: (context) => MyGoalsScreen(
                                    account: consumerAccount,
                                  ),
                                ));
                                break;
                            }
                          },
                          itemBuilder: (context) =>

                              // menuWidth: 150,
                              // menuItemExtent: 40,
                              // blurSize: 0,
                              // blurBackgroundColor:
                              //     Colors.black.withOpacity(0.00000000005),
                              // openWithTap: true,
                              // onPressed: () {},
                              [
                            PopupMenuItem<int>(
                              height: popupMenuHeight,
                              value: 0,
                              child: AppText(
                                text: 'Budget',
                                color: (ref.watch(themeProvider) == 'System' &&
                                            MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark) ||
                                        ref.watch(themeProvider) == 'Dark'
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              height: popupMenuHeight,
                              value: 1,

                              child: const AppText(
                                text: 'Goal milestones',
                                color: Colors.green,
                              ),
                              // onPressed: () {

                              // },
                            ),
                          ],

                          child: AppText(
                            text: 'Adjust',
                            color: Colors.red[200],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                    ],
                  ),
                ],
              )
            ],
          ),
          const Gap(25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey.withOpacity(0.35),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            color: Colors.green,
                            child: const FaIcon(
                              Icons.file_download_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Gap(5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              text: 'Income',
                              isWhite: true,
                            ),
                            AppText(
                              text:
                                  '${consumerAccount.currency ?? 'GHS'} ${consumerAccount.income.toString()}',
                              isWhite: true,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.grey.withOpacity(0.35),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            color: Colors.red,
                            child: const FaIcon(
                              Icons.file_upload_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Gap(5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppText(
                              text: 'Expenses',
                              isWhite: true,
                            ),
                            AppText(
                              text:
                                  '${consumerAccount.currency ?? 'GHS'} ${consumerAccount.expenses.toString()}',
                              isWhite: true,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// IconData getCategoryIcon(String? name) {
//   switch (name) {
//     case 'Gifts':
//       return Iconsax.gift;

//     case 'Health':
//       return FontAwesomeIcons.stethoscope;

//     case 'Car':
//       return FontAwesomeIcons.car;
//     case 'Game':
//       return FontAwesomeIcons.chess;
//     case 'Cafe':
//       return FontAwesomeIcons.utensils;

//     case 'Travel':
//       return Iconsax.airplane;
//     case 'Utility':
//       return FontAwesomeIcons.lightbulb;
//     case 'Care':
//       return Icons.face_2;

//     case 'Devices':
//       return FontAwesomeIcons.tv;
//     case 'Food':
//       return FontAwesomeIcons.bowlFood;
//     case 'Shopping':
//       return FontAwesomeIcons.cartShopping;
//     case 'Transport':
//       return Iconsax.truck;

//     default:
//       return FontAwesomeIcons.coins;
//   }
// }
