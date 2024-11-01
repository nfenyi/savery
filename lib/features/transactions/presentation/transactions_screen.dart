import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';

import '../../../app_functions/app_functions.dart';
import '../../main_screen/models/account.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String? _selectedAccountName;
  String? _selectedSortBy;
  Account? _selectedAccount;
  List<String>? dropdownOptions = [];

  int? _periodFilter = 0;
  int? _transactionTypeFilter = 0;

  DateTime _dateHolder = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const AppText(text: 'Transactions'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                alignment: Alignment.center,
                isExpanded: true,
                hint: const AppText(
                  text: 'Accounts',

                  // isFetching ? 'Please wait...' : "Select...",

                  overflow: TextOverflow.ellipsis,
                ),
                iconStyleData: const IconStyleData(
                  icon: FaIcon(
                    FontAwesomeIcons.chevronDown,
                    color: AppColors.neutral900,
                  ),
                  iconSize: 12.0,
                ),
                items: dropdownOptions!
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item,
                            style: GoogleFonts.manrope(
                              fontSize: AppSizes.bodySmaller,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ))
                    .toList(),
                value: _selectedAccountName,
                onChanged: (value) {},
                buttonStyleData: ButtonStyleData(
                  height: AppSizes.dropDownBoxHeight,
                  padding: const EdgeInsets.only(right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    // border: Border.all(
                    //   width: 1.0,
                    //   color: AppColors.neutral300,
                    // ),
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
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: Colors.grey.shade100,
                    thumbColor: AppColors.primary,
                    children: {
                      0: AppText(
                        text: 'All',
                        isWhite: _periodFilter == 0 ? true : false,
                      ),
                      1: AppText(
                        text: 'Day',
                        isWhite: _periodFilter == 1 ? true : false,
                      ),
                      2: AppText(
                        text: 'Week',
                        isWhite: _periodFilter == 2 ? true : false,
                      ),
                      3: AppText(
                        text: 'Month',
                        isWhite: _periodFilter == 3 ? true : false,
                      ),
                      4: AppText(
                        text: 'Year',
                        isWhite: _periodFilter == 4 ? true : false,
                      ),
                    },
                    groupValue: _periodFilter,
                    onValueChanged: (value) {
                      setState(() {
                        _periodFilter = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    borderRadius: 20,
                    callback: () {
                      setState(() {
                        _transactionTypeFilter = 0;
                      });
                    },
                    text: 'All',
                    textColor: _transactionTypeFilter == 0
                        ? Colors.white
                        : Colors.black,
                    buttonColor: _transactionTypeFilter == 0
                        ? AppColors.primary
                        : Colors.grey.shade100,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: AppButton(
                    borderRadius: 20,
                    callback: () {
                      setState(() {
                        _transactionTypeFilter = 1;
                      });
                    },
                    text: 'Incomes',
                    textColor: _transactionTypeFilter == 1
                        ? Colors.white
                        : Colors.black,
                    buttonColor: _transactionTypeFilter == 1
                        ? AppColors.primary
                        : Colors.grey.shade100,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: AppButton(
                    borderRadius: 20,
                    callback: () {
                      setState(() {
                        _transactionTypeFilter = 2;
                      });
                    },
                    buttonColor: _transactionTypeFilter == 2
                        ? AppColors.primary
                        : Colors.grey.shade100,
                    text: 'Expenses',
                    textColor: _transactionTypeFilter == 2
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ],
            ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      alignment: Alignment.centerRight,
                      hint: const AppText(
                        text: 'Sort by',
                        color: AppColors.primary,

                        // isFetching ? 'Please wait...' : "Select...",

                        overflow: TextOverflow.ellipsis,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: FaIcon(
                          FontAwesomeIcons.chevronDown,
                          color: AppColors.primary,
                        ),
                        iconSize: 12.0,
                      ),
                      items: [
                        'Sort by date',
                        'Sort by categories',
                      ]
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: GoogleFonts.manrope(
                                    fontSize: AppSizes.bodySmaller,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral900,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: _selectedSortBy,
                      onChanged: (value) {
                        setState(() {
                          _selectedSortBy = value;
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        height: AppSizes.dropDownBoxHeight,
                        padding: const EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                          // color: Colors.grey.shade100,
                          // border: Border.all(
                          //   width: 1.0,
                          //   color: AppColors.neutral300,
                          // ),
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
                ),
              ],
            ),
            const Divider(),
            (_selectedAccountName != null)
                ? SizedBox(
                    height: Adaptive.h(40),
                    child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.horizontalPaddingSmall),
                        itemBuilder: (context, index) {
                          final transaction =
                              _selectedAccount!.transactions[index];
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
                                child: _selectedAccount!.transactions[index]
                                            .category.name !=
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
                                    text:
                                        '-${transaction.amount.toString()}GHc'),
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
        ),
      ),
    );
  }
}
