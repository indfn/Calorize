import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/utils/macro_calculator.dart';
import 'package:calorize/providers/theme_provider.dart';
import 'package:isar/isar.dart';
import 'package:calorize/services/notification_service.dart';
import 'package:calorize/screens/settings/weekly_macros_screen.dart';
import 'package:calorize/screens/settings/ai_providers_screen.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;
  int? _suggestedTdee;
  int? _suggestedProtein;
  int? _suggestedCarbs;
  int? _suggestedFat;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final isar = DatabaseService().isar;
    final profile = await isar.userProfiles.where().findFirst();
    
    // Legacy Data Fix: Ensure valid times and Timezone
    if (profile != null) {
      bool needsUpdate = false;
      
      // Fix 1: Timezone Migration (The -9223... fix)
      // If offset is outside reasonable bounds (-12 to +14), reset to 8 (Singapore)
      if (profile.utcOffset < -12 || profile.utcOffset > 14) {
        profile.utcOffset = 8; 
        needsUpdate = true;
      }

      // Fix 2: Notification Times
      if (profile.breakfastTime < 0 || profile.breakfastTime > 1439) {
        profile.breakfastTime = 480; needsUpdate = true;
      }
      if (profile.lunchTime < 0 || profile.lunchTime > 1439) {
        profile.lunchTime = 780; needsUpdate = true;
      }
      if (profile.dinnerTime < 0 || profile.dinnerTime > 1439) {
        profile.dinnerTime = 1140; needsUpdate = true;
      }

      if (needsUpdate) {
        await isar.writeTxn(() => isar.userProfiles.put(profile));
      }
    }
    
    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    if (_userProfile == null) return;

    final age = MacroCalculator.calculateAge(_userProfile!.dob!);
    final bmr = MacroCalculator.calculateBMR(
      weightKg: _userProfile!.weight!,
      heightCm: _userProfile!.height!,
      age: age,
      gender: _userProfile!.gender!,
    );
    final tdee = MacroCalculator.calculateTDEE(
      bmr: bmr,
      activityLevel: _userProfile!.activityLevel!,
    );
    final dailyTarget = MacroCalculator.calculateDailyTarget(
      tdee: tdee,
      goalType: _userProfile!.goalType!,
      weightLossRate: _userProfile!.weightLossRate ?? 0.5,
    );
    
    // Validate Percentages
    if (_userProfile!.proteinPercentage <= 0 || _userProfile!.carbsPercentage <= 0 || _userProfile!.fatPercentage <= 0) {
      final ratios = MacroCalculator.getRatiosForDiet(_userProfile!.dietPreference ?? 'Balanced');
      _userProfile!.proteinPercentage = ratios['protein']! * 100;
      _userProfile!.carbsPercentage = ratios['carbs']! * 100;
      _userProfile!.fatPercentage = ratios['fat']! * 100;
    }

    final micros = MacroCalculator.calculateMacros(
      targetCalories: dailyTarget,
      weightKg: _userProfile!.weight!,
      goalType: _userProfile!.goalType!,
      dietPreference: _userProfile!.dietPreference ?? 'Balanced',
      gender: _userProfile!.gender!,
      age: age,
    );

    _userProfile!
      ..tdeeGoal = dailyTarget
      ..proteinGoal = (dailyTarget * _userProfile!.proteinPercentage / 100) / 4
      ..fatGoal = (dailyTarget * _userProfile!.fatPercentage / 100) / 9
      ..carbsGoal = (dailyTarget * _userProfile!.carbsPercentage / 100) / 4
      ..fiberGoal = micros['fiber']
      ..sugarGoal = micros['sugar']
      ..sodiumGoal = micros['sodium'];

    final isar = DatabaseService().isar;
    await isar.writeTxn(() async {
      await isar.userProfiles.put(_userProfile!);
    });

    setState(() {}); 
  }

  Future<void> _lightSaveProfile() async {
    final isar = DatabaseService().isar;
    await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
  }

  void _calculateSuggested() {
    if (_userProfile == null ||
        _userProfile!.dob == null ||
        _userProfile!.weight == null ||
        _userProfile!.height == null ||
        _userProfile!.gender == null ||
        _userProfile!.activityLevel == null) return;
    final age = MacroCalculator.calculateAge(_userProfile!.dob!);
    final bmr = MacroCalculator.calculateBMR(
      weightKg: _userProfile!.weight!,
      heightCm: _userProfile!.height!,
      age: age,
      gender: _userProfile!.gender!,
    );
    final tdee = MacroCalculator.calculateTDEE(
      bmr: bmr,
      activityLevel: _userProfile!.activityLevel!,
    );
    _suggestedTdee = MacroCalculator.calculateDailyTarget(
      tdee: tdee,
      goalType: _userProfile!.goalType!,
      weightLossRate: _userProfile!.weightLossRate ?? 0.5,
    );
    final ratios = MacroCalculator.getRatiosForDiet(_userProfile!.dietPreference ?? 'Balanced');
    _suggestedProtein = ((_suggestedTdee! * ratios['protein']!) / 4).round();
    _suggestedCarbs = ((_suggestedTdee! * ratios['carbs']!) / 4).round();
    _suggestedFat = ((_suggestedTdee! * ratios['fat']!) / 9).round();
  }

  Future<void> _applyRecalculation(BuildContext ctx, {required bool applyToAllDays}) async {
    final oldTdee = _userProfile?.tdeeGoal ?? _suggestedTdee ?? 2000;

    await _updateProfile();

    if (applyToAllDays && _userProfile?.weeklyGoals != null && _userProfile!.weeklyGoals!.isNotEmpty) {
      final newTdee = _suggestedTdee ?? oldTdee;
      if (oldTdee > 0 && oldTdee != newTdee) {
        final ratio = newTdee / oldTdee;
        for (final goal in _userProfile!.weeklyGoals!) {
          if (goal.tdeeGoal != null) {
            goal.tdeeGoal = (goal.tdeeGoal! * ratio).round();
          }
        }
        final isar = DatabaseService().isar;
        await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
      }
    }

    if (ctx.mounted) Navigator.pop(ctx);
    setState(() {
      _hasUnsavedChanges = false;
      _suggestedTdee = null;
      _suggestedProtein = null;
      _suggestedCarbs = null;
      _suggestedFat = null;
    });
  }

  void _showRecalculationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggested Goals',
                  style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSuggestionRow('Calories', '$_suggestedTdee kcal', scheme),
                const SizedBox(height: 8),
                _buildSuggestionRow('Protein', '${_suggestedProtein ?? 0}g', scheme),
                const SizedBox(height: 8),
                _buildSuggestionRow('Carbs', '${_suggestedCarbs ?? 0}g', scheme),
                const SizedBox(height: 8),
                _buildSuggestionRow('Fat', '${_suggestedFat ?? 0}g', scheme),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _applyRecalculation(ctx, applyToAllDays: false),
                        child: const Text('Apply to Today'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _applyRecalculation(ctx, applyToAllDays: true),
                        child: const Text('Apply to All Days'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionRow(String label, String value, ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurfaceVariant)),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Future<void> _updateTheme(String mode) async {
    setState(() => _userProfile!.themeMode = mode);
    final isar = DatabaseService().isar;
    await isar.writeTxn(() async {
      await isar.userProfiles.put(_userProfile!);
    });
    if (mounted) {
      Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
    }
  }

  // ---------------------------------------------------------------------------
  // NEW CARD-BASED LAYOUT HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildSectionCard({required Widget child, ColorScheme? scheme}) {
    final s = scheme ?? Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: s.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _buildFieldRow(String label, String value, ColorScheme scheme, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 15, color: scheme.onSurfaceVariant)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: scheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavRow(String label, ColorScheme scheme, {String? subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Divider(height: 1, thickness: 0.5, color: scheme.outlineVariant.withValues(alpha: 0.3)),
    );
  }

  Widget _buildRecalBanner(ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Suggested goals available',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _hasUnsavedChanges = false),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'New goals: $_suggestedTdee cal/day  ·  P${_suggestedProtein ?? 0}g  ·  C${_suggestedCarbs ?? 0}g  ·  F${_suggestedFat ?? 0}g',
            style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: _showRecalculationSheet,
              child: const Text('View & Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ColorScheme scheme, bool isMetric) {
    final p = _userProfile!;
    return _buildSectionCard(
      scheme: scheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Manage your personal details and body metrics',
            style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          _buildFieldRow('Gender', p.gender!, scheme, onTap: () {
            _showOptionsPicker('Gender', ['Male', 'Female'], (val) async {
              setState(() => p.gender = val);
              await _lightSaveProfile();
              _calculateSuggested();
              if (mounted) setState(() => _hasUnsavedChanges = true);
            });
          }),
          _buildSectionDivider(scheme),
          _buildFieldRow('Height', _formatHeight(p.height!, isMetric), scheme,
              onTap: () => _showHeightPicker(isMetric)),
          _buildSectionDivider(scheme),
          _buildFieldRow('Weight', _formatWeight(p.weight!, isMetric), scheme,
              onTap: () => _showWeightPicker(isMetric)),
          _buildSectionDivider(scheme),
          _buildFieldRow('Activity Level', p.activityLevel!, scheme, onTap: () {
            _showOptionsPicker('Activity Level', ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active', 'Extra Active'], (val) async {
              setState(() => p.activityLevel = val);
              await _lightSaveProfile();
              _calculateSuggested();
              if (mounted) setState(() => _hasUnsavedChanges = true);
            });
          }),
          _buildSectionDivider(scheme),
          _buildFieldRow('Goal', p.goalType!.toUpperCase(), scheme, onTap: () {
            _showOptionsPicker('Goal', ['LOSE', 'MAINTAIN', 'GAIN'], (val) async {
              final newGoal = val.toLowerCase();
              setState(() {
                p.goalType = newGoal;
                final currentWeight = p.weight!;
                final targetWeight = p.targetWeight ?? currentWeight;
                if (newGoal == 'lose' && targetWeight > currentWeight) p.targetWeight = currentWeight;
                else if (newGoal == 'gain' && targetWeight < currentWeight) p.targetWeight = currentWeight;
                else if (newGoal == 'maintain') p.targetWeight = currentWeight;
              });
              await _lightSaveProfile();
              _calculateSuggested();
              if (mounted) setState(() => _hasUnsavedChanges = true);
            });
          }),
          _buildSectionDivider(scheme),
          _buildFieldRow('Diet Preference', p.dietPreference ?? 'Balanced', scheme, onTap: () {
            _showOptionsPicker('Diet Preference', ['Balanced', 'Low Fat', 'Low Carb', 'High Protein', 'Custom'], (val) async {
              setState(() {
                p.dietPreference = val;
                final ratios = MacroCalculator.getRatiosForDiet(val);
                p.proteinPercentage = (ratios['protein']! * 100);
                p.carbsPercentage = (ratios['carbs']! * 100);
                p.fatPercentage = (ratios['fat']! * 100);
              });
              await _lightSaveProfile();
              _calculateSuggested();
              if (mounted) setState(() => _hasUnsavedChanges = true);
            });
          }),
          _buildSectionDivider(scheme),
          _buildFieldRow('Target Weight', _formatWeight(p.targetWeight ?? p.weight!, isMetric), scheme,
              onTap: () => _showTargetWeightPicker(isMetric)),
          if (p.goalType != 'maintain') ...[
            _buildSectionDivider(scheme),
            _buildFieldRow('Weekly Pace', _formatWeeklyPace(p.weightLossRate ?? 0.5, isMetric), scheme,
                onTap: () => _showWeeklyPacePicker(isMetric)),
          ],
          _buildSectionDivider(scheme),
          _buildNavRow('AI Providers', scheme,
            subtitle: p.aiProviders != null && p.aiProviders!.isNotEmpty
                ? '${p.aiProviders!.length} provider(s) configured'
                : 'Not Configured',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiProvidersScreen()),
              ).then((_) => _loadProfile());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsMacrosCard(ColorScheme scheme) {
    return _buildSectionCard(
      scheme: scheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Goals & Macros', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Adjust your daily and weekly nutrition targets',
            style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          _buildNavRow('Customize Weekly Goals', scheme,
            subtitle: 'Set different goals per day of the week',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyMacrosScreen(profile: _userProfile!),
                ),
              ).then((_) => _loadProfile());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(ColorScheme scheme) {
    final p = _userProfile!;
    return _buildSectionCard(
      scheme: scheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Manage meal reminder alerts',
            style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Enable Meal Reminders', style: GoogleFonts.inter(fontSize: 15)),
            subtitle: Text('Get reminded to log your meals', style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurfaceVariant)),
            value: p.notificationsEnabled,
            onChanged: (value) async {
              setState(() => p.notificationsEnabled = value);
              final isar = DatabaseService().isar;
              await isar.writeTxn(() => isar.userProfiles.put(p));
              await NotificationService().scheduleDailyNotifications(p);
            },
          ),
          if (p.notificationsEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildFieldRow('Breakfast', _formatTime(p.breakfastTime), scheme, onTap: () {
                _showTimePicker('Select Breakfast Time', p.breakfastTime, (minutes) async {
                  setState(() => p.breakfastTime = minutes);
                  final isar = DatabaseService().isar;
                  await isar.writeTxn(() => isar.userProfiles.put(p));
                  await NotificationService().scheduleDailyNotifications(p);
                });
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildFieldRow('Lunch', _formatTime(p.lunchTime), scheme, onTap: () {
                _showTimePicker('Select Lunch Time', p.lunchTime, (minutes) async {
                  setState(() => p.lunchTime = minutes);
                  final isar = DatabaseService().isar;
                  await isar.writeTxn(() => isar.userProfiles.put(p));
                  await NotificationService().scheduleDailyNotifications(p);
                });
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildFieldRow('Dinner', _formatTime(p.dinnerTime), scheme, onTap: () {
                _showTimePicker('Select Dinner Time', p.dinnerTime, (minutes) async {
                  setState(() => p.dinnerTime = minutes);
                  final isar = DatabaseService().isar;
                  await isar.writeTxn(() => isar.userProfiles.put(p));
                  await NotificationService().scheduleDailyNotifications(p);
                });
              }),
            ),
            const SizedBox(height: 8),
            _buildNavRow('Notifications not working?', scheme,
              subtitle: 'Some devices require special permissions. Check the guide for your phone brand.',
              onTap: () async {
                final uri = Uri.parse('https://dontkillmyapp.com');
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('Failed to launch URL: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open browser. Please visit dontkillmyapp.com manually.')),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(ColorScheme scheme) {
    final p = _userProfile!;
    return _buildSectionCard(
      scheme: scheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferences', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Theme, rollover behaviour, and success criteria',
            style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Dark Mode', style: GoogleFonts.inter(fontSize: 15)),
            secondary: Icon(
              p.themeMode == 'dark' || 
              (p.themeMode == 'system' && 
               MediaQuery.platformBrightnessOf(context) == Brightness.dark)
                  ? Icons.dark_mode 
                  : Icons.light_mode,
              color: scheme.onSurfaceVariant,
            ),
            value: p.themeMode == 'dark' || 
                (p.themeMode == 'system' && 
                 MediaQuery.platformBrightnessOf(context) == Brightness.dark),
            onChanged: (bool value) {
              _updateTheme(value ? 'dark' : 'light');
            },
          ),
          _buildSectionDivider(scheme),
          const SizedBox(height: 4),
          Text(
            'Daily Success Criteria',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enable Calorie Rollover', style: GoogleFonts.inter(fontSize: 15)),
                    Text('Balance calories across days', style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: p.rolloverEnabled,
                activeColor: scheme.primary,
                onChanged: (value) async {
                  setState(() => p.rolloverEnabled = value);
                  final isar = DatabaseService().isar;
                  await isar.writeTxn(() => isar.userProfiles.put(p));
                },
              ),
            ],
          ),
          if (p.rolloverEnabled) ...[
            const SizedBox(height: 8),
            Text(
              'Rollover Limit: ${p.maxRollover.clamp(50, 200)} cal',
              style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurfaceVariant),
            ),
            Slider(
              value: p.maxRollover.clamp(50, 200).toDouble(),
              min: 50, max: 200, divisions: 30,
              activeColor: scheme.primary,
              label: '${p.maxRollover} cal',
              onChanged: (value) { setState(() { p.maxRollover = value.round(); }); },
              onChangeEnd: (value) async {
                final isar = DatabaseService().isar;
                await isar.writeTxn(() => isar.userProfiles.put(p));
              },
            ),
          ],
          const SizedBox(height: 12),
          Text(
            'Success Tolerance: ±${p.successTolerance.clamp(50, 200)} cal',
            style: GoogleFonts.inter(fontSize: 14, color: scheme.onSurfaceVariant),
          ),
          Text(
            'Range to keep streak alive: Base Goal ± Tolerance',
            style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurfaceVariant, fontStyle: FontStyle.italic),
          ),
          Slider(
            value: p.successTolerance.clamp(50, 200).toDouble(),
            min: 50, max: 200, divisions: 30,
            activeColor: scheme.primary,
            label: '±${p.successTolerance} cal',
            onChanged: (value) { setState(() => p.successTolerance = value.round()); },
            onChangeEnd: (value) async {
              final isar = DatabaseService().isar;
              await isar.writeTxn(() => isar.userProfiles.put(p));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementCard(ColorScheme scheme) {
    return _buildSectionCard(
      scheme: scheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Management', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Export, backup, or reset your data',
            style: GoogleFonts.inter(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          _buildNavRow('Export Food Logs', scheme,
            subtitle: 'Share your data as JSON',
            onTap: _exportFoodLogs,
          ),
          _buildSectionDivider(scheme),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset All Data?'),
                  content: const Text(
                    'This will delete all your food logs, progress tracking, and reset your profile. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        await DatabaseService().resetAllData();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/get-started', (route) => false);
                        }
                      },
                      child: const Text('Reset All Data'),
                    ),
                  ],
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reset All Data', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red)),
                        Text('Delete all logs and profile', style: GoogleFonts.inter(fontSize: 12, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: Colors.red.withValues(alpha: 0.6)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // END NEW CARD-BASED LAYOUT HELPERS
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_userProfile == null) return const Center(child: Text('No Profile Found'));

    final isMetric = _userProfile!.isMetric ?? true;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        children: [
          if (_hasUnsavedChanges && _suggestedTdee != null)
            _buildRecalBanner(scheme),
          _buildProfileCard(scheme, isMetric),
          const SizedBox(height: 16),
          _buildGoalsMacrosCard(scheme),
          const SizedBox(height: 16),
          _buildNotificationsCard(scheme),
          const SizedBox(height: 16),
          _buildPreferencesCard(scheme),
          const SizedBox(height: 16),
          _buildDataManagementCard(scheme),
        ],
      ),
    );
  }

  Future<void> _exportFoodLogs() async {
    try {
      final json = await DatabaseService().exportFoodLogsAsJson();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/calorize_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], text: 'Calorize Food Logs Export');
      await file.delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  // --- HELPER METHODS & PICKERS ---

  String _formatHeight(double cm, bool isMetric) {
    if (isMetric) {
      return '${cm.toStringAsFixed(1)} cm';
    } else {
      final inchesTotal = cm / 2.54;
      final feet = (inchesTotal / 12).floor();
      final inches = (inchesTotal % 12).round();
      return '$feet\' $inches"';
    }
  }

  String _formatWeight(double kg, bool isMetric) {
    if (isMetric) {
      return '${kg.toStringAsFixed(1)} kg';
    } else {
      final lbs = kg * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
  }

  void _showOptionsPicker(String title, List<String> options, Function(String) onSave) {
    String? currentValue;
    int initialIndex = 0;
    
    if (title == 'Gender') currentValue = _userProfile!.gender;
    if (title == 'Activity Level') currentValue = _userProfile!.activityLevel;
    if (title == 'Goal') currentValue = _userProfile!.goalType!.toUpperCase();
    if (title == 'Diet Preference') currentValue = _userProfile!.dietPreference;
    
    if (currentValue != null && options.contains(currentValue)) {
      initialIndex = options.indexOf(currentValue);
    }
    
    String selectedValue = options[initialIndex];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(initialItem: initialIndex),
                    onSelectedItemChanged: (index) {
                      setModalState(() => selectedValue = options[index]);
                    },
                    children: options.map((o) => Center(child: Text(o))).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          onSave(selectedValue);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          );
        }
      ),
    );
  }

  void _showHeightPicker(bool initialMetric) {
    bool isMetric = initialMetric;
    double currentCm = _userProfile!.height!;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: SizedBox(
              height: 300,
              child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('CM'),
                    Switch(
                      value: !isMetric,
                      onChanged: (val) => setModalState(() => isMetric = !val),
                    ),
                    const Text('FT'),
                  ],
                ),
                Expanded(
                  child: isMetric
                    ? CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(initialItem: currentCm.toInt() - 100),
                        onSelectedItemChanged: (index) {
                          currentCm = (index + 100).toDouble();
                        },
                        children: List.generate(150, (index) => Center(child: Text('${index + 100} cm'))),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 32,
                              scrollController: FixedExtentScrollController(initialItem: (currentCm / 2.54 / 12).floor() - 1),
                              onSelectedItemChanged: (index) {
                                int feet = index + 1;
                                int inches = ((currentCm / 2.54) % 12).round();
                                currentCm = ((feet * 12) + inches) * 2.54;
                              },
                              children: List.generate(8, (index) => Center(child: Text('${index + 1} ft'))),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 32,
                              scrollController: FixedExtentScrollController(initialItem: ((currentCm / 2.54) % 12).round()),
                              onSelectedItemChanged: (index) {
                                int feet = (currentCm / 2.54 / 12).floor();
                                currentCm = ((feet * 12) + index) * 2.54;
                              },
                              children: List.generate(12, (index) => Center(child: Text('$index in'))),
                            ),
                          ),
                        ],
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          setState(() {
                            _userProfile!.height = currentCm;
                            _userProfile!.isMetric = isMetric;
                          });
                          await _lightSaveProfile();
                          _calculateSuggested();
                          if (mounted) {
                            setState(() => _hasUnsavedChanges = true);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          );
        }
      ),
    );
  }

  void _showWeightPicker(bool initialMetric) {
    bool isMetric = initialMetric;
    double currentKg = _userProfile!.weight!;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: SizedBox(
              height: 300,
              child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('KG'),
                    Switch(
                      value: !isMetric,
                      onChanged: (val) => setModalState(() => isMetric = !val),
                    ),
                    const Text('LBS'),
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: isMetric ? currentKg.toInt() - 30 : (currentKg * 2.20462).round() - 66
                    ),
                    onSelectedItemChanged: (index) {
                      if (isMetric) {
                        currentKg = (index + 30).toDouble();
                      } else {
                        currentKg = (index + 66) * 0.453592;
                      }
                    },
                    children: List.generate(
                      300, 
                      (index) => Center(child: Text(isMetric ? '${index + 30} kg' : '${index + 66} lbs'))
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          setState(() {
                            _userProfile!.weight = currentKg;
                            _userProfile!.isMetric = isMetric;
                          });
                          await _lightSaveProfile();
                          _calculateSuggested();
                          if (mounted) {
                            setState(() => _hasUnsavedChanges = true);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          );
        }
      ),
    );
  }

  String _formatWeeklyPace(double kgPerWeek, bool isMetric) {
    if (isMetric) {
      return '${kgPerWeek.toStringAsFixed(2)} kg/week';
    } else {
      final lbsPerWeek = kgPerWeek * 2.20462;
      return '${lbsPerWeek.toStringAsFixed(2)} lbs/week';
    }
  }

  void _showTargetWeightPicker(bool initialMetric) {
    bool isMetric = initialMetric;
    final goalType = _userProfile!.goalType!;
    final userWeightKg = _userProfile!.weight!;
    double currentKg = _userProfile!.targetWeight ?? userWeightKg;

    if (goalType == 'lose' && currentKg > userWeightKg) {
      currentKg = userWeightKg;
    } else if (goalType == 'gain' && currentKg < userWeightKg) {
      currentKg = userWeightKg;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int minVal, maxVal;
          int currentVal;

          if (isMetric) {
            if (goalType == 'lose') {
              minVal = 30;
              maxVal = userWeightKg.floor();
            } else if (goalType == 'gain') {
              minVal = userWeightKg.ceil();
              maxVal = 300;
            } else { 
              minVal = 30;
              maxVal = 300;
            }
            currentVal = currentKg.round();
          } else {
            int weightLbs = (userWeightKg * 2.20462).round();
            if (goalType == 'lose') {
              minVal = 66;
              maxVal = weightLbs;
            } else if (goalType == 'gain') {
              minVal = weightLbs;
              maxVal = 660;
            } else { 
              minVal = 66;
              maxVal = 660;
            }
            currentVal = (currentKg * 2.20462).round();
          }

          if (currentVal < minVal) currentVal = minVal;
          if (currentVal > maxVal) currentVal = maxVal;

          int itemCount = maxVal - minVal + 1;

          return SafeArea(
            child: SizedBox(
              height: 300,
              child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('KG'),
                    Switch(
                      value: !isMetric,
                      onChanged: (val) => setModalState(() => isMetric = !val),
                    ),
                    const Text('LBS'),
                  ],
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: currentVal - minVal
                    ),
                    onSelectedItemChanged: (index) {
                      if (isMetric) {
                        currentKg = (minVal + index).toDouble();
                      } else {
                        double valLbs = (minVal + index).toDouble();
                        currentKg = valLbs * 0.453592;
                      }
                    },
                    children: List.generate(
                      itemCount, 
                      (index) => Center(child: Text(isMetric ? '${minVal + index} kg' : '${minVal + index} lbs'))
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          setState(() {
                            _userProfile!.targetWeight = currentKg;
                            _userProfile!.isMetric = isMetric;
                          });
                          await _lightSaveProfile();
                          _calculateSuggested();
                          if (mounted) {
                            setState(() => _hasUnsavedChanges = true);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          );
        }
      ),
    );
  }

  void _showWeeklyPacePicker(bool initialMetric) {
    bool isMetric = initialMetric;
    final goalType = _userProfile!.goalType!;
    
    double minKg = 0.2;
    double maxKg = goalType == 'lose' ? 0.9 : 0.5;

    double currentKg = _userProfile!.weightLossRate ?? 0.5;
    if (currentKg < minKg) currentKg = minKg;
    if (currentKg > maxKg) currentKg = maxKg;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          int divisions;
          if (isMetric) {
            divisions = goalType == 'lose' 
              ? ((maxKg - minKg) / 0.1).round() 
              : ((maxKg - minKg) / 0.05).round();
          } else {
            double minLbs = minKg * 2.20462;
            double maxLbs = maxKg * 2.20462;
            divisions = ((maxLbs - minLbs) / 0.1).round();
          }

          String rateDisplay;
          if (isMetric) {
            rateDisplay = '${currentKg.toStringAsFixed(2)} kg / week';
          } else {
            double rateLbs = currentKg * 2.20462;
            rateDisplay = '${rateLbs.toStringAsFixed(1)} lbs / week';
          }

          return AlertDialog(
            title: const Text('Weekly Pace'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('KG'),
                    Switch(
                      value: !isMetric,
                      onChanged: (val) => setDialogState(() => isMetric = !val),
                    ),
                    const Text('LBS'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  rateDisplay,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: currentKg,
                  min: minKg,
                  max: maxKg,
                  divisions: divisions > 0 ? divisions : 1,
                  label: isMetric 
                    ? '${currentKg.toStringAsFixed(2)} kg'
                    : '${(currentKg * 2.20462).toStringAsFixed(1)} lbs',
                  onChanged: (val) => setDialogState(() => currentKg = val),
                ),
                const SizedBox(height: 8),
                Text(
                  goalType == 'lose' 
                    ? (isMetric ? 'Recommended: 0.5 kg/week' : 'Recommended: 1.1 lbs/week')
                    : (isMetric ? 'Recommended: 0.25 kg/week' : 'Recommended: 0.5 lbs/week'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  setState(() {
                    _userProfile!.weightLossRate = currentKg;
                    _userProfile!.isMetric = isMetric;
                  });
                          await _lightSaveProfile();
                          _calculateSuggested();
                          if (mounted) {
                            setState(() => _hasUnsavedChanges = true);
                            Navigator.pop(context);
                          }
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _showTimePicker(String title, int initialMinutes, Function(int) onSaved) async {
    final validMinutes = initialMinutes.clamp(0, 1439);
    int selectedHour = validMinutes ~/ 60;
    int selectedMinute = validMinutes % 60;

    await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 32,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedHour,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedHour = index);
                            },
                            children: List.generate(
                              24,
                              (index) => Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 32,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedMinute,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() => selectedMinute = index);
                            },
                            children: List.generate(
                              60,
                              (index) => Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            final newMinutes = selectedHour * 60 + selectedMinute;
                            onSaved(newMinutes);
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(int minutes) {
    final validMinutes = minutes.clamp(0, 1439);
    final h = validMinutes ~/ 60;
    final m = validMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
