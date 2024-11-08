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
import 'package:iconsax/iconsax.dart';
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
import '../../../app_constants/app_constants.dart';
import '../../../app_widgets/widgets.dart';
import '../../sign_in/user_info/models/user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Box _accountsBox = Hive.box<Account>('accounts');

  Account? _selectedAccount;
  DateTime? _dateHolder;

  final GlobalKey<FormState> _accountNameFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

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
        StreamBuilder<BoxEvent>(
            stream: _accountsBox.watch(),
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

              {
                if (!snapshot.hasData) {
                  final accounts = _accountsBox.values.toList();
                  if (accounts.isEmpty) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      itemCount: accounts.length,
                      itemBuilder: (context, index, realIndex) {
                        final account = accounts[index];
                        if (index != accounts.length - 1) {
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
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _selectedAccount = accounts[index];
                            });
                          },
                          viewportFraction: 0.85),
                    );
                  }
                } else {
                  final accounts = _accountsBox.values.toList();
                  return CarouselSlider.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index, realIndex) {
                      final account = accounts[index];
                      if (index != accounts.length - 1) {
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
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _selectedAccount = accounts[index];
                          });
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
                  callback: () async {
                    await navigatorKey.currentState!.push(MaterialPageRoute(
                      builder: (context) => const TransactionsScreen(),
                    ));
                  })
            ],
          ),
        ),
        // AppText(
        //     text: AppFunctions.formatDate(DateTime.now().toString(),
        //         format: r'j M Y')),
        const Gap(5),
        (_selectedAccount != null)
            ? (_selectedAccount!.transactions == null)
                ? Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Lottie.asset(AppAssets.emptyList, height: 200),
                      const AppText(
                          text: 'Tap on the + button to add a transaction.')
                    ],
                  ))
                : SizedBox(
                    height: Adaptive.h(40),
                    child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.horizontalPaddingSmall),
                        itemBuilder: (context, index) {
                          final transaction =
                              _selectedAccount!.transactions![index];
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
                                  child: Icon(
                                    getIcon(transaction),
                                    color: AppColors.primary,
                                  )),
                            ),
                            title: AppText(text: transaction.type),
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
                                      transaction.date.toString(),
                                      format: r'g:i A'),
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          if (_selectedAccount!.transactions![index].date !=
                              _dateHolder) {
                            _dateHolder =
                                _selectedAccount!.transactions?[index].date;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Gap(5),
                                AppText(
                                    text: AppFunctions.formatDate(
                                        _selectedAccount!
                                            .transactions![index].date
                                            .toString(),
                                        format: r'j M Y')),
                                const Gap(5),
                              ],
                            );
                          } else {
                            return const Gap(10);
                          }
                        },
                        itemCount: _selectedAccount!.transactions!.length),
                  )
            : Center(
                child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Lottie.asset(AppAssets.emptyList, height: 200),
                  const AppText(
                      text: 'Tap on the + button to add a  transaction.')
                ],
              ))
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
                  //   // _accounts.add(Account(
                  //   //     name: _nameController.text,
                  //   //     // availableBalance: 0,
                  //   //     expenses: 0,
                  //   //     income: 0,
                  //   //     transactions: []));
                  //   // setState(() {
                  //   //   _selectedAccount =
                  //   //       _accounts.isEmpty ? null : _accounts.first;
                  //   });

                  // if (mounted) {
                  //   await db.collection(FirestoreFieldNames.users).add({
                  //     FirebaseAuth.instance.currentUser!.uid: {
                  //       FirestoreFieldNames.accounts: {
                  //         'name': _nameController.text.trim()
                  //       }
                  //     }
                  //   }).then((doc) {
                  //     widgets.showInfoToast('Account added!',
                  //         context: navigatorKey.currentContext!);
                  //   }, onError: (error) {
                  //     widgets.showInfoToast(error.toString(),
                  //         context: navigatorKey.currentContext!);
                  //   });
                  // }

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
                    final userBox = Hive.box<AppUser>(AppBoxes.user);
                    final user = userBox.values.first;

                    await _accountsBox.add(Account(name: _nameController.text));
                    user.accounts = HiveList(_accountsBox);

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
                    setState(() {
                      _selectedAccount = _accountsBox.values.last;
                    });
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

  IconData getIcon(AccountTransaction transaction) {
    switch (transaction.type) {
      case 'Gifts':
        return Iconsax.gift;

      case 'Health':
        return FontAwesomeIcons.stethoscope;
      case 'Car':
        return FontAwesomeIcons.car;
      case 'Game':
        return FontAwesomeIcons.chess;
      case 'Cafe':
        return FontAwesomeIcons.utensils;

      case 'Travel':
        return Iconsax.airplane;
      case 'Utility':
        return FontAwesomeIcons.lightbulb;
      case 'Care':
        return Icons.face_2;
      case 'Devices':
        return FontAwesomeIcons.tv;
      case 'Food':
        return FontAwesomeIcons.bowlFood;
      case 'Shopping':
        return FontAwesomeIcons.cartShopping;
      case 'Transport':
        return Iconsax.truck;

      default:
        return Iconsax.pen_add;
    }
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
    logger.d(Hive.box('app_state').values);
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Color.fromARGB(255, 224, 130, 186),
          Color.fromARGB(255, 156, 117, 233)
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Available Balance',
                isWhite: true,
              ),
              AppText(
                text: 'GHc TODO}',
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
                    color: Colors.grey.withOpacity(0.35),
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
                    color: Colors.grey.withOpacity(0.35),
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
