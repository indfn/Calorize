import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:calorize/theme/app_theme.dart';
import 'package:calorize/providers/theme_provider.dart';
import 'package:calorize/services/database_service.dart';

import 'package:calorize/screens/onboarding/get_started_screen.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/screens/home_screen.dart';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:calorize/screens/camera_logging_screen.dart';
import 'package:calorize/widgets/food_edit_sheet.dart';
import 'package:calorize/services/background_service.dart';
import 'package:calorize/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'calorize', url: '');
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.USA;

  await DatabaseService().init();
  await NotificationService().init();
  
  final isar = DatabaseService().isar;
  final userCount = await isar.userProfiles.count();

  final profile = await DatabaseService().getUserProfile();
  if (profile != null) {
    await NotificationService().scheduleDailyNotifications(profile);
  }
  
  // Update widgets on app start with latest data
  try {
    await BackgroundService().updateWidgetData();
  } catch (e) {
    debugPrint('Failed to update widgets on startup: $e');
  }
  
  runApp(MyApp(showOnboarding: userCount == 0));
}

class MyApp extends StatefulWidget {
  final bool showOnboarding;
  
  const MyApp({
    super.key, 
    required this.showOnboarding,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static const platform = MethodChannel('com.calorize.app/widget');

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onWidgetClick') {
        final String? uriString = call.arguments as String?;
        if (uriString != null && uriString.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 300));
          _handleLaunch(Uri.parse(uriString));
        }
      }
    });
  }

  void _handleLaunch(Uri? uri) {
    if (uri == null) return;
    
    Future.delayed(const Duration(milliseconds: 300), () {
      final context = _navigatorKey.currentContext;
      if (context == null) return;

      final scheme = uri.scheme;
      final host = uri.host;

      if (scheme == 'calorize' || host.isNotEmpty) {
        final action = host.isEmpty ? uri.path.replaceFirst('/', '') : host;
        
        if (action == 'scan_barcode') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CameraLoggingScreen(initialBarcodeMode: true),
            ),
          ).catchError((e) {
            debugPrint('Navigation error scan_barcode: $e');
          });
        } else if (action == 'scan_ai') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CameraLoggingScreen(initialBarcodeMode: false),
            ),
          ).catchError((e) {
            debugPrint('Navigation error scan_ai: $e');
          });
        } else if (action == 'manual_log') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const FoodEditSheet(),
          ).catchError((e) {
            debugPrint('BottomSheet error manual_log: $e');
          });
        } else if (action == 'dashboard') {
          // Just open the app to its normal state — no navigation needed
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          if (themeProvider.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Calorize',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: widget.showOnboarding ? const GetStartedScreen() : const HomeScreen(),
          );
        },
      ),
    );
  }
}
