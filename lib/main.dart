import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/features/main_screen/presentation/main_screen.dart';
import 'package:savery/features/new_transaction/models/transaction_category_model.dart';
import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';

import 'features/onboarding/presentation/onboarding_screen.dart';
import 'firebase_options.dart';
import 'themes/themes.dart';

final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await Hive.initFlutter();
  await registerHiveAdpapters();

  await openBoxes();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
//   // You may set the permission requests to "provisional" which allows the user to choose what type
// // of notifications they would like to receive once the user receives a notification.
// final notificationSettings =
  await FirebaseMessaging.instance.requestPermission(
//   // provisional: true
      );

// // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
// final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
// if (apnsToken != null) {
//  // APNS token is available, make FCM plugin API requests...
// }
  logger.d(await FirebaseMessaging.instance.getToken());
  runApp(const ProviderScope(child: Savery()));
}

Future<void> registerHiveAdpapters() async {
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionCategoryAdapter());
  Hive.registerAdapter(GoalAdapter());
}

Future<void> openBoxes() async {
  await Hive.openBox(AppBoxes.appState);
  await Hive.openBox<AppUser>(AppBoxes.user);
  await Hive.openBox<Account>(AppBoxes.accounts);
  await Hive.openBox<Budget>(AppBoxes.budgets);
  await Hive.openBox<AccountTransaction>(AppBoxes.transactions);
  await Hive.openBox<TransactionCategory>(AppBoxes.transactionsCategories);
  await Hive.openBox<Goal>(AppBoxes.goals);
}

class Savery extends StatelessWidget {
  const Savery({super.key});

  //TODO: there maybe an error when the device is not connected to the internet and is open for the
  //first time (onboarding)
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder:
        (BuildContext context, Orientation orientation, ScreenType screenType) {
      return Consumer(
        builder: (context, ref, child) {
          var theme = ref.watch(themeProvider);
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            builder: FToastBuilder(),

            title: 'Flutter Demo',
            themeMode: theme == 'System'
                ? ThemeMode.system
                : theme == 'Light'
                    ? ThemeMode.light
                    : ThemeMode.dark,
            // themeMode: ThemeMode.light,

            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            navigatorKey: navigatorKey,

            home: const Wrapper(),
          );
        },
      );
    });
  }
}

class Wrapper extends ConsumerWidget {
  const Wrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box(AppBoxes.appState).listenable(),
        builder: (context, appStateBox, child) {
          bool onboarded = appStateBox.get('onboarded', defaultValue: false);
          if (!onboarded) {
            return const OnboardingScreen();
          }
          bool authenticated =
              appStateBox.get('authenticated', defaultValue: false);

          if (!authenticated) {
            return const SignInScreen();
          } else {
            return const MainScreen();
          }
        },
      ),
    );
  }
}
