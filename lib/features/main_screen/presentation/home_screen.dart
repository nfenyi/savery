import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart' as d_border;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_functions/app_functions.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart' as widgets;
import 'package:savery/extensions/context_extenstions.dart';
import 'package:savery/features/transactions/presentation/transactions_screen.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_assets.dart';
import '../../../app_widgets/widgets.dart';
import '../../../themes/themes.dart';
import '../../sign_in/user_info/models/user_model.dart';
import '../../sign_in/user_info/providers/providers.dart';
import 'widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime? _dateHolder;

  final GlobalKey<FormState> _accountNameFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final db = FirebaseFirestore.instance;
  bool showFirstCard = true;
  late ValueNotifier<Account?> _valueNotifier;
  late final String _appStateUid;

  @override
  void initState() {
    super.initState();
    _appStateUid = Hive.box(AppBoxes.appState).get('currentUser');
    _valueNotifier = ValueNotifier(
        ref.read(userProvider).user(_appStateUid).accounts?.firstOrNull);

    // _accounts.add(
    //   Account(
    //       name: 'April',
    //       availableBalance: 2225,
    //       expenses: 600,
    //       income: 800,
    //       transactions: [
    //         Transaction(
    //             category: TransactionCategory(
    //                 icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
    //             amount: 35,
    //             createdAt: DateTime.now(),
    //             description: 'Carrefour Supermarket'),
    //         Transaction(
    //             category: (
    //                 icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
    //             amount: 35,
    //             createdAt: DateTime.now(),
    //             description: 'Carrefour Supermarket'),
    //         Transaction(
    //             category: TransactionCategory(
    //                 icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
    //             amount: 35,
    //             createdAt: DateTime.now(),
    //             description: 'Carrefour Supermarket'),
    //         Transaction(
    //             category: TransactionCategory(
    //                 icon: FontAwesomeIcons.cartShopping, name: 'Shopping'),
    //             amount: 35,
    //             createdAt: DateTime.now(),
    //             description: 'Carrefour Supermarket'),
    //       ]),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime dateTimeNow = DateTime.now();
    // logger.d(_selectedAccount!.name);

    // logger.d(_userBox);
    // var val = _accountsBox.watch().map(
    //   (event) {
    //     logger.d('not dele');
    //     if (event.deleted) {
    //       // Handle deletion (if needed)
    //       // You might want to remove the item from your UI or perform other actions
    //       return null;
    //     } else {
    //       logger.d('not dele');
    //       return _accountsBox.get(event.key);
    //     }
    //   },
    // );
    // logger.d(val.length);

    //TODO: place at a better place:
    // _accounts =  db
    //     .collection(FirestoreFieldNames.users)
    //     .where('users', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get().;

    // logger.d(db.doc(
    //     '${FirestoreFieldNames.users}/${FirebaseAuth.instance.currentUser!.uid}/${FirestoreFieldNames.accounts}/').get());
    final AppUser user = ref.watch(userProvider).user(_appStateUid);

    // HiveList<Account>? accounts = ref.watch(accountsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(20),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.horizontalPaddingSmall),
          child: AppText(
            text: context.localizations.accounts,
            // 'Accounts',
            size: AppSizes.bodySmall,
            weight: FontWeight.bold,
          ),
        ),
        const Gap(10),
        (user.accounts == null || user.accounts!.isEmpty)
            ? InkWell(
                onTap: () async {
                  await showAccountDialog(context);
                },
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.horizontalPaddingSmall),
                    child: d_border.DottedBorder(
                        color: (ref.watch(themeProvider) == 'System' &&
                                    MediaQuery.platformBrightnessOf(context) ==
                                        Brightness.dark) ||
                                ref.watch(themeProvider) == 'Dark'
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        borderType: d_border.BorderType.RRect,
                        radius: const Radius.circular(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: Adaptive.w(90),
                              height: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: ((ref.watch(themeProvider) ==
                                                'System') &&
                                            (MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark))
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    // size: 5,
                                  ),
                                  const Gap(10),
                                  AppText(
                                    text: context.localizations
                                        .tap_here_to_create_an_account,
                                    // 'Tap here to create an account.'
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              )
            : CarouselSlider.builder(
                itemCount: user.accounts!.length,
                itemBuilder: (context, index, realIndex) {
                  final account = user.accounts![index];
                  if (index != user.accounts!.length - 1) {
                    return AccountCard(
                        account: account, appStateUid: _appStateUid);
                  } else {
                    return SizedBox(
                      width: 384,
                      height: 200,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            width: 320,
                            child: AccountCard(
                              account: account,
                              appStateUid: _appStateUid,
                            ),
                          ),
                          const Gap(1),
                          InkWell(
                            onTap: () async {
                              await showAccountDialog(context);
                            },
                            child: Ink(
                              child: d_border.DottedBorder(
                                  color: (ref.watch(themeProvider) ==
                                                  'System' &&
                                              MediaQuery.platformBrightnessOf(
                                                      context) ==
                                                  Brightness.dark) ||
                                          ref.watch(themeProvider) == 'Dark'
                                      ? AppColors.primaryDark
                                      : AppColors.primary,
                                  borderType: d_border.BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle,
                                        color: ((ref.watch(themeProvider) ==
                                                    'System') &&
                                                (MediaQuery
                                                        .platformBrightnessOf(
                                                            context) ==
                                                    Brightness.dark))
                                            ? AppColors.primaryDark
                                            : AppColors.primary,
                                        // size: 5,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                options: CarouselOptions(
                    // enlargeCenterPage: true,
                    height: 200,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      _valueNotifier.value = user.accounts![index];
                    },
                    viewportFraction: 0.85),
              ),
        const Gap(20),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.horizontalPaddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: context.localizations.transactions,
                    // 'Transactions',
                    weight: FontWeight.bold,
                    size: AppSizes.bodySmall,
                  ),
                  ValueListenableBuilder(
                    valueListenable: _valueNotifier,
                    builder: (context, value, child) {
                      return Visibility(
                          visible: value?.transactions != null &&
                              value!.transactions!.isNotEmpty,
                          child: child!);
                    },
                    child: widgets.AppTextButton(
                        text: context.localizations.view_all,
                        //  'View All',
                        callback: () async {
                          await navigatorKey.currentState!
                              .push(MaterialPageRoute(
                            builder: (context) => TransactionsScreen(
                              initAccount: _valueNotifier.value!,
                            ),
                          ));
                        }),
                  )
                ],
              ),
              const Gap(5),
              ValueListenableBuilder(
                  valueListenable: _valueNotifier,
                  builder: (context, value, child) {
                    if (value?.transactions == null ||
                        value!.transactions!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    _dateHolder = value.transactions?.reversed.first.date;
                    return AppText(
                      text: (dateTimeNow.day == _dateHolder?.day)
                          ? context.localizations.today
                          : (dateTimeNow.weekday - _dateHolder!.weekday == 1)
                              ? context.localizations.yesterday
                              // 'Yesterday'
                              : (dateTimeNow.difference(_dateHolder!).inDays >
                                      7)
                                  ? AppFunctions.formatDate(
                                      _dateHolder!.toString(),
                                      format: r'j M')
                                  : AppFunctions.formatDate(
                                      _dateHolder!.toString(),
                                      format: r'l'),
                    );
                  }),
              const Gap(5)
            ],
          ),
        ),
        ValueListenableBuilder(
            valueListenable: _valueNotifier,
            builder: (context, value, child) {
              if (value?.transactions != null &&
                  value!.transactions!.isNotEmpty) {
                final reversedTransactions =
                    value.transactions!.reversed.toList();
                return Expanded(
                  child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.horizontalPaddingSmall),
                      itemBuilder: (context, index) {
                        final transaction = reversedTransactions[index];
                        return Container(
                          decoration: BoxDecoration(
                              color: (ref.watch(themeProvider) == 'System' &&
                                          MediaQuery.platformBrightnessOf(
                                                  context) ==
                                              Brightness.dark) ||
                                      ref.watch(themeProvider) == 'Dark'
                                  ? const Color.fromARGB(255, 39, 32, 39)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(15)),
                            // tileColor: Colors.grey.shade100,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  width: 50,
                                  color: ((ref.watch(themeProvider) ==
                                              'System') &&
                                          (MediaQuery.platformBrightnessOf(
                                                  context) ==
                                              Brightness.dark))
                                      ? AppColors.primaryDark.withOpacity(0.1)
                                      : AppColors.primary.withOpacity(0.1),
                                  child: transaction.category == null
                                      ? FaIcon(
                                          FontAwesomeIcons.coins,
                                          color: ((ref.watch(themeProvider) ==
                                                      'System') &&
                                                  (MediaQuery
                                                          .platformBrightnessOf(
                                                              context) ==
                                                      Brightness.dark))
                                              ? AppColors.primaryDark
                                              : AppColors.primary,
                                        )
                                      : Iconify(
                                          transaction.category!.icon,
                                          color: ((ref.watch(themeProvider) ==
                                                      'System') &&
                                                  (MediaQuery
                                                          .platformBrightnessOf(
                                                              context) ==
                                                      Brightness.dark))
                                              ? AppColors.primaryDark
                                              : AppColors.primary,
                                        )),
                            ),
                            title: AppText(
                                text: transaction.type == 'Income'
                                    ? context.localizations.income
                                    // "Income"
                                    : transaction.category!.name),
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
                                      '${transaction.type == 'Income' ? '+' : '-'} ${_valueNotifier.value!.currency ?? 'GHS'} ${transaction.amount.toString()}',
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
                        if (reversedTransactions[index + 1]
                                .date
                                .difference(_dateHolder!) >
                            const Duration(days: 7)) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(5),
                              AppText(
                                  text: AppFunctions.formatDate(
                                      reversedTransactions[index + 1]
                                          .date
                                          .toString(),
                                      format: r'j M Y')),
                              const Gap(5),
                            ],
                          );
                        } else {
                          final transactionDay =
                              reversedTransactions[index + 1].date.weekday;

                          if (_dateHolder!.weekday == transactionDay) {
                            // logger.d(reversedTransactions[index].description);
                            return const Gap(10);
                          } else {
                            _dateHolder = reversedTransactions[index + 1].date;
                            // logger.d(reversedTransactions[index].description);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(5),
                                AppText(
                                  text: reversedTransactions[index + 1]
                                              .date
                                              .weekday ==
                                          1
                                      ? context.localizations.monday
                                      : reversedTransactions[index + 1]
                                                  .date
                                                  .weekday ==
                                              2
                                          ? context.localizations.tuesday
                                          : reversedTransactions[index + 1]
                                                      .date
                                                      .weekday ==
                                                  3
                                              ? context.localizations.wednesday
                                              : reversedTransactions[index + 1]
                                                          .date
                                                          .weekday ==
                                                      4
                                                  ? context
                                                      .localizations.thursday
                                                  : reversedTransactions[
                                                                  index + 1]
                                                              .date
                                                              .weekday ==
                                                          5
                                                      ? context
                                                          .localizations.friday
                                                      : reversedTransactions[
                                                                      index + 1]
                                                                  .date
                                                                  .weekday ==
                                                              6
                                                          ? context
                                                              .localizations
                                                              .saturday
                                                          : context
                                                              .localizations
                                                              .sunday,
                                ),
                                const Gap(5),
                              ],
                            );
                          }
                        }
                      },
                      itemCount: value.transactions!.length < 5
                          ? value.transactions!.length
                          : 5),
                );
              } else {
                return Expanded(
                  // child: Column(
                  //   children: [
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(AppAssets.emptyList, height: 200),
                        (value != null)
                            ? AppText(
                                text: context
                                    .localizations.tap_add_transaction_button,
                                // 'Tap on the + button to add a transaction.',
                              )
                            : const AppText(text: 'No transactions yet.'),
                        Gap(Adaptive.h(20)),
                      ],
                    ),
                  ),
                  //   ],
                  // ),
                );
              }
            })
      ],
    );
  }

  Future<dynamic> showAccountDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return CupertinoAlertDialog(
            content: Form(
              key: _accountNameFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequiredText(
                    context.localizations.name_of_account_title,
                    // 'Name of Account'
                  ),
                  const Gap(12),
                  AppTextFormField(
                    controller: _nameController,
                    hintText: 'eg. ${context.localizations.primary}',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () async {
                  // if (_accountNameFormKey.currentState!.validate()) {
                  //   final user = _userBox.values.first;

                  //   await _accountsBox.add(Account(name: _nameController.text));

                  //   user.accounts = HiveList(_accountsBox);

                  //   accounts.addAll(_accountsBox.values);

                  //   await user.save();

                  //   navigatorKey.currentState!.pop();
                  //   _nameController.clear();
                  // }
                },
                child: AppText(
                  text: 'OK',
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
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            content: Form(
              key: _accountNameFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RequiredText(
                    context.localizations.name_of_account_title,
                    // 'Name of Account'
                  ),
                  const Gap(12),
                  AppTextFormField(
                    controller: _nameController,
                    hintText: 'eg. ${context.localizations.primary}',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (_accountNameFormKey.currentState!.validate()) {
                    await ref
                        .read(userProvider.notifier)
                        .addAccount(_nameController.text);
                    navigatorKey.currentState!.pop();
                    _nameController.clear();
                    _valueNotifier.value = ref
                        .read(userProvider)
                        .user(_appStateUid)
                        .accounts!
                        .elementAt((_valueNotifier.value == null)
                            ? ref.read(accountsProvider)!.length - 1
                            : ref.read(accountsProvider)!.length - 2);
                  }
                },
                child: AppText(
                  text: context.localizations.ok,
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
        }
      },
    );
  }
}
