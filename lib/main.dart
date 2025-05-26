import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:optionxi/Auth_Service/auth_service.dart';
import 'package:optionxi/Helpers/get_database.dart';
import 'package:optionxi/Login_Signup/login.dart';
import 'package:optionxi/Main_Pages/act_alert_stocks.dart';
import 'package:optionxi/Main_Pages/act_scanner_result.dart';
import 'package:optionxi/Main_Pages/act_search_stocks.dart';
import 'package:optionxi/Main_Pages/act_stock_detail.dart';
import 'package:optionxi/PushNotification/notifcation_service.dart';
import 'package:optionxi/PushNotification/notifcation_service_firebase.dart';
import 'package:optionxi/Theme/theme_controller.dart';
import 'package:optionxi/homepage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialisation
  await dotenv.load(); // Load .env file

  try {
    await Firebase.initializeApp();
    // Initialize StockService with your Supabase credentials
    await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!);

    await Get.put(Database()).initStorage();

    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
    // FirebaseDatabase.instance.setPersistenceEnabled(true);
    // await FirebaseAppCheck.instance.activate();
    await NotificationService().initNotification();
    await NotificationServiceFirebase().initNotificationFirebase();
    // await MobileAds.instance.initialize();

    await FirebaseRemoteConfig.instance.fetchAndActivate();
  } catch (e) {}

  // ALWAYS put ThemeController after other risky initializations
  final themeController = Get.put(ThemeController());
  await themeController.initTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    _testSetUserProperty();

    return GetX<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Option Xi',
          debugShowCheckedModeBanner: false,
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode:
              themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AuthService().handleAuthState(),
          getPages: [
            GetPage(name: '/home', page: () => Homepage()),
            GetPage(name: '/login', page: () => ModernTradingLoginPage()),
            GetPage(name: '/stocks', page: () => StockSearchPage(false)),
            GetPage(
              name: '/stocks/:stockName',
              page: () {
                final stockName = Get.parameters['stockName'] ?? '';
                return StockDetailPage(stockname: stockName);
              },
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: '/alerts/:stockName',
              page: () {
                final stockName = Get.parameters['stockName'];
                return StockAlertsPage(stockName);
              },
              transition: Transition.rightToLeft,
            ),
            GetPage(
              name: '/scanners/:scanName',
              page: () {
                final scanName = Get.parameters['scanName'] ?? '';
                final arguments = Get.arguments as Map<String, dynamic>?;
                final category = arguments?['category'] as String?;

                return ScannerDetailPage(
                  scanName: scanName,
                  category: category,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _testSetUserProperty() async {
    await analytics.setUserProperty(name: 'regular', value: 'user');
  }
}
