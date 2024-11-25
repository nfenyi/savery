// import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:lottie/lottie.dart';
// import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
// import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';

import '../../../app_functions/app_functions.dart';
import '../../main_screen/presentation/widgets.dart';
import '../../sign_in/user_info/models/user_model.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  final Account initAccount;
  const TransactionsScreen({required this.initAccount, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  // late String _selectedAccountName;
  // String? _selectedSortBy = 'Sort by date';
  late Account _selectedAccount;
  // final _userBox = Hive.box<AppUser>(AppBoxes.user);
  late List<AccountTransaction>? _reversedTransactions;
  // late List<AccountTransaction>? _transactionsHolder;

  // int? _periodFilter = 1;
  // String _selectedTransactionTypeFilter = 'All';
  final DateTime dateTimeNow = DateTime.now();
  late DateTime? _dateHolder;
  late String? _currency;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.initAccount;
    // _selectedAccountName = _selectedAccount.name;
    _reversedTransactions = _selectedAccount.transactions?.reversed.toList();
    _currency = _selectedAccount.currency ?? 'GHS';
    // _transactionsHolder = _reversedTransactions
    //     ?.where((element) =>
    //         (element.date.day == dateTimeNow.day) &&
    //         (element.date.difference(dateTimeNow) < const Duration(days: 1)))
    //     .toList();
  }

  @override
  Widget build(BuildContext context) {
    _dateHolder = _selectedAccount.transactions?.reversed.first.date;
    //  _selectedAccount = _userBox.values.first.accounts?.first;
    // _selectedAccountName = _selectedAccount.name;
    return Scaffold(
      appBar: AppBar(
        // centerTitle: true,
        title: const AppText(
          text: 'Transactions',
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
            // DropdownButtonHideUnderline(
            //   child: DropdownButton2<String>(
            //     alignment: Alignment.center,
            //     isExpanded: true,
            //     hint: const AppText(
            //       text: 'Accounts',
            //       textAlign: TextAlign.center,

            //       // isFetching ? 'Please wait...' : "Select...",

            //       overflow: TextOverflow.ellipsis,
            //     ),
            //     iconStyleData: const IconStyleData(
            //       icon: FaIcon(
            //         FontAwesomeIcons.chevronDown,
            //         color: AppColors.neutral900,
            //       ),
            //       iconSize: 12.0,
            //     ),
            //     items: _userBox.values.first.accounts!
            //         .map(
            //           (e) => e.name,
            //         )
            //         .map((item) => DropdownMenuItem(
            //               value: item,
            //               child: AppText(
            //                 text: item,
            //                 textAlign: TextAlign.center,
            //                 size: AppSizes.bodySmaller,
            //                 weight: FontWeight.w500,
            //                 color: AppColors.neutral900,
            //               ),
            //             ))
            //         .toList(),
            //     value: _selectedAccountName,
            //     onChanged: (value) {
            //       setState(() {
            //         _selectedAccountName = value!;
            //         _selectedAccount =
            //             _userBox.values.first.accounts!.firstWhere(
            //           (element) => element.name == value,
            //         );

            //         _reversedTransactions =
            //             _selectedAccount.transactions!.reversed;

            //         _transactionsHolder = _reversedTransactions
            //             ?.where((element) =>
            //                 (element.date.day == dateTimeNow.day) &&
            //                 (element.date.difference(dateTimeNow) <
            //                     const Duration(days: 1)))
            //             .toList();
            //         // _periodFilter = 1;
            //         // _selectedTransactionTypeFilter = 'All';
            //       });
            //     },
            //     buttonStyleData: ButtonStyleData(
            //       height: AppSizes.dropDownBoxHeight,
            //       padding: const EdgeInsets.only(right: 10.0),
            //       decoration: BoxDecoration(
            //         color: Colors.grey.shade100,
            //         // border: Border.all(
            //         //   width: 1.0,
            //         //   color: AppColors.neutral300,
            //         // ),
            //         borderRadius: BorderRadius.circular(20.0),
            //       ),
            //     ),
            //     dropdownStyleData: DropdownStyleData(
            //       maxHeight: 350,
            //       elevation: 1,
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(5.0),
            //         color: Colors.white,
            //       ),
            //     ),
            //     menuItemStyleData: const MenuItemStyleData(
            //       height: 40.0,
            //     ),
            //   ),
            // ),
            // const Gap(10),

            AppText(
                textAlign: TextAlign.left,
                text: (DateTime.now().day == _dateHolder?.day)
                    ? 'Today'
                    : (DateTime.now().weekday - _dateHolder!.weekday == 1)
                        ? 'Yesterday'
                        : AppFunctions.formatDate(_dateHolder.toString(),
                            format: r'g:i A')),
            const Gap(10),
            // (_transactionsHolder != null && _transactionsHolder!.isNotEmpty)
            //     ?
            Expanded(
              child: ListView.separated(
                  //TODO: find a better way to implement the implementation of timestamps
                  //and remove cacheExtent property
                  cacheExtent: 1000000,
                  itemBuilder: (context, index) {
                    final transaction = _reversedTransactions![index];
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        // tileColor: Colors.grey.shade100,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              width: 50,
                              color: AppColors.primary.withOpacity(0.1),
                              child: Icon(
                                getCategoryIcon(transaction.category),
                                color: AppColors.primary,
                              )),
                        ),
                        title: AppText(
                            text: transaction.type == 'Income'
                                ? "Income"
                                : transaction.category!),
                        subtitle: AppText(
                          text: transaction.description,
                          color: Colors.grey,
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(
                              text:
                                  '${transaction.type == 'Income' ? '+' : '-'} $_currency ${transaction.amount.toString()}',
                              color: transaction.type == 'Income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            AppText(
                              text: AppFunctions.formatDate(
                                  transaction.date.toString(),
                                  format: r'g:i A'),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    if (_reversedTransactions![index + 1]
                            .date
                            .difference(_dateHolder!) >
                        const Duration(days: 7)) {
                      // _dateHolder =
                      //     value.transactions?[index].date;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(5),
                          AppText(
                              text: AppFunctions.formatDate(
                                  _reversedTransactions![index + 1]
                                      .date
                                      .toString(),
                                  format: r'j M Y')),
                          const Gap(5),
                        ],
                      );
                    } else {
                      final transactionDay =
                          _reversedTransactions![index + 1].date.weekday;

                      if (_dateHolder!.weekday == transactionDay) {
                        // logger.d(reversedTransactions[index].description);
                        return const Gap(10);
                      } else {
                        _dateHolder = _reversedTransactions![index + 1].date;
                        // logger.d(reversedTransactions[index].description);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Gap(5),
                            AppText(
                                text: AppFunctions.formatDate(
                                    _reversedTransactions![index + 1]
                                        .date
                                        .toString(),
                                    format: 'l')),
                            const Gap(5),
                          ],
                        );
                      }
                    }
                  },
                  itemCount: _reversedTransactions!.length),
            )
            // : Center(
            //     child: Column(
            //     mainAxisSize: MainAxisSize.max,
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Lottie.asset(AppAssets.emptyList, height: 200),
            //       const AppText(
            //           text: 'No transactions made on this account.')
            //     ],
            //   ))
          ],
        ),
      ),
    );
  }
}
