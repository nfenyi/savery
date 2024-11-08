import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:savery/app_constants/app_constants.dart';
import 'package:savery/features/main_screen/presentation/main_screen.dart';
import 'package:savery/features/sign_in/presentation/sign_in_screen.dart';
import 'package:savery/features/sign_in/user_info/models/user_model.dart';

import 'features/onboarding/presentation/onboarding_screen.dart';
import 'firebase_options.dart';

final Logger logger = Logger();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await Hive.initFlutter();
  await registerHiveAdpapters();

  await openBoxes();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: Savery()));
}

Future<void> registerHiveAdpapters() async {
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(TransactionAdapter());
}

Future<void> openBoxes() async {
  await Hive.openBox(AppBoxes.appState);
  await Hive.openBox<AppUser>(AppBoxes.user);
  await Hive.openBox<Account>(AppBoxes.accounts);
  await Hive.openBox<Budget>(AppBoxes.budgets);
  await Hive.openBox<AccountTransaction>(AppBoxes.transactions);
}

class Savery extends StatelessWidget {
  const Savery({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder:
        (BuildContext context, Orientation orientation, ScreenType screenType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: FToastBuilder(),
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: GoogleFonts.manrope(fontSize: 13).fontFamily,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scrollbarTheme: ScrollbarThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a purple toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            crossAxisMargin: 5,
            // thickness: 5,
            thumbColor: WidgetStateProperty.all(Colors.grey[400]),

            radius: const Radius.circular(10),
          ),
        ),
        navigatorKey: navigatorKey,
        // home: Consumer(builder: (context, ref, child) {
        //   //take care of displaying the loading screen
        //   ref.listen<bool>(isLoadingProvider, (_, isLoading) {
        //     if (isLoading) {
        //       LoadingScreen.instance().show(context: context);
        //     } else {
        //       LoadingScreen.instance().hide();
        //     }
        //   });
        home: const Wrapper(),
        // final isLoggedIn =
        //     ref.watch(authStateProvider).result == AuthResult.success;
        // if (isLoggedIn) {
        //   return const MainView();
        // } else {
        //   return const LoginView();
        // }
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
