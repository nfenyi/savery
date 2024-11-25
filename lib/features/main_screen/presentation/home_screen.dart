import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart' as d_border;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_colors.dart';
import 'package:savery/app_constants/app_sizes.dart';
import 'package:savery/app_functions/app_functions.dart';
import 'package:savery/app_widgets/app_text.dart';
import 'package:savery/app_widgets/widgets.dart' as widgets;
import 'package:savery/features/transactions/presentation/transactions_screen.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_assets.dart';
import '../../../app_widgets/widgets.dart';
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

  @override
  void initState() {
    super.initState();

    _valueNotifier = ValueNotifier(ref.read(userProvider).user.accounts?.first);

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
    final AppUser user = ref.watch(userProvider).user;
    final HiveList<Account>? accounts = ref.watch(accountsProvider);
    // HiveList<Account>? accounts = ref.watch(accountsProvider);
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

        (accounts == null || user.accounts!.isEmpty)
            ? InkWell(
                onTap: () async {
                  await showAccountDialog(context);
                },
                child: Ink(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.horizontalPaddingSmall),
                    child: d_border.DottedBorder(
                        color: AppColors.primary,
                        borderType: d_border.BorderType.RRect,
                        radius: const Radius.circular(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: Adaptive.w(90),
                              height: 200,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: AppColors.primary,
                                    // size: 5,
                                  ),
                                  Gap(10),
                                  AppText(
                                      text: 'Tap here to create an account.')
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
                          InkWell(
                            onTap: () async {
                              await showAccountDialog(context);
                            },
                            child: Ink(
                              child: d_border.DottedBorder(
                                  color: AppColors.primary,
                                  borderType: d_border.BorderType.RRect,
                                  radius: const Radius.circular(10),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_circle,
                                        color: AppColors.primary,
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
                    initialPage: _valueNotifier.value == null
                        ? 0
                        : _valueNotifier.value!.key,
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
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      text: 'Transactions',
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
                          text: 'View All',
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
                          text: (DateTime.now().day == _dateHolder?.day)
                              ? 'Today'
                              : (DateTime.now().weekday -
                                          _dateHolder!.weekday ==
                                      1)
                                  ? 'Yesterday'
                                  : AppFunctions.formatDate(
                                      _dateHolder.toString(),
                                      format: r'g:i A'));
                    }),
                const Gap(5)
              ],
            ),
          ),
        ),
        //TODO: fix streambuilder not listening to transaction addition
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
                              color: Colors.grey.shade100,
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
                        if (reversedTransactions[index]
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
                                      reversedTransactions[index]
                                          .date
                                          .toString(),
                                      format: r'j M Y')),
                              const Gap(5),
                            ],
                          );
                        } else {
                          final transactionDay =
                              reversedTransactions[index].date.weekday;

                          if (_dateHolder!.weekday == transactionDay) {
                            // logger.d(reversedTransactions[index].description);
                            return const Gap(10);
                          } else {
                            _dateHolder = reversedTransactions[index].date;
                            // logger.d(reversedTransactions[index].description);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(5),
                                AppText(
                                    text: AppFunctions.formatDate(
                                        reversedTransactions[index]
                                            .date
                                            .toString(),
                                        format: 'l')),
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
                return Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Lottie.asset(AppAssets.emptyList, height: 200),
                    const AppText(
                        text: 'Tap on the + button to add a  transaction.')
                  ],
                ));
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
                  const RequiredText('Name of Account'),
                  const Gap(12),
                  AppTextFormField(
                    controller: _nameController,
                    hintText: 'eg. Primary',
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
                child: const AppText(
                  text: 'OK',
                  color: AppColors.primary,
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
            // backgroundColor: Colors.white,
            content: Form(
              key: _accountNameFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RequiredText('Name of Account'),
                  const Gap(12),
                  AppTextFormField(
                    controller: _nameController,
                    hintText: 'eg. Primary',
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
                  }
                },
                child: const AppText(
                  text: 'OK',
                  color: AppColors.primary,
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
