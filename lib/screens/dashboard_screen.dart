import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calorize/widgets/date_strip.dart';
import 'package:calorize/widgets/streak_icon.dart';
import 'package:isar/isar.dart';

import 'package:calorize/services/database_service.dart';
import 'package:calorize/services/food_sourcing_service.dart';
import 'package:calorize/widgets/dashboard_carousel.dart';
import 'package:calorize/widgets/recently_uploaded_list.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/food_log.dart';
import 'package:calorize/data/models/daily_stat.dart';
import 'package:calorize/widgets/food_edit_sheet.dart';
import 'package:calorize/screens/camera_logging_screen.dart';
import 'package:calorize/screens/settings/ai_providers_screen.dart';
import 'package:calorize/widgets/fab_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _streak = 0;
  UserProfile? _userProfile;
  DailyStat? _todayStat;
  Map<DateTime, bool> _weeklySuccess = {};

  StreamSubscription? _dailyStatsSubscription;

  @override
  void initState() {
    super.initState();
    _loadStreak();
    _loadUserProfile();
    _loadTodayStat();
    _loadWeeklySuccess();
    
    // Listen for changes in daily stats (e.g. when food is logged)
    _dailyStatsSubscription = DatabaseService().isar.dailyStats.watchLazy().listen((_) {
      _loadStreak();
      _loadTodayStat();
      _loadWeeklySuccess();
    });
  }

  @override
  void dispose() {
    _dailyStatsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadStreak() async {
    try {
      final streak = await DatabaseService().getCurrentStreak();
      if (mounted) {
        setState(() {
          _streak = streak;
        });
      }
    } catch (e) {
      debugPrint('Failed to load streak: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await DatabaseService().getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }

  Future<void> _loadTodayStat() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final stat = await DatabaseService().isar.dailyStats
          .filter()
          .dateEqualTo(today)
          .findFirst();
      if (mounted) {
        setState(() {
          _todayStat = stat;
        });
      }
    } catch (e) {
      debugPrint('Failed to load today stats: $e');
    }
  }

  Future<void> _loadWeeklySuccess() async {
    try {
      final success = await DatabaseService().getWeeklySuccessStatus();
      if (mounted) {
        setState(() {
          _weeklySuccess = success;
        });
      }
    } catch (e) {
      debugPrint('Failed to load weekly success status: $e');
    }
  }

  void _showStreakDetails() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF9F43),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '$_streak Day Streak!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have maintained a streak of $_streak days.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 Keep logging your meals every day to keep the flame burning! Consistency is key to reaching your goals.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Got it!',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleManualEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FoodEditSheet(),
    );
  }

  void _showAddOptionsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddOptionsSheet(
        onManualEntry: () {
          Navigator.pop(context);
          _handleManualEntry();
        },
        onBarcodeScan: () {
          Navigator.pop(context);
          _handleBarcodeScan();
        },
        onAiAnalysis: () {
          Navigator.pop(context);
          _handleAiAnalysis();
        },
      ),
    );
  }

  String _parseErrorMessage(String raw) {
    if (raw.contains('No AI providers')) {
      return 'No AI providers configured. Add one in Settings.';
    }
    if (raw.contains('API error: 401') || raw.contains('API error: 403')) {
      return 'Authentication failed. Check your API key.';
    }
    if (raw.contains('API error: 429')) {
      return 'Rate limit exceeded. Please try again later.';
    }
    if (raw.contains('API error: 5')) {
      return 'The AI provider server returned an error. Try again.';
    }
    if (raw.contains('Connection refused') || raw.contains('SocketException')) {
      return 'Could not connect to the AI provider. Check your internet connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  void _handleBarcodeScan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraLoggingScreen(initialBarcodeMode: true),
      ),
    );
  }

  Future<void> _handleAiAnalysis() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked != null && mounted) {
        final imageFile = File(picked.path);
        // Show context dialog
        final contextController = TextEditingController();
        try {
          final shouldAnalyze = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add Context'),
              content: TextField(
                controller: contextController,
                decoration: const InputDecoration(
                  hintText: 'e.g. "Lunch at a cafe", "Homemade pasta"',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Analyze'),
                ),
              ],
            ),
          );

          if (shouldAnalyze == true && mounted) {
            final userContextText = contextController.text;
            // Show progress indicator dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing image...'),
                      ],
                    ),
                  ),
                ),
              ),
            );

            try {
              final log = await FoodSourcingService().analyzeImage(
                imageFile,
                userContextText,
              );
              if (mounted) {
                Navigator.pop(context); // Dismiss progress dialog
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FoodEditSheet(initialLog: log),
                );
              }
            } catch (e) {
              if (mounted) {
                Navigator.pop(context);
                final errorMsg = e.toString();
                final userFriendlyMsg = _parseErrorMessage(errorMsg);

                await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Analysis Failed'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userFriendlyMsg),
                        if (userContextText.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text('Your context:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(userContextText, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: userContextText));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Context copied!')));
                        },
                        child: const Text('Copy Context'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Dismiss'),
                      ),
                      if (errorMsg.contains('No AI providers') || errorMsg.contains('API key'))
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AiProvidersScreen()));
                          },
                          child: const Text('Configure AI'),
                        ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _handleAiAnalysis();
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }
            }
          }
        } finally {
          contextController.dispose();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white 
            : Colors.black,
          foregroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.black 
            : Colors.white,
          onPressed: _showAddOptionsSheet,
          child: const Icon(Icons.add),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo & Title
                      Flexible(
                        child: Image.asset(
                          Theme.of(context).brightness == Brightness.dark 
                            ? 'assets/logo_text_dark.png' 
                            : 'assets/logo_text.png',
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Streak Icon
                      StreakIcon(
                        streakCount: _streak,
                        onTap: _showStreakDetails,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Date Strip
                DateStrip(successStatus: _weeklySuccess),
                
                // Rest of the dashboard content will go here
                const SizedBox(height: 24),
                StreamBuilder<List<FoodLog>>(
                  stream: DatabaseService().watchTodayFoodLogs(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load meals: ${snapshot.error}',
                          style: GoogleFonts.inter(color: Colors.red),
                        ),
                      );
                    }
                    final todayLogs = snapshot.data ?? [];
                    return DashboardCarousel(
                      userProfile: _userProfile,
                      todayLogs: todayLogs,
                      todayStat: _todayStat,
                    );
                  },
                ),
                const SizedBox(height: 24),
                const RecentlyUploadedList(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
