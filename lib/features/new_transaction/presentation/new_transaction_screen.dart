import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_functions/app_functions.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/main_screen/state/bottom_nav_index_provider.dart';
import 'package:savery/features/main_screen/state/rebuild_stats_screen_provider.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';
import 'package:savery/features/sign_in/user_info/providers/providers.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_sizes.dart';
import '../../../themes/themes.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  const NewTransactionScreen({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedTransactionType = "Income";
  TransactionCategory? _selectedCategory;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<TransactionCategory> _categories =
      Hive.box<TransactionCategory>(AppBoxes.transactionsCategories)
          .values
          .toList();

  // final List<TransactionCategory> _categories = [
  //   TransactionCategory(icon: Iconsax.gift, name: 'Gifts'),
  //   TransactionCategory(icon: FontAwesomeIcons.stethoscope, name: 'Health'),
  //   TransactionCategory(icon: FontAwesomeIcons.car, name: 'Car'),
  //   TransactionCategory(icon: FontAwesomeIcons.chess, name: 'Game'),
  //   TransactionCategory(icon: FontAwesomeIcons.utensils, name: 'Cafe'),
  //   TransactionCategory(icon: Iconsax.airplane, name: 'Travel'),
  //   TransactionCategory(icon: FontAwesomeIcons.lightbulb, name: 'Utility'),
  //   TransactionCategory(icon: Icons.face_2, name: 'Care'),
  //   TransactionCategory(icon: FontAwesomeIcons.tv, name: 'Devices'),
  //   TransactionCategory(icon: FontAwesomeIcons.bowlFood, name: 'Food'),
  //   TransactionCategory(icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
  //   TransactionCategory(icon: Iconsax.truck, name: 'Transport'),
  // ];

  String? _selectedAccountName;
  final Iterable<Account> _accounts = Hive.box<Account>('accounts').values;

  late final List<String> _accountNames;

  Color? _accountNameColor;

  Color? _dateColor;

  Color? _categoryColor;

  late String _currency;

  @override
  void initState() {
    super.initState();
    _accountNames = _accounts
        .map(
          (e) => e.name,
        )
        .toList();
    _currency = 'GHS';
  }

  @override
  void dispose() {
    super.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => navigatorKey.currentState!.pop(),
          child: Ink(
            child: const Padding(
              padding: EdgeInsets.only(
                  left: AppSizes.horizontalPadding,
                  top: AppSizes.horizontalPadding),
              child: FaIcon(
                FontAwesomeIcons.chevronDown,
                // color: AppColors.neutral500,
                size: 18,
              ),
            ),
          ),
        ),
        title: const AppText(
          text: 'New Transaction',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.horizontalPaddingSmall),
          child: Column(
            children: [
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    callback: () {
                      setState(() {
                        _selectedTransactionType = 'Income';
                      });
                    },
                    width: 130,
                    padding: const EdgeInsets.all(12),
                    text: 'Income',
                    isSecondary: _selectedTransactionType == 'Expense',
                    textSize: 17,
                    iconFirst: true,
                    borderRadius: 15,
                    icon: Icon(
                      Iconsax.arrow_down,
                      color: _selectedTransactionType == 'Expense'
                          // ? AppColors.primary
                          ? null
                          : Colors.white,
                      size: 17,
                    ),
                  ),
                  const Gap(15),
                  AppButton(
                    callback: () {
                      setState(() {
                        _selectedTransactionType = 'Expense';
                      });
                    },
                    borderRadius: 15,
                    padding: const EdgeInsets.all(12),
                    text: 'Expense',
                    isSecondary: _selectedTransactionType == 'Income',
                    width: 130,
                    textSize: 17,
                    iconFirst: true,
                    icon: Icon(
                      Iconsax.arrow_up_3,
                      color: _selectedTransactionType == 'Income'
                          // ? AppColors.primary
                          ? null
                          : Colors.white,
                      size: 17,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 110,
                                child: AppTextFormField(
                                  controller: _amountController,
                                  textAlign: TextAlign.right,
                                  borderType: BorderType.underline,
                                  hintText: '0.00',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(),
                                  // textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  suffixIcon: AppText(text: _currency),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(
                                        errorText: 'Provide figure')
                                  ]),
                                ),
                              ),
                              AppTextFormField(
                                // fontWeight: FontWeight.bold,
                                controller: _descriptionController,
                                borderType: BorderType.underline,
                                hintText: 'Description',
                                hintStyleColor: Colors.grey,
                                validator: FormBuilderValidators.compose(
                                    [FormBuilderValidators.required()]),
                              ),
                              Visibility(
                                visible: _selectedTransactionType == 'Expense',
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(
                                          left: 12, right: 5),
                                      title: AppText(
                                        text: _selectedCategory == null
                                            ? 'Category'
                                            : _selectedCategory!.name,
                                        // weight: _selectedCategory == null
                                        //     ? null
                                        //     : FontWeight.bold,
                                        color: _selectedCategory == null
                                            ? Colors.grey
                                            : null,
                                      ),
                                      trailing: const Icon(
                                        Icons.keyboard_arrow_down,
                                        // color: AppColors.primary,
                                      ),
                                      dense: true,
                                      onTap: () async {
                                        await showModalBottomSheet(
                                          context: context,
                                          barrierColor:
                                              Colors.black.withOpacity(0.6),
                                          builder: (BuildContext context) {
                                            return Container(
                                                width: double.infinity,
                                                // height: Adaptive.h(40),
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.4,
                                                decoration: BoxDecoration(
                                                  // color: Colors.white,
                                                  color: ((ref.watch(themeProvider) ==
                                                                  'System' ||
                                                              ref.watch(
                                                                      themeProvider) ==
                                                                  'Dark') &&
                                                          (MediaQuery
                                                                  .platformBrightnessOf(
                                                                      context) ==
                                                              Brightness.dark))
                                                      ? const Color.fromARGB(
                                                          255, 32, 25, 33)
                                                      : Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15.0),
                                                    topRight:
                                                        Radius.circular(15.0),
                                                  ),
                                                ),
                                                child: SingleChildScrollView(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 30),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Gap(
                                                        5,
                                                      ),
                                                      const Gap(10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const SizedBox
                                                              .shrink(),
                                                          const AppText(
                                                            text:
                                                                "Select the category",
                                                            size: AppSizes
                                                                .bodySmaller,
                                                            // weight: FontWeight.bold,
                                                          ),
                                                          // const Gap(10),
                                                          GestureDetector(
                                                            child: FaIcon(
                                                              FontAwesomeIcons
                                                                  .xmark,
                                                              size: 18,
                                                              color: ((ref.watch(themeProvider) ==
                                                                              'System' ||
                                                                          ref.watch(themeProvider) ==
                                                                              'Dark') &&
                                                                      (MediaQuery.platformBrightnessOf(
                                                                              context) ==
                                                                          Brightness
                                                                              .dark))
                                                                  ? AppColors
                                                                      .primaryDark
                                                                  : AppColors
                                                                      .primary,
                                                            ),
                                                            onTap: () =>
                                                                navigatorKey
                                                                    .currentState!
                                                                    .pop(),
                                                          ),
                                                          // const Gap(10),
                                                          // AppTextButton(
                                                          //   text: 'Done',
                                                          //   color: AppColors.primary,
                                                          //   callback: () {
                                                          //     navigatorKey.currentState!.pop();
                                                          //   },
                                                          // )
                                                        ],
                                                      ),
                                                      const Gap(30),
                                                      SizedBox(
                                                        height: Adaptive.h(30),
                                                        child: GridView.builder(
                                                          itemCount: _categories
                                                              .length,
                                                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                                              maxCrossAxisExtent:
                                                                  70,
                                                              mainAxisExtent:
                                                                  65,
                                                              crossAxisSpacing:
                                                                  10,
                                                              mainAxisSpacing:
                                                                  10),
                                                          itemBuilder:
                                                              (context, index) {
                                                            final category =
                                                                _categories[
                                                                    index];
                                                            return InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _selectedCategory =
                                                                      category;
                                                                });
                                                                navigatorKey
                                                                    .currentState!
                                                                    .pop();
                                                              },
                                                              child: Ink(
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  child: TileIcon(
                                                                      category:
                                                                          category),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ));
                                          },
                                        );
                                      },
                                    ),
                                    Divider(
                                      color: _categoryColor,
                                    ),
                                  ],
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  style: GoogleFonts.manrope(
                                    fontSize: AppSizes.bodySmaller,
                                    // fontWeight: _selectedAccountName == null
                                    //     ? null
                                    //     : FontWeight.bold,
                                    color: Colors.black,
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
                                      // color: AppColors.primary,
                                    ),
                                    iconSize: 12.0,
                                  ),
                                  items: _accountNames
                                      .map((item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: GoogleFonts.manrope(
                                                fontSize: AppSizes.bodySmaller,
                                                fontWeight: FontWeight.w500,
                                                color: (ref.watch(themeProvider) ==
                                                                'System' &&
                                                            MediaQuery.platformBrightnessOf(
                                                                    context) ==
                                                                Brightness
                                                                    .dark) ||
                                                        ref.watch(
                                                                themeProvider) ==
                                                            'Dark'
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
                                      _currency =
                                          Hive.box<Account>(AppBoxes.accounts)
                                                  .values
                                                  .firstWhere(
                                                    (element) =>
                                                        element.name == value,
                                                  )
                                                  .currency ??
                                              'GHS';
                                    });
                                  },
                                  buttonStyleData: const ButtonStyleData(
                                    height: AppSizes.dropDownBoxHeight,
                                    padding: EdgeInsets.only(right: 10.0),
                                    // decoration: BoxDecoration(
                                    //   color: ((ref.watch(themeProvider) == 'System' ||
                                    //               ref.watch(themeProvider) == 'Dark') &&
                                    //           (MediaQuery.platformBrightnessOf(context) ==
                                    //               Brightness.dark))
                                    //       ? const Color.fromARGB(255, 32, 25, 33)
                                    //       : Colors.white,
                                    //   border: Border.all(
                                    //     //   width: 1.0,
                                    //     color: AppColors.neutral300,
                                    //   ),
                                    // borderRadius: BorderRadius.circular(20.0),
                                    // ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 350,
                                    elevation: 1,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: (ref.watch(themeProvider) ==
                                                      'System' &&
                                                  MediaQuery
                                                          .platformBrightnessOf(
                                                              context) ==
                                                      Brightness.dark) ||
                                              ref.watch(themeProvider) == 'Dark'
                                          ? const Color.fromARGB(
                                              255, 32, 25, 33)
                                          : Colors.white,
                                    ),
                                  ),
                                  menuItemStyleData: const MenuItemStyleData(
                                    height: 40.0,
                                  ),
                                ),
                              ),
                              Divider(
                                color: _accountNameColor,
                              ),
                              ListTile(
                                title: Text(
                                  _selectedDate == null
                                      ? 'Date'
                                      : AppFunctions.formatDate(
                                          _selectedDate.toString(),
                                          format: 'j M Y, g:i A'),
                                  style: GoogleFonts.manrope(
                                    fontSize: AppSizes.bodySmaller,
                                    // fontWeight:
                                    //     _selectedDate == null ? null : FontWeight.bold,
                                    color: _selectedDate == null
                                        ? Colors.grey
                                        : null,
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
                                      activeColor: (ref.watch(themeProvider) ==
                                                      'System' &&
                                                  MediaQuery
                                                          .platformBrightnessOf(
                                                              context) ==
                                                      Brightness.dark) ||
                                              ref.watch(themeProvider) == 'Dark'
                                          ? AppColors.primaryDark
                                          : AppColors.primary,
                                      // backgroundColor: Colors.white,
                                      foregroundColor: (ref.watch(
                                                          themeProvider) ==
                                                      'System' &&
                                                  MediaQuery
                                                          .platformBrightnessOf(
                                                              context) ==
                                                      Brightness.dark) ||
                                              ref.watch(themeProvider) == 'Dark'
                                          ? const Color.fromARGB(
                                              255, 78, 79, 91)
                                          : AppColors.neutral100,
                                      // boardTitle: "Select 'TODAY' or '",
                                      // boardTitleTextStyle: TextStyle(fontWeight: FontWeight.w400),
                                      inputable: false,
                                      pickerSubTitles:
                                          const BoardDateTimeItemTitles(
                                        year: 'Year',
                                        // day: 'd',
                                        // hour: 'h',
                                        // minute: 'm',
                                      ),
                                    ),
                                    context: context,
                                    pickerType: DateTimePickerType.datetime,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          color: _dateColor,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        AppGradientButton(
                          text: 'Save',
                          callback: () async {
                            if (_formKey.currentState!.validate() &&
                                _selectedAccountName != null &&
                                _selectedDate != null) {
                              if (_selectedCategory == null &&
                                  _selectedTransactionType == 'Expense') {
                                setState(() {
                                  _categoryColor = Colors.red;
                                });
                                showInfoToast('Please select a category',
                                    context: context);
                              } else if (_selectedTransactionType ==
                                      'Expense' &&
                                  ref
                                          .read(userProvider)
                                          .expenseBudgets(_accounts.firstWhere(
                                            (element) =>
                                                element.name ==
                                                _selectedAccountName,
                                          ))
                                          ?.toList()
                                          .firstWhereOrNull(
                                            (element) =>
                                                element.category!.name ==
                                                _selectedCategory!.name,
                                          ) ==
                                      null) {
                                setState(() {
                                  _categoryColor = Colors.red;
                                });
                                showInfoToast(
                                    'Please create a ${_selectedCategory!.name} budget for this transaction for this account first.',
                                    context: context);
                              } else {
                                await ref
                                    .read(userProvider.notifier)
                                    .addTransaction(
                                      amount: _amountController.text,
                                      description: _descriptionController.text,
                                      selectedAccountName:
                                          _selectedAccountName!,
                                      selectedCategory: _selectedCategory,
                                      selectedDate: _selectedDate!,
                                      selectedTransactionType:
                                          _selectedTransactionType,
                                    );
                                _amountController.clear();
                                _descriptionController.clear();
                                navigatorKey.currentState!.pop();
                                if (ref.read(inStatsScreenProvider)) {
                                  ref
                                      .read(bottomNavIndexProvider.notifier)
                                      .rebuildStatsScreen();
                                }
                              }
                            } else {
                              if (_selectedAccountName == null) {
                                setState(() {
                                  _accountNameColor = Colors.red;
                                });
                                showInfoToast('Please select an account',
                                    context: context);
                              } else {
                                setState(() {
                                  _accountNameColor = null;
                                });
                              }
                              if (_selectedDate == null) {
                                setState(() {
                                  _dateColor = Colors.red;
                                });
                                showInfoToast('Please pick a date',
                                    context: context);
                              } else {
                                setState(() {
                                  _dateColor = null;
                                });
                              }
                            }
                          },
                        ),
                        Gap(20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TileIcon extends ConsumerWidget {
  const TileIcon({
    super.key,
    required this.category,
  });

  final TransactionCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        width: double.infinity,
        color: (ref.watch(themeProvider) == 'System' &&
                    MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark) ||
                ref.watch(themeProvider) == 'Dark'
            ? AppColors.primaryDark.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              category.icon,
              color: ((ref.watch(themeProvider) == 'System') &&
                      (MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark))
                  ? AppColors.primaryDark
                  : AppColors.primary,
            ),
            AppText(
              text: category.name,
              color: (ref.watch(themeProvider) == 'System' &&
                          MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark) ||
                      ref.watch(themeProvider) == 'Dark'
                  ? AppColors.primaryDark
                  : AppColors.primary,
              size: AppSizes.bodySmallest,
            )
          ],
        ));
  }
}
