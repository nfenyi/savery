import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:iconify_flutter/icons/heroicons.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ic.dart';
import 'package:iconify_flutter_plus/icons/la.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_widgets/widgets.dart';
import 'package:savery/features/categories/providers/categories_provider.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/main.dart';

import '../../../app_widgets/app_text.dart';
import '../../../themes/themes.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController categoryNameController =
        TextEditingController();
    final formKey = GlobalKey<FormState>();
    final consumerCategories = ref.watch(categoriesProvider).categories;
    String? selectedIcon;
    Color? pickAColorColor;
    final addButton =
        TransactionCategory(icon: Ic.round_plus, name: 'Add a category');
    final categoriesHolder = [addButton, ...consumerCategories];
    Future<void> showDeleteDialog(
        {required TransactionCategory category, required int index}) async {
      await showAppInfoDialog(
        navigatorKey.currentContext!,
        ref,
        title: 'Are you sure you want to delete ${category.name}?',
        confirmText: 'Yes',
        isWarning: true,
        cancelText: 'No',
        confirmCallbackFunction: () async {
          await ref
              .read(categoriesProvider.notifier)
              .deleteCategory(index: index);

          navigatorKey.currentState!.pop();
        },
      );
    }

    Future<dynamic> showAddDialog({
      required BuildContext context,
    }) async {
      return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            return CupertinoAlertDialog(
              content: StatefulBuilder(builder: (context, setState) {
                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RequiredText('Goal'),
                      const Gap(12),
                      AppTextFormField(
                        controller: categoryNameController,
                        hintText: '50.05',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const Gap(12),
                    ],
                  ),
                );
              }),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {}
                  },
                  child: AppText(
                    text: 'Add',
                    color: (ref.watch(themeProvider) == 'System' &&
                                MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark) ||
                            ref.watch(themeProvider) == 'Dark'
                        ? AppColors.primaryDark
                        : AppColors.primary,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            );
          } else {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                actionsPadding: const EdgeInsets.only(bottom: 5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: 'New Category',
                        weight: FontWeight.bold,
                        size: 15,
                      ),
                      const Gap(27),
                      const RequiredText('Name'),
                      const Gap(12),
                      AppTextFormField(
                        controller: categoryNameController,
                        hintText: 'wife',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const Gap(12),
                      AppText(
                        text: 'Pick an icon',
                        color: pickAColorColor,
                      ),
                      const Gap(5),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1.0,
                              color: AppColors.neutral300,
                            ),
                          ),
                          height: Adaptive.h(30),
                          width: Adaptive.w(60),
                          child: Scrollbar(
                            child: GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              itemCount: Heroicons.iconsList.length,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 30,
                                      mainAxisExtent: 30,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 10),
                              itemBuilder: (context, index) {
                                final icon = Heroicons.iconsList[index];
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedIcon = icon;
                                    });
                                  },
                                  child: Ink(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: (selectedIcon == icon
                                                    ? ((ref.watch(themeProvider) ==
                                                                'System') &&
                                                            (MediaQuery.platformBrightnessOf(
                                                                    context) ==
                                                                Brightness
                                                                    .dark))
                                                        ? AppColors.primaryDark
                                                        : AppColors.primary
                                                    : Colors.grey)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5))),
                                        // width: Adaptive.w(5),
                                        child: Iconify(
                                          icon,
                                          color: selectedIcon == icon
                                              ? ((ref.watch(themeProvider) ==
                                                          'System') &&
                                                      (MediaQuery
                                                              .platformBrightnessOf(
                                                                  context) ==
                                                          Brightness.dark))
                                                  ? AppColors.primaryDark
                                                  : AppColors.primary
                                              : null,
                                          size: 7,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (selectedIcon != null) {
                          await ref
                              .read(categoriesProvider.notifier)
                              .addCategory(
                                  name: categoryNameController.text,
                                  icon: selectedIcon!);
                          selectedIcon = null;
                          navigatorKey.currentState!.pop();
                        } else {
                          showInfoToast('Please pick an icon.',
                              context: context);

                          setState(() {
                            pickAColorColor = Colors.red;
                          });
                        }
                      }
                    },
                    child: AppText(
                      text: 'Add',
                      color: (ref.watch(themeProvider) == 'System' &&
                                  MediaQuery.platformBrightnessOf(context) ==
                                      Brightness.dark) ||
                              ref.watch(themeProvider) == 'Dark'
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            });
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'Categories',
          weight: FontWeight.bold,
          size: AppSizes.bodySmall,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.horizontalPaddingSmall),
                itemCount: categoriesHolder.length,
                itemBuilder: (context, index) {
                  final category = categoriesHolder.toList()[index];
                  return ListTile(
                    onTap: index == 0
                        ? () async {
                            await showAddDialog(
                              context: context,
                            );
                          }
                        : null,
                    contentPadding: const EdgeInsets.all(0),
                    trailing: index != 0
                        ? InkWell(
                            onTap: () async => await showDeleteDialog(
                                category: category, index: index),
                            child: Ink(
                              child: const SizedBox(
                                width: 20,
                                child: FaIcon(
                                  FontAwesomeIcons.trashCan,
                                  color: Colors.red,
                                  size: 15,
                                ),
                              ),
                            ),
                          )
                        : null,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 7),
                      decoration: BoxDecoration(
                          color: (ref.watch(themeProvider) == 'System' &&
                                      MediaQuery.platformBrightnessOf(
                                              context) ==
                                          Brightness.dark) ||
                                  ref.watch(themeProvider) == 'Dark'
                              ? AppColors.primaryDark.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5))),
                      // width: Adaptive.w(5),
                      child: Iconify(
                        category.icon,
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        size: 25,
                      ),
                    ),
                    title: AppText(
                      text: category.name,
                      size: AppSizes.bodySmaller,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
