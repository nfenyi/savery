import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_functions/app_functions.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart' as widgets;
import 'package:savery/features/new_transaction/models/transaction_category.dart';
import 'package:savery/features/transactions/presentation/transactions_screen.dart';
import 'package:savery/main.dart';

import '../models/account.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<Account> _accounts = [];

  Account? _selectedAccount;
  DateTime? _dateHolder;

  @override
  void initState() {
    super.initState();
    _accounts.add(
      Account(
          name: 'April',
          availableBalance: 2225,
          expenses: 600,
          income: 800,
          transactions: [
            Transaction(
                category: TransactionCategory(
                    icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
                amount: 35,
                createdAt: DateTime.now(),
                description: 'Carrefour Supermarket'),
            Transaction(
                category: TransactionCategory(
                    icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
                amount: 35,
                createdAt: DateTime.now(),
                description: 'Carrefour Supermarket'),
            Transaction(
                category: TransactionCategory(
                    icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
                amount: 35,
                createdAt: DateTime.now(),
                description: 'Carrefour Supermarket'),
            Transaction(
                category: TransactionCategory(
                    icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
                amount: 35,
                createdAt: DateTime.now(),
                description: 'Carrefour Supermarket'),
          ]),
    );
    _accounts.add(Account(
        name: "",
        availableBalance: 0,
        expenses: 0,
        income: 0,
        transactions: []));
    _selectedAccount = _accounts.isEmpty ? null : _accounts.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(20),
        const Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppSizes.horizontalPaddingSmall),
          child: AppText(
            text: 'Accounts',
            size: AppSizes.bodySmall,
            weight: FontWeight.bold,
          ),
        ),
        const Gap(10),
        CarouselSlider.builder(
          itemCount: _accounts.length,
          itemBuilder: (context, index, realIndex) {
            final account = _accounts[index];
            if (index != _accounts.length - 1) {
              return AccountCard(account: account);
            } else {
              return SizedBox(
                width: 380,
                height: 200,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 320,
                      child: AccountCard(
                        account: account,
                      ),
                    ),
                    const Gap(1),
                    DottedBorder(
                        color: AppColors.primary,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        child: const Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle, color: AppColors.primary,
                              // size: 5,
                            ),
                          ],
                        )),
                  ],
                ),
              );
            }
          },
          options: CarouselOptions(
              // enlargeCenterPage: true,
              height: 170,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {},
              viewportFraction: 0.85),
        ),
        const Gap(20),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.horizontalPaddingSmall),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                text: 'Transactions',
                weight: FontWeight.bold,
                size: AppSizes.bodySmall,
              ),
              widgets.AppTextButton(
                  text: 'View All',
                  callback: () {
                    navigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => const TransactionsScreen(),
                    ));
                  })
            ],
          ),
        ),
        AppText(
            text: AppFunctions.formatDate(DateTime.now().toString(),
                format: r'j M Y')),
        const Gap(5),
        (_selectedAccount != null)
            ? SizedBox(
                height: Adaptive.h(40),
                child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.horizontalPaddingSmall),
                    itemBuilder: (context, index) {
                      final transaction = _selectedAccount!.transactions[index];
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
                            color: AppColors.primary.withOpacity(0.1),
                            child: _selectedAccount!
                                        .transactions[index].category.name !=
                                    ''
                                ? Icon(
                                    _selectedAccount!
                                        .transactions[index].category.icon,
                                    color: AppColors.primary,
                                  )
                                : Icon(
                                    _selectedAccount!
                                        .transactions[index].category.icon,
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                        title: AppText(text: transaction.category.name),
                        subtitle: AppText(
                          text: transaction.description,
                          color: Colors.grey,
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(
                                text: '-${transaction.amount.toString()}GHc'),
                            AppText(
                              text: AppFunctions.formatDate(
                                  transaction.createdAt.toString(),
                                  format: r'g:i A'),
                              color: Colors.grey,
                            ),
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
    );
  }
}

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.account,
  });

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color.fromARGB(
            255,
            224,
            6,
            135,
          ),
          AppColors.primary
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
                text: account.name,
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
              const AppText(
                text: 'Available Balance',
                isWhite: true,
              ),
              AppText(
                text: 'GHc ${account.availableBalance.toString()}',
                isWhite: true,
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
                    color: Colors.grey.withOpacity(0.5),
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
                              text: 'GHc ${account.income.toString()}',
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
                    color: Colors.grey.withOpacity(0.5),
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
                              text: 'GHc ${account.expenses.toString()}',
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
