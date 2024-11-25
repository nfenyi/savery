import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:gap/gap.dart';

import 'package:get/get_utils/get_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

import 'package:savery/app_constants/app_assets.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/main_screen/presentation/widgets.dart';

import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/main.dart';

class MySavingsScreen extends ConsumerStatefulWidget {
  const MySavingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MySavingsScreenState();
}

class _MySavingsScreenState extends ConsumerState<MySavingsScreen> {
  late Account _selectedAccount;

  String? _selectedAccountName;
  final _accounts = Hive.box<Account>('accounts').values;
  late String _currency;
  List<TextEditingController> _controllers = [];

  List<Budget>? _savings = [];
  List<Budget>? _expenseBudgets = [];

  late final List<String> _accountNames;

  List<bool> _canPops = [];

  @override
  void initState() {
    super.initState();
    _selectedAccount = _accounts.first;
    //TODO: make _currency non-nullable
    _currency = _selectedAccount.currency ?? 'GHS';
    _selectedAccountName = _selectedAccount.name;
    _accountNames = _accounts
        .map(
          (e) => e.name,
        )
        .toList();

    _savings = _selectedAccount.budgets
        ?.where(
          (budget) => budget.type == BudgetType.savings,
        )
        .toList();
    _expenseBudgets = _selectedAccount.budgets
        ?.where(
          (element) => element.type == BudgetType.expenseBudget,
        )
        .toList();
    for (var i = 0; i < (_savings?.length ?? 0); i++) {
      //killing two birds with one stone
      _controllers
          .add(TextEditingController(text: _savings![i].amount.toString()));
      _canPops.add(true);
      // _textFormFieldColors.add(null);
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < (_savings?.length ?? 0); i++) {
      _controllers[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  return PopScope(
    //TODO: to implement this in another way
//seems to not work because of canonicalization?
// //try creating a button to handle the equality and pass the result to canPop
//       canPop: (null ==
//           _canPops.firstWhereOrNull(
//             (element) => element == false,
//           )),
//       onPopInvokedWithResult: (didPop, result) {
//         if (!didPop) {
//           showInfoToast("Please adjust your figure(s) suitably.",
//               context: context);
//         }
    // },child:
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'My Savings',
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
            const AppText(
                text:
                    'You can set how much you wish to save out from your budget here.'),
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
                  if (_selectedAccountName != value) {
                    setState(() {
                      //just in case there will be memory leak
                      for (var i = 0; i < (_savings?.length ?? 0); i++) {
                        _controllers[i].dispose();
                      }
                      _selectedAccountName = value;

                      _selectedAccount = _accounts.firstWhere(
                        (element) => element.name == value,
                      );
                      _currency = _selectedAccount.currency ?? 'GHS';
                      _savings = _selectedAccount.budgets
                          ?.where(
                            (budget) => budget.type == BudgetType.savings,
                          )
                          .toList();
                      _expenseBudgets = _selectedAccount.budgets
                          ?.where(
                            (element) =>
                                element.type == BudgetType.expenseBudget,
                          )
                          .toList();
                      _controllers = [];
                      for (var i = 0; i < (_savings?.length ?? 0); i++) {
                        //killing two birds with one stone
                        _controllers.add(TextEditingController(
                            text: _savings![i].amount.toString()));
                        _canPops.add(true);
                        // _textFormFieldColors.add(null);
                      }
                    });
                  }
                },
                buttonStyleData: ButtonStyleData(
                  height: AppSizes.dropDownBoxHeight,
                  padding: const EdgeInsets.only(right: 10.0),
                  decoration: BoxDecoration(
                    // color: Colors.grey.shade100,
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
            (_savings != null && _savings!.isNotEmpty)
                ? Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Gap(10),
                      itemCount: _savings!.length,
                      itemBuilder: (context, index) {
                        final saving = _savings![index];
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
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: 50,
                                  color: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    getCategoryIcon(saving.category),
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Gap(10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AppText(
                                          text: saving.category!,
                                          weight: FontWeight.bold,
                                          size: AppSizes.bodySmall,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                const Gap(6),
                                                AppText(
                                                  text: _currency,
                                                  weight: FontWeight.bold,
                                                  size: AppSizes.bodySmall,
                                                ),
                                              ],
                                            ),
                                            const Gap(4),
                                            SizedBox(
                                                width: 60,
                                                child: AppTextFormField(
                                                  validator: (value) {
                                                    if (value == null ||
                                                        double.parse(value) >
                                                            _expenseBudgets![
                                                                    index]
                                                                .amount) {
                                                      return '>${_expenseBudgets![index].amount}';
                                                    }

                                                    return null;
                                                  },
                                                  textAlign: TextAlign.end,
                                                  paddingWidth: 0,
                                                  height: 6,
                                                  controller:
                                                      _controllers[index],
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  onChanged: (value) async {
                                                    if (value != null &&
                                                        value.isNotEmpty) {
                                                      final parsedValue =
                                                          double.parse(value);
                                                      if (parsedValue <
                                                          _expenseBudgets![
                                                                  index]
                                                              .amount) {
                                                        _savings![index]
                                                                .amount =
                                                            parsedValue;
                                                        await _savings![index]
                                                            .save();
                                                        _canPops[index] = true;
                                                      } else {
                                                        _canPops[index] = false;
                                                        // setState(() {
                                                        //   _textFormFieldColors[
                                                        //           index] =
                                                        //       Colors.red;
                                                        // });
                                                      }
                                                    }
                                                    logger.d(null ==
                                                        _canPops
                                                            .firstWhereOrNull(
                                                          (element) =>
                                                              element == false,
                                                        ));
                                                  },
                                                  radius: 5,
                                                )),
                                          ],
                                        )
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
                  )
                : Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(AppAssets.emptyList, height: 200),
                      const AppText(
                          text:
                              'Please create some budgets under this account first')
                    ],
                  ))
          ],
        ),
      ),
    );
  }

  // Future<dynamic> showCreateBillDialog(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (BuildContext context) {
  //       if (defaultTargetPlatform == TargetPlatform.iOS) {
  //         return CupertinoAlertDialog(
  //           content: Form(
  //             key: _formKey,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const RequiredText('Bill Name'),
  //                 const Gap(12),
  //                 AppTextFormField(
  //                   controller: _billNameController,
  //                   hintText: '50.05',
  //                   validator: FormBuilderValidators.compose([
  //                     FormBuilderValidators.required(),
  //                   ]),
  //                 ),
  //                 const Gap(12),
  //                 const RequiredText('Bill Amount'),
  //                 const Gap(12),
  //                 AppTextFormField(
  //                   controller: _billAmountController,
  //                   hintText: '50.05',
  //                   keyboardType: TextInputType.number,
  //                   suffixIcon: const AppText(
  //                     text: 'GHc',
  //                     color: Colors.grey,
  //                   ),
  //                   validator: FormBuilderValidators.compose([
  //                     FormBuilderValidators.required(),
  //                   ]),
  //                 ),
  //                 const Gap(12),
  //                 const RequiredText('Bill Coverage Duration'),
  //                 const Gap(12),
  //                 AppTextFormField(
  //                   controller: _billAmountController,
  //                   hintText: '50.05',
  //                   keyboardType: TextInputType.number,
  //                   suffixIcon: const AppText(text: 'days', color: Colors.grey),
  //                   validator: FormBuilderValidators.compose([
  //                     FormBuilderValidators.required(),
  //                   ]),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[
  //             CupertinoDialogAction(
  //               onPressed: () async {
  //                 if (_formKey.currentState!.validate()) {
  //                   navigatorKey.currentState!.pop();
  //                   _billNameController.clear();
  //                   _billAmountController.clear();
  //                   _billCoverageController.clear();
  //                 }
  //               },
  //               child: const AppText(
  //                 text: 'OK',
  //                 color: AppColors.primary,
  //                 weight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         );
  //       } else {
  //         return AlertDialog(
  //           actionsPadding: const EdgeInsets.only(bottom: 5),
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12.0)),
  //           backgroundColor: Colors.white,
  //           content: Form(
  //             key: _formKey,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const RequiredText('Category'),
  //                 const Gap(12),
  //                 DropdownButtonHideUnderline(
  //                   child: DropdownButton2<String>(
  //                     style: GoogleFonts.manrope(
  //                       fontSize: AppSizes.bodySmaller,
  //                       // fontWeight:
  //                       //     _selectedAccountName == null ? null : FontWeight.bold,
  //                       color: _selectedCategory == null
  //                           ? Colors.grey
  //                           : Colors.black,
  //                     ),
  //                     isExpanded: true,
  //                     hint: const AppText(
  //                       text: 'Select a category',
  //                       overflow: TextOverflow.ellipsis,
  //                       // color: Colors.grey,
  //                     ),
  //                     iconStyleData: const IconStyleData(
  //                       icon: FaIcon(
  //                         FontAwesomeIcons.chevronDown,
  //                         color: AppColors.primary,
  //                       ),
  //                       iconSize: 12.0,
  //                     ),
  //                     items: _transactionCategories
  //                         .map((item) => DropdownMenuItem(
  //                               value: item,
  //                               child: Text(
  //                                 item,
  //                                 style: const TextStyle(
  //                                   fontSize: AppSizes.bodySmaller,
  //                                   fontWeight: FontWeight.w500,
  //                                   // color: Colors.grey,
  //                                 ),
  //                               ),
  //                             ))
  //                         .toList(),
  //                     value: _selectedCategory,
  //                     onChanged: (value) {
  //                       setState(() {
  //                         _selectedCategory = value;
  //                       });
  //                     },
  //                     buttonStyleData: ButtonStyleData(
  //                       height: AppSizes.dropDownBoxHeight,
  //                       padding: const EdgeInsets.only(right: 10.0),
  //                       decoration: BoxDecoration(
  //                         color: Colors.grey.shade100,
  //                         border: Border.all(
  //                           width: 1.0,
  //                           color: AppColors.neutral300,
  //                         ),
  //                         borderRadius: BorderRadius.circular(10.0),
  //                       ),
  //                     ),
  //                     dropdownStyleData: DropdownStyleData(
  //                       maxHeight: 350,
  //                       elevation: 1,
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(5.0),
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     menuItemStyleData: const MenuItemStyleData(
  //                       height: 40.0,
  //                     ),
  //                   ),
  //                 ),
  //                 const Gap(12),
  //                 const RequiredText('Bill Amount'),
  //                 const Gap(12),
  //                 AppTextFormField(
  //                   controller: _billAmountController,
  //                   hintText: '50.05',
  //                   keyboardType: TextInputType.number,
  //                   suffixIcon: const AppText(
  //                     text: 'GHc',
  //                     color: Colors.grey,
  //                   ),
  //                   validator: FormBuilderValidators.compose([
  //                     FormBuilderValidators.required(),
  //                   ]),
  //                 ),
  //                 const Gap(12),
  //                 const RequiredText('Bill Coverage Duration'),
  //                 const Gap(12),
  //                 AppTextFormField(
  //                   controller: _billCoverageController,
  //                   hintText: '50.05',
  //                   keyboardType: TextInputType.number,
  //                   suffixIcon: const AppText(
  //                     text: 'days',
  //                     color: Colors.grey,
  //                   ),
  //                   validator: FormBuilderValidators.compose([
  //                     FormBuilderValidators.required(),
  //                   ]),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               onPressed: () async {
  //                 if (_formKey.currentState!.validate()) {
  //                   final user = _userBox.values.first;

  //                   await _budgetBox.add(Budget(
  //                       category: _selectedCategory!,
  //                       amount: double.parse(_billAmountController.text),
  //                       type: BudgetType.bill,
  //                       duration: int.parse(_billCoverageController.text)));

  //                   user.accounts
  //                       ?.firstWhere(
  //                           (element) => element.name == _selectedAccountName)
  //                       .budgets = HiveList(_budgetBox);

  //                   user.accounts
  //                       ?.firstWhere(
  //                           (element) => element.name == _selectedAccountName)
  //                       .budgets
  //                       ?.addAll(_budgetBox.values);

  //                   await user.save();

  //                   navigatorKey.currentState!.pop();
  //                   _selectedCategory = null;
  //                   _billNameController.clear();
  //                   _billAmountController.clear();
  //                   _billCoverageController.clear();
  //                   setState(() {
  //                     _savings = _budgets
  //                         ?.where(
  //                           (budget) => budget.type == BudgetType.bill,
  //                         )
  //                         .toList();
  //                   });
  //                 }
  //               },
  //               child: const AppText(
  //                 text: 'OK',
  //                 color: AppColors.primary,
  //                 weight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         );
  //       }
  //     },
  //   );
  // }
}
