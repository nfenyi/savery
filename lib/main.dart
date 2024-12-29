import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:savery/features/main_screen/state/localization.dart';
import 'package:savery/notifications/models/notification_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:secure_application/secure_application.dart';
import 'notifications/apis/firebase_notifications_api.dart';
import 'themes/themes.dart';
import 'l10n/l10n.dart';
import 'package:firebase_core/firebase_core.dart';
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

final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await registerHiveAdpapters();

    await openBoxes();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    runApp(const ProviderScope(child: Savery()));
    await FirebaseNotificationsApi().initNotifications();
  } on FirebaseException catch (e) {
    // error is thrown when launching app for the first time and internet is off
    //message: [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: Exception: [firebase_messaging/unknown] java.io.IOException: java.util.concurrent.ExecutionException: java.io.IOException: SERVICE_NOT_AVAILABLE
    if ( //commenting out to make it more generic
        // e.plugin == "firebase_messaging" &&
        e.message != null && e.message!.contains('SERVICE_NOT_AVAILABLE')) {
      await Hive.box(AppBoxes.appState).put(
        'firebaseServiceNotAvailable',
        true,
      );
    }
  }
}

Future<void> registerHiveAdpapters() async {
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(TransactionCategoryAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(NotificationAdapter());
}

Future<void> openBoxes() async {
  await Hive.openBox(AppBoxes.appState);
  await Hive.openBox<AppUser>(AppBoxes.users);
  await Hive.openBox<Account>(AppBoxes.accounts);
  await Hive.openBox<Budget>(AppBoxes.budgets);
  await Hive.openBox<AppNotification>(AppBoxes.notifications);
  await Hive.openBox<AccountTransaction>(AppBoxes.transactions);
  await Hive.openBox<TransactionCategory>(AppBoxes.transactionsCategories);
  await Hive.openBox<Goal>(AppBoxes.goals);
}

class Savery extends StatelessWidget {
  const Savery({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder:
        (BuildContext context, Orientation orientation, ScreenType screenType) {
      return Consumer(
        builder: (context, ref, child) {
          var theme = ref.watch(themeProvider);

          return Portal(
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              builder: FToastBuilder(),
              supportedLocales: L10n.all,
              locale: ref.watch(languageProvider) == 'Français'
                  ? const Locale('fr')
                  : const Locale('en'),

              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
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
            ),
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
