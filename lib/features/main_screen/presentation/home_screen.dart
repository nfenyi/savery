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
import 'package:savery/features/main_screen/streams/streams.dart';
import 'package:savery/features/transactions/presentation/transactions_screen.dart';
import 'package:savery/main.dart';

import '../../../app_constants/app_assets.dart';
import '../../../app_constants/app_constants.dart';
import '../../../app_widgets/widgets.dart';
import '../../sign_in/user_info/models/user_model.dart';
import 'widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Account? _selectedAccount;
  late DateTime? _dateHolder;

  final GlobalKey<FormState> _accountNameFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final db = FirebaseFirestore.instance;
  final _userBox = Hive.box<AppUser>(AppBoxes.user);
  final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  late final ValueNotifier<Account?> _valueNotifier;

  @override
  void initState() {
    super.initState();
    if (_accountsBox.values.isNotEmpty) {
      _selectedAccount = _accountsBox.values.first;
    }
    _valueNotifier = ValueNotifier(_selectedAccount);

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
        //TODO: change to the use of changenotifier provider
        StreamBuilder<List<Account>>(
            stream: accountsStream(),
            // .map(
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
            // )

            builder: (context, snapshot) {
              // logger.d(snapshot.connectionState);
              // _accountsBox.listenable().add
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const widgets.AppLoader();
              } else {
                if (snapshot.data!.isEmpty) {
                  return InkWell(
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
                                          text:
                                              'Tap here to create an account.')
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  );
                } else {
                  return CarouselSlider.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index, realIndex) {
                      final account = snapshot.data![index];
                      if (index != snapshot.data!.length - 1) {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                        initialPage: _selectedAccount == null
                            ? 0
                            : _accountsBox.values
                                .firstWhere((element) =>
                                    element.name == _selectedAccount!.name)
                                .key,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          _valueNotifier.value = snapshot.data![index];
                        },
                        viewportFraction: 0.85),
                  );
                }
              }
            }),
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
                            visible: value?.transactions != null ||
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
                      return Container(
                        color: Colors.white,
                        child: AppText(
                            text: (DateTime.now().day == _dateHolder?.day)
                                ? 'Today'
                                : (DateTime.now().weekday -
                                            _dateHolder!.weekday ==
                                        1)
                                    ? 'Yesterday'
                                    : AppFunctions.formatDate(
                                        _dateHolder.toString(),
                                        format: r'g:i A')),
                      );
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
            return StreamBuilder<List<AccountTransaction>>(
                stream: transactionsStream(value?.name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const widgets.AppLoader();
                  } else {
                    if (value?.transactions != null) {
                      final reversedTransactions =
                          value!.transactions!.reversed.toList();
                      return (snapshot.data!.isNotEmpty)
                          ? Expanded(
                              child: ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          AppSizes.horizontalPaddingSmall),
                                  itemBuilder: (context, index) {
                                    final transaction =
                                        reversedTransactions.toList()[index];
                                    return ListTile(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      tileColor: Colors.grey.shade100,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: 50,
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            child: Icon(
                                              getCategoryIcon(
                                                  transaction.category),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          AppText(
                                            text:
                                                '${transaction.type == 'Income' ? '+' : '-'} GHc ${transaction.amount.toString()}',
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
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    if (reversedTransactions[index]
                                            .date
                                            .difference(_dateHolder!) >
                                        const Duration(days: 6)) {
                                      // _dateHolder =
                                      //     value.transactions?[index].date;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          reversedTransactions[index].date.day;

                                      if (_dateHolder!.day == transactionDay) {
                                        return const Gap(10);
                                      } else {
                                        _dateHolder =
                                            reversedTransactions[index].date;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                  itemCount: snapshot.data!.length < 5
                                      ? snapshot.data!.length
                                      : 5),
                            )
                          : Center(
                              child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Lottie.asset(AppAssets.emptyList, height: 200),
                                const AppText(
                                    text:
                                        'Tap on the + button to add a  transaction.')
                              ],
                            ));
                    } else {
                      return Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Lottie.asset(AppAssets.emptyList, height: 200),
                          const AppText(
                              text:
                                  'Tap on the + button to add a  transaction.')
                        ],
                      ));
                    }
                  }
                });
          },
        )
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
                  if (_accountNameFormKey.currentState!.validate()) {
                    final user = _userBox.values.first;

                    await _accountsBox.add(Account(name: _nameController.text));

                    user.accounts = HiveList(_accountsBox);

                    user.accounts!.addAll(_accountsBox.values);

                    await user.save();
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
        } else {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            backgroundColor: Colors.white,
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
                    final user = _userBox.values.first;

                    await _accountsBox.add(Account(name: _nameController.text));
                    // logger.d(HiveList(_accountsBox));

                    user.accounts = HiveList(_accountsBox);

                    user.accounts!.addAll(_accountsBox.values);

                    await user.save();

                    // _accounts.isEmpty
                    //     ? await db
                    //         // .collection(FirestoreFieldNames.users)
                    //         .collection(FirestoreFieldNames.users)
                    //         // /${FirebaseAuth.instance.currentUser!.uid}/${FirestoreFieldNames.accounts}

                    //         .doc(FirebaseAuth.instance.currentUser!.uid)
                    //         .set({
                    //         FirestoreFieldNames.accounts: {
                    //           _nameController.text.trim(): {}
                    //         }
                    //       }).then((doc) {
                    //         widgets.showInfoToast('Account added!',
                    //             context: navigatorKey.currentContext!);
                    //       }).onError((error, _) {
                    //         widgets.showInfoToast(error.toString(),
                    //             context: navigatorKey.currentContext!);
                    //       })
                    //     : await db
                    //         .doc(
                    //             '${FirestoreFieldNames.users}/${FirebaseAuth.instance.currentUser!.uid}')
                    //         .update({
                    //         '${FirestoreFieldNames.accounts}.${_nameController.text.trim()}':
                    //             {}
                    //       }).then((doc) {
                    //         widgets.showInfoToast('Account added!',
                    //             context: navigatorKey.currentContext!);
                    //       }).onError((error, _) {
                    //         widgets.showInfoToast(error.toString(),
                    //             context: navigatorKey.currentContext!);
                    //       });
                    // _accounts.add(Account(
                    //     name: _nameController.text,
                    //     // availableBalance: 0,
                    //     expenses: 0,
                    //     income: 0,
                    //     transactions: []));

                    // await _accountsBox.add(Account(
                    //     name: _nameController.text,
                    //     // availableBalance: 0,
                    //     expenses: 0,
                    //     income: 0,
                    //     transactions: []));

                    navigatorKey.currentState!.pop();
                    _nameController.clear();
                    // setState(() {
                    //   valueNotifier.value = _accountsBox.values.last;
                    // });
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
