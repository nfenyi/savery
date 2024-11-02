import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/new_transaction/models/transaction_category.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_sizes.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  final _priceController = TextEditingController();
  final _nameController = TextEditingController();
  // final _accountsController = TextEditingController();
  // final _dateController = TextEditingController();

  final List<TransactionCategory> _categories = [
    TransactionCategory(icon: Iconsax.gift, name: 'Gifts'),
    TransactionCategory(icon: FontAwesomeIcons.stethoscope, name: 'Health'),
    TransactionCategory(icon: FontAwesomeIcons.car, name: 'Car'),
    TransactionCategory(icon: FontAwesomeIcons.chess, name: 'Game'),
    TransactionCategory(icon: FontAwesomeIcons.utensils, name: 'Cafe'),
    TransactionCategory(icon: Iconsax.airplane, name: 'Travel'),
    TransactionCategory(icon: FontAwesomeIcons.lightbulb, name: 'Utility'),
    TransactionCategory(icon: Icons.face_2, name: 'Care'),
    TransactionCategory(icon: FontAwesomeIcons.tv, name: 'Devices'),
    TransactionCategory(icon: FontAwesomeIcons.bowlFood, name: 'Food'),
    TransactionCategory(icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
    TransactionCategory(icon: Iconsax.truck, name: 'Transport'),
  ];

  @override
  void initState() {
    super.initState();
    _categories.add(TransactionCategory(icon: Icons.add_circle, name: ''));
  }

  @override
  void dispose() {
    super.dispose();
    _priceController.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppText(text: 'New Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.horizontalPaddingSmall),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  width: 130,
                  padding: EdgeInsets.all(12),
                  text: 'Income',
                  isSecondary: true,
                  textSize: 17,
                  iconFirst: true,
                  borderRadius: 15,
                  icon: Icon(
                    Iconsax.arrow_down,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
                Gap(15),
                AppButton(
                  borderRadius: 15,
                  padding: EdgeInsets.all(12),
                  text: 'Expense',
                  width: 130,
                  textSize: 17,
                  iconFirst: true,
                  icon: Icon(
                    Iconsax.arrow_up_3,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ],
            ),
            // TextFormField(controller: _priceController,textAlign: TextAlign.right,decoration: InputDecoration(hintStyle: ),)
            AppTextFormField(
              controller: _priceController,
              textAlign: TextAlign.right,
              borderType: BorderType.underline,
              hintText: 'Price',
              keyboardType: const TextInputType.numberWithOptions(),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              // suffixIcon: const AppText(text: '₵'),
            ),
            AppTextFormField(
              controller: _nameController,
              borderType: BorderType.underline,
              hintText: 'Name',
            ),
            ListTile(
              title: const AppText(text: 'Category'),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.6),
                  builder: (BuildContext context) {
                    return Container(
                        width: double.infinity,
                        // height: Adaptive.h(40),
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(
                                5,
                              ),
                              const Gap(10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    child: const FaIcon(
                                      FontAwesomeIcons.xmark,
                                      size: 18,
                                    ),
                                    onTap: () =>
                                        navigatorKey.currentState!.pop(),
                                  ),
                                  // const Gap(10),
                                  const AppText(
                                    text: "Select the category",
                                    size: AppSizes.bodySmaller,
                                  ),
                                  // const Gap(10),
                                  AppTextButton(
                                    text: 'Done',
                                    callback: () {
                                      navigatorKey.currentState!.pop();
                                    },
                                  )
                                ],
                              ),
                              const Gap(30),
                              SizedBox(
                                height: Adaptive.h(30),
                                child: GridView.builder(
                                  itemCount: _categories.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 70,
                                          mainAxisExtent: 65,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10),
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: TileIcon(category: category),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        )

                        //  CupertinoDatePicker(
                        //   backgroundColor: Colors.white,
                        //   initialDateTime: DateTime.now(),
                        //   maximumDate: DateTime.now(),
                        //   minimumDate: DateTime(1900),
                        //   mode: CupertinoDatePickerMode.date,
                        //   onDateTimeChanged: (DateTime datetime) {
                        //     _dobController.text =
                        //         AppFunctions.formatDate(
                        //       datetime.toIso8601String(),
                        //     );
                        //   },
                        // ),
                        );
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const AppText(text: 'Accounts'),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const AppText(text: 'Date'),
              trailing: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const AppText(text: 'Photo'),
              trailing: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
              ),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              onTap: () {},
            ),
            const Divider(),
            AppGradientButton(
              text: 'Save',
              callback: () {
                navigatorKey.currentState!.pop();
              },
            )
            // Row(
            //   children: [
            //     AppText(text: 'Accounts'),
            //     Icon(Icons.keyboard_arrow_down)
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}

class TileIcon extends StatelessWidget {
  const TileIcon({
    super.key,
    required this.category,
  });

  final TransactionCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary.withOpacity(0.1),
      child: category.name != ''
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  color: AppColors.primary,
                ),
                AppText(
                  text: category.name,
                  color: AppColors.primary,
                  size: AppSizes.bodySmallest,
                )
              ],
            )
          : Icon(
              category.icon,
              color: AppColors.primary,
            ),
    );
  }
}
