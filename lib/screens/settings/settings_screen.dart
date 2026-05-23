import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/utils/macro_calculator.dart';
import 'package:calorize/providers/theme_provider.dart';
import 'package:calorize/widgets/macro_sliders.dart';
import 'package:isar/isar.dart';
import 'package:calorize/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;

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

    final age = DateTime.now().year - _userProfile!.dob!.year;
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
       _userProfile!.proteinPercentage = 30;
       _userProfile!.carbsPercentage = 40;
       _userProfile!.fatPercentage = 30;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_userProfile == null) return const Center(child: Text('No Profile Found'));

    final isMetric = _userProfile!.isMetric ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- PROFILE ---
          ExpansionTile(
            title: const Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              _buildEditableTile('Gender', _userProfile!.gender!, (val) {
                setState(() => _userProfile!.gender = val);
                _updateProfile();
              }, isPicker: true, options: ['Male', 'Female']),
              
              _buildEditableTile('Height', _formatHeight(_userProfile!.height!, isMetric), (val) {}, onTap: () => _showHeightPicker(isMetric)),
              _buildEditableTile('Weight', _formatWeight(_userProfile!.weight!, isMetric), (val) {}, onTap: () => _showWeightPicker(isMetric)),
              _buildEditableTile('Activity Level', _userProfile!.activityLevel!, (val) {
                setState(() => _userProfile!.activityLevel = val);
                _updateProfile();
              }, isPicker: true, options: ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active', 'Extra Active']),
              _buildEditableTile('Goal', _userProfile!.goalType!.toUpperCase(), (val) {
                final newGoal = val.toLowerCase();
                setState(() {
                  _userProfile!.goalType = newGoal;
                  final currentWeight = _userProfile!.weight!;
                  final targetWeight = _userProfile!.targetWeight ?? currentWeight;
                  if (newGoal == 'lose' && targetWeight > currentWeight) _userProfile!.targetWeight = currentWeight;
                  else if (newGoal == 'gain' && targetWeight < currentWeight) _userProfile!.targetWeight = currentWeight;
                  else if (newGoal == 'maintain') _userProfile!.targetWeight = currentWeight;
                });
                _updateProfile();
              }, isPicker: true, options: ['LOSE', 'MAINTAIN', 'GAIN']),
              _buildEditableTile('Diet Preference', _userProfile!.dietPreference ?? 'Balanced', (val) {
                setState(() {
                  _userProfile!.dietPreference = val;
                  if (val == 'High Protein') { _userProfile!.proteinPercentage = 40; _userProfile!.carbsPercentage = 40; _userProfile!.fatPercentage = 20; }
                  else if (val == 'Low Carb') { _userProfile!.proteinPercentage = 35; _userProfile!.carbsPercentage = 30; _userProfile!.fatPercentage = 35; }
                  else if (val == 'Low Fat') { _userProfile!.proteinPercentage = 30; _userProfile!.carbsPercentage = 50; _userProfile!.fatPercentage = 20; }
                  else if (val == 'Balanced') { _userProfile!.proteinPercentage = 30; _userProfile!.carbsPercentage = 40; _userProfile!.fatPercentage = 30; }
                });
                _updateProfile();
              }, isPicker: true, options: ['Balanced', 'Low Fat', 'Low Carb', 'High Protein', 'Custom']),
              _buildEditableTile('Target Weight', _formatWeight(_userProfile!.targetWeight ?? _userProfile!.weight!, isMetric), (val) {}, onTap: () => _showTargetWeightPicker(isMetric)),
              if (_userProfile!.goalType != 'maintain')
                _buildEditableTile('Weekly Pace', _formatWeeklyPace(_userProfile!.weightLossRate ?? 0.5, isMetric), (val) {}, onTap: () => _showWeeklyPacePicker(isMetric)),
              _buildEditableTile('Gemini API Key', _userProfile!.geminiApiKey != null && _userProfile!.geminiApiKey!.isNotEmpty ? 'Configured' : 'Not Configured', (val) {}, onTap: () => _showApiKeyDialog()),
            ],
          ),
          
          const Divider(),

          // --- MACROS ---
          ExpansionTile(
            title: const Text('Adjust Macronutrients', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              ListTile(
                title: const Text('Customize Macro Split'),
                subtitle: Text(_getMacroSplitText()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showMacroAdjustmentDialog(),
              ),
            ],
          ),
          
          const Divider(),

          // --- NOTIFICATIONS (UPDATED) ---
          ExpansionTile(
            title: const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              SwitchListTile(
                title: const Text('Enable Meal Reminders'),
                subtitle: const Text('Get reminded to log your meals'),
                value: _userProfile!.notificationsEnabled,
                onChanged: (value) async {
                  setState(() => _userProfile!.notificationsEnabled = value);
                  final isar = DatabaseService().isar;
                  await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                  await NotificationService().scheduleDailyNotifications(_userProfile!);
                },
              ),
              if (_userProfile!.notificationsEnabled) ...[
                // 🟢 NEW TIMEZONE TILE
                _buildEditableTile(
                  'Timezone', 
                  'UTC${_userProfile!.utcOffset >= 0 ? '+' : ''}${_userProfile!.utcOffset}', 
                  (val) {}, 
                  onTap: () => _showTimezonePicker()
                ),
                _buildEditableTile('Breakfast Time', _formatTime(_userProfile!.breakfastTime), (val) {}, onTap: () {
                  _showTimePicker('Select Breakfast Time', _userProfile!.breakfastTime, (minutes) async {
                    setState(() => _userProfile!.breakfastTime = minutes);
                    final isar = DatabaseService().isar;
                    await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                    await NotificationService().scheduleDailyNotifications(_userProfile!);
                  });
                }),
                _buildEditableTile('Lunch Time', _formatTime(_userProfile!.lunchTime), (val) {}, onTap: () {
                  _showTimePicker('Select Lunch Time', _userProfile!.lunchTime, (minutes) async {
                    setState(() => _userProfile!.lunchTime = minutes);
                    final isar = DatabaseService().isar;
                    await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                    await NotificationService().scheduleDailyNotifications(_userProfile!);
                  });
                }),
                _buildEditableTile('Dinner Time', _formatTime(_userProfile!.dinnerTime), (val) {}, onTap: () {
                  _showTimePicker('Select Dinner Time', _userProfile!.dinnerTime, (minutes) async {
                    setState(() => _userProfile!.dinnerTime = minutes);
                    final isar = DatabaseService().isar;
                    await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                    await NotificationService().scheduleDailyNotifications(_userProfile!);
                  });
                }),
              ],
            ],
          ),
          
          const Divider(),

          // --- PREFERENCES ---
          ExpansionTile(
            title: const Text('Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            initiallyExpanded: false,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontSize: 16)),
                  secondary: Icon(_userProfile!.themeMode == 'dark' ? Icons.dark_mode : Icons.light_mode),
                  value: _userProfile!.themeMode == 'dark',
                  onChanged: (bool value) {
                    _updateTheme(value ? 'dark' : 'light');
                  },
                ),
              ),
              const Divider(),
              const ListTile(
                title: Text('Daily Success Criteria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Enable Calorie Rollover'),
                subtitle: const Text('Balance calories across days'),
                trailing: Switch(
                  value: _userProfile!.rolloverEnabled,
                  onChanged: (value) async {
                    setState(() => _userProfile!.rolloverEnabled = value);
                    final isar = DatabaseService().isar;
                    await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                  },
                ),
              ),
              if (_userProfile!.rolloverEnabled) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rollover Limit: ${_userProfile!.maxRollover.clamp(50, 200)} cal',
                        style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                      Slider(
                        value: _userProfile!.maxRollover.clamp(50, 200).toDouble(),
                        min: 50, max: 200, divisions: 30,
                        label: '${_userProfile!.maxRollover} cal',
                        onChanged: (value) { setState(() { _userProfile!.maxRollover = value.round(); }); },
                        onChangeEnd: (value) async {
                          final isar = DatabaseService().isar;
                          await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                        },
                      ),
                    ],
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Success Tolerance: ±${_userProfile!.successTolerance.clamp(50, 200)} cal',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Range to keep streak alive: Base Goal ± Tolerance',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color, fontStyle: FontStyle.italic),
                    ),
                    Slider(
                      value: _userProfile!.successTolerance.clamp(50, 200).toDouble(),
                      min: 50, max: 200, divisions: 30,
                      label: '±${_userProfile!.successTolerance} cal',
                      onChanged: (value) { setState(() => _userProfile!.successTolerance = value.round()); },
                      onChangeEnd: (value) async {
                        final isar = DatabaseService().isar;
                        await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // --- RESET BUTTON ---
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () {
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
              child: const Text(
                'Reset All Data',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // --- HELPER METHODS & PICKERS ---

  void _showTimezonePicker() {
    // Safety Fallback: If data is corrupted, default to 8 (Singapore)
    int selectedOffset = _userProfile!.utcOffset;
    if (selectedOffset < -12 || selectedOffset > 14) {
      selectedOffset = 8; 
    }

    // Generate options from UTC-12 to UTC+14
    final offsets = List.generate(27, (index) => index - 12); 

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
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Select Timezone',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      scrollController: FixedExtentScrollController(
                        // Map offset to index: Offset -12 is index 0. 
                        // So Initial = Selected - (-12) = Selected + 12
                        initialItem: selectedOffset + 12, 
                      ),
                      onSelectedItemChanged: (index) {
                        setModalState(() => selectedOffset = offsets[index]);
                      },
                      children: offsets.map((offset) {
                        final sign = offset >= 0 ? '+' : '';
                        return Center(child: Text('UTC $sign$offset'));
                      }).toList(),
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
                            setState(() => _userProfile!.utcOffset = selectedOffset);
                            final isar = DatabaseService().isar;
                            await isar.writeTxn(() => isar.userProfiles.put(_userProfile!));
                            
                            // Reschedule immediately with new timezone
                            await NotificationService().scheduleDailyNotifications(_userProfile!);
                            
                            if (mounted) Navigator.pop(context);
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
        },
      ),
    );
  }

  String _getMacroSplitText() {
    final protein = _userProfile!.proteinPercentage;
    final carbs = _userProfile!.carbsPercentage;
    final fat = _userProfile!.fatPercentage;
    
    if (!protein.isFinite || !carbs.isFinite || !fat.isFinite) {
      return 'Protein: 30% | Carbs: 40% | Fat: 30%';
    }
    return 'P: ${protein.round()}% | C: ${carbs.round()}% | F: ${fat.round()}%';
  }

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

  Widget _buildEditableTile(String label, String value, Function(String) onSave, {bool isPicker = false, List<String>? options, VoidCallback? onTap}) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit, size: 16),
      onTap: onTap ?? () {
        if (isPicker && options != null) {
          _showOptionsPicker(label, options, onSave);
        }
      },
    );
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
                        onPressed: () {
                          setState(() {
                            _userProfile!.height = currentCm;
                            _userProfile!.isMetric = isMetric;
                          });
                          _updateProfile();
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
                        onPressed: () {
                          setState(() {
                            _userProfile!.weight = currentKg;
                            _userProfile!.isMetric = isMetric;
                          });
                          _updateProfile();
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
                        onPressed: () {
                          setState(() {
                            _userProfile!.targetWeight = currentKg;
                            _userProfile!.isMetric = isMetric;
                          });
                          _updateProfile();
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
                onPressed: () {
                  setState(() {
                    _userProfile!.weightLossRate = currentKg;
                    _userProfile!.isMetric = isMetric;
                  });
                  _updateProfile();
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showApiKeyDialog() {
    String currentKey = _userProfile!.geminiApiKey ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your Gemini API Key to enable AI food analysis.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: currentKey),
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => currentKey = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _userProfile!.geminiApiKey = currentKey;
              });
              _updateProfile();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMacroAdjustmentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Adjust Macronutrients',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: MacroSliders(
                      profile: _userProfile!,
                      onChanged: (protein, carbs, fat) {
                        setState(() {
                          _userProfile!.proteinPercentage = protein;
                          _userProfile!.carbsPercentage = carbs;
                          _userProfile!.fatPercentage = fat;
                        });
                      },
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _loadProfile();
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          _userProfile!.dietPreference = 'Custom';
                          
                          final weekday = DateTime.now().weekday;
                          final tdee = _userProfile!.getTdeeGoalForDay(weekday);
                          _userProfile!.proteinGoal = (tdee * _userProfile!.proteinPercentage / 100) / 4;
                          _userProfile!.carbsGoal = (tdee * _userProfile!.carbsPercentage / 100) / 4;
                          _userProfile!.fatGoal = (tdee * _userProfile!.fatPercentage / 100) / 9;
                          
                          final isar = DatabaseService().isar;
                          await isar.writeTxn(() async {
                            await isar.userProfiles.put(_userProfile!);
                          });
                          
                          setState(() {}); 
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Macro split updated successfully!')),
                            );
                          }
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
      },
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