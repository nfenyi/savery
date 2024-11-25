// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:savery/app_constants/app_constants.dart';
// import 'package:savery/features/sign_in/user_info/models/user_model.dart';

// import '../../../../main.dart';

// // basic information provider for getting data for inspection
// class UserNotifier extends StateNotifier<AppUser> {
  
//   UserNotifier() : super(Hive.box<AppUser>(AppBoxes.user).values.first);
//   final _userBox = Hive.box<AppUser>(AppBoxes.user);
//   final _accountsBox = Hive.box<Account>(AppBoxes.accounts);
  

//   void getUser() {
//     ref.read()
//     state = Hive.box<AppUser>(AppBoxes.user).values.first;
//   }

//   Future<void> addAccount(String accountName) async {
//     final user = _userBox.values.first;

//     await _accountsBox.add(Account(name: accountName));
//     // logger.d(HiveList(_accountsBox));

//     user.accounts = HiveList(_accountsBox);

//     user.accounts!.addAll(_accountsBox.values);

//     await user.save();

//     // _accounts.isEmpty
//     //     ? await db
//     //         // .collection(FirestoreFieldNames.users)
//     //         .collection(FirestoreFieldNames.users)
//     //         // /${FirebaseAuth.instance.currentUser!.uid}/${FirestoreFieldNames.accounts}

//     //         .doc(FirebaseAuth.instance.currentUser!.uid)
//     //         .set({
//     //         FirestoreFieldNames.accounts: {
//     //           _nameController.text.trim(): {}
//     //         }
//     //       }).then((doc) {
//     //         widgets.showInfoToast('Account added!',
//     //             context: navigatorKey.currentContext!);
//     //       }).onError((error, _) {
//     //         widgets.showInfoToast(error.toString(),
//     //             context: navigatorKey.currentContext!);
//     //       })
//     //     : await db
//     //         .doc(
//     //             '${FirestoreFieldNames.users}/${FirebaseAuth.instance.currentUser!.uid}')
//     //         .update({
//     //         '${FirestoreFieldNames.accounts}.${_nameController.text.trim()}':
//     //             {}
//     //       }).then((doc) {
//     //         widgets.showInfoToast('Account added!',
//     //             context: navigatorKey.currentContext!);
//     //       }).onError((error, _) {
//     //         widgets.showInfoToast(error.toString(),
//     //             context: navigatorKey.currentContext!);
//     //       });
//     // _accounts.add(Account(
//     //     name: _nameController.text,
//     //     // availableBalance: 0,
//     //     expenses: 0,
//     //     income: 0,
//     //     transactions: []));

//     // await _accountsBox.add(Account(
//     //     name: _nameController.text,
//     //     // availableBalance: 0,
//     //     expenses: 0,
//     //     income: 0,
//     //     transactions: []));

//     navigatorKey.currentState!.pop();
//     state.accounts = Hive.box<AppUser>(AppBoxes.user).values.first.accounts;

//     logger.d(state.accounts);
//     // setState(() {
//     //   valueNotifier.value = _accountsBox.values.last;
//     // });
//   }
// }

// final userProvider = StateNotifierProvider<UserNotifier, AppUser>(
//   (ref) => UserNotifier(),
// );

// final accountsProvider = Provider<HiveList<Account>?>(
//   (ref) {
//     logger.d(ref.read(userProvider).accounts);
//     return ref.watch(userProvider).accounts;
//   },
// );

// class Person {
//   String name;
//   int age;

//   Person(this.name, this.age);

//   @override
//   String toString() {
//     return 'name: $name, age: $age';
//   }

//   @override
//   bool operator ==(Object other) =>
//       // identical(this, other) ||
//       other is Person && name == other.name && age == other.age;
//   // runtimeType == other.runtimeType;

//   @override
//   int get hashCode => Object.hashAll([runtimeType, name, age]);
// }
