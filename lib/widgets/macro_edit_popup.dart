import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/macro_goal.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/utils/macro_calculator.dart';

const List<String> _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class MacroEditPopup extends StatefulWidget {
  final UserProfile profile;
  final int initialDay;
  final VoidCallback onSaved;

  const MacroEditPopup({
    super.key,
    required this.profile,
    required this.initialDay,
    required this.onSaved,
  });

  @override
  State<MacroEditPopup> createState() => _MacroEditPopupState();
}

class _MacroEditPopupState extends State<MacroEditPopup> {
  late int _currentDay;
  late Map<int, MacroGoal> _localEdits;

  late final TextEditingController _calController;
  late final TextEditingController _proteinPctController;
  late final TextEditingController _carbsPctController;
  late final TextEditingController _fatPctController;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.initialDay.clamp(1, 7);
    _localEdits = {};
    _initFromProfile();

    final goal = _localEdits[_currentDay]!;
    _calController = TextEditingController(text: goal.tdeeGoal.toString());
    _proteinPctController = TextEditingController(text: (goal.proteinPercentage ?? 27.0).round().toString());
    _carbsPctController = TextEditingController(text: (goal.carbsPercentage ?? 49.0).round().toString());
    _fatPctController = TextEditingController(text: (goal.fatPercentage ?? 24.0).round().toString());
  }

  @override
  void dispose() {
    _calController.dispose();
    _proteinPctController.dispose();
    _carbsPctController.dispose();
    _fatPctController.dispose();
    super.dispose();
  }

  void _initFromProfile() {
    double profileProteinPct = widget.profile.proteinPercentage;
    double profileCarbsPct = widget.profile.carbsPercentage;
    double profileFatPct = widget.profile.fatPercentage;

    if (profileProteinPct == 30.0 &&
        profileCarbsPct == 40.0 &&
        profileFatPct == 30.0 &&
        widget.profile.dietPreference != null) {
      final ratios = MacroCalculator.getRatiosForDiet(widget.profile.dietPreference!);
      profileProteinPct = (ratios['protein'] ?? 0.27) * 100;
      profileCarbsPct = (ratios['carbs'] ?? 0.49) * 100;
      profileFatPct = (ratios['fat'] ?? 0.24) * 100;
    }

    for (int day = 1; day <= 7; day++) {
      final existing = widget.profile.getGoalForDay(day);
      
      double proteinPct = existing?.proteinPercentage ?? profileProteinPct;
      double carbsPct = existing?.carbsPercentage ?? profileCarbsPct;
      double fatPct = existing?.fatPercentage ?? profileFatPct;

      if (proteinPct == 30.0 &&
          carbsPct == 40.0 &&
          fatPct == 30.0 &&
          widget.profile.dietPreference != null) {
        final ratios = MacroCalculator.getRatiosForDiet(widget.profile.dietPreference!);
        proteinPct = (ratios['protein'] ?? 0.27) * 100;
        carbsPct = (ratios['carbs'] ?? 0.49) * 100;
        fatPct = (ratios['fat'] ?? 0.24) * 100;
      }

      final tdee = existing?.tdeeGoal ?? widget.profile.getTdeeGoalForDay(day);
      
      final proteinGrams = existing?.proteinGoal ?? (tdee * (proteinPct / 100) / 4);
      final carbsGrams = existing?.carbsGoal ?? (tdee * (carbsPct / 100) / 4);
      final fatGrams = existing?.fatGoal ?? (tdee * (fatPct / 100) / 9);

      _localEdits[day] = MacroGoal()
        ..dayOfWeek = day
        ..tdeeGoal = tdee
        ..proteinGoal = proteinGrams
        ..carbsGoal = carbsGrams
        ..fatGoal = fatGrams
        ..proteinPercentage = proteinPct
        ..carbsPercentage = carbsPct
        ..fatPercentage = fatPct
        ..fiberGoal = existing?.fiberGoal ?? widget.profile.getFiberGoalForDay(day)
        ..sugarGoal = existing?.sugarGoal ?? widget.profile.getSugarGoalForDay(day)
        ..sodiumGoal = existing?.sodiumGoal ?? widget.profile.getSodiumGoalForDay(day);
    }
  }

  void _recalculateGrams(MacroGoal goal) {
    final calories = goal.tdeeGoal ?? 2000;
    final pPct = goal.proteinPercentage ?? 27.0;
    final cPct = goal.carbsPercentage ?? 49.0;
    final fPct = goal.fatPercentage ?? 24.0;
    
    goal.proteinGoal = (calories * (pPct / 100)) / 4;
    goal.carbsGoal = (calories * (cPct / 100)) / 4;
    goal.fatGoal = (calories * (fPct / 100)) / 9;
  }

  void _updateControllersForCurrentDay() {
    final goal = _localEdits[_currentDay]!;
    
    if (_calController.text != goal.tdeeGoal.toString()) {
      _calController.text = goal.tdeeGoal.toString();
    }
    
    final pParsed = double.tryParse(_proteinPctController.text) ?? 0.0;
    if (pParsed.round() != (goal.proteinPercentage ?? 27.0).round()) {
      _proteinPctController.text = (goal.proteinPercentage ?? 27.0).round().toString();
    }
    
    final cParsed = double.tryParse(_carbsPctController.text) ?? 0.0;
    if (cParsed.round() != (goal.carbsPercentage ?? 49.0).round()) {
      _carbsPctController.text = (goal.carbsPercentage ?? 49.0).round().toString();
    }
    
    final fParsed = double.tryParse(_fatPctController.text) ?? 0.0;
    if (fParsed.round() != (goal.fatPercentage ?? 24.0).round()) {
      _fatPctController.text = (goal.fatPercentage ?? 24.0).round().toString();
    }
  }

  void _previousDay() {
    setState(() {
      _currentDay = _currentDay == 1 ? 7 : _currentDay - 1;
      _updateControllersForCurrentDay();
    });
  }

  void _nextDay() {
    setState(() {
      _currentDay = _currentDay == 7 ? 1 : _currentDay + 1;
      _updateControllersForCurrentDay();
    });
  }

  Future<void> _save() async {
    final db = DatabaseService();
    for (int day = 1; day <= 7; day++) {
      await db.saveWeeklyGoal(day, _localEdits[day]!);
    }
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _applyConstant() async {
    final base = _localEdits[_currentDay]!;
    final db = DatabaseService();
    await db.applyConstantGoals(base);
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  void _showPresetSheet() {
    final goal = _localEdits[_currentDay]!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _PresetSheet(
          currentCalories: goal.tdeeGoal ?? 2000,
          proteinPct: goal.proteinPercentage ?? 27.0,
          carbsPct: goal.carbsPercentage ?? 49.0,
          fatPct: goal.fatPercentage ?? 24.0,
          onPresetSelected: (calories, proteinPct, carbsPct, fatPct) {
            setState(() {
              if (calories != null) {
                goal.tdeeGoal = calories;
              }
              goal.proteinPercentage = proteinPct;
              goal.carbsPercentage = carbsPct;
              goal.fatPercentage = fatPct;
              _recalculateGrams(goal);
              _updateControllersForCurrentDay();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayGoal = _localEdits[_currentDay]!;
    final totalPercentage = ((dayGoal.proteinPercentage ?? 0.0) +
        (dayGoal.carbsPercentage ?? 0.0) +
        (dayGoal.fatPercentage ?? 0.0)).round();

    final isSaveEnabled = totalPercentage == 100;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousDay,
                  ),
                  Text(
                    _dayNames[_currentDay - 1],
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextDay,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showPresetSheet,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Use Preset'),
              ),
              const SizedBox(height: 16),
              _buildCaloriesField(dayGoal),
              const SizedBox(height: 20),
              _buildMacroSliderRow(
                label: 'Protein',
                percent: dayGoal.proteinPercentage ?? 27.0,
                grams: dayGoal.proteinGoal ?? 0.0,
                color: Colors.orange,
                controller: _proteinPctController,
                onPercentChanged: (val) {
                  setState(() {
                    dayGoal.proteinPercentage = val;
                    _recalculateGrams(dayGoal);
                    _updateControllersForCurrentDay();
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildMacroSliderRow(
                label: 'Carbs',
                percent: dayGoal.carbsPercentage ?? 49.0,
                grams: dayGoal.carbsGoal ?? 0.0,
                color: Colors.blue,
                controller: _carbsPctController,
                onPercentChanged: (val) {
                  setState(() {
                    dayGoal.carbsPercentage = val;
                    _recalculateGrams(dayGoal);
                    _updateControllersForCurrentDay();
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildMacroSliderRow(
                label: 'Fat',
                percent: dayGoal.fatPercentage ?? 24.0,
                grams: dayGoal.fatGoal ?? 0.0,
                color: Colors.yellow,
                controller: _fatPctController,
                onPercentChanged: (val) {
                  setState(() {
                    dayGoal.fatPercentage = val;
                    _recalculateGrams(dayGoal);
                    _updateControllersForCurrentDay();
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Percentage:',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$totalPercentage%',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSaveEnabled ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isSaveEnabled ? _applyConstant : null,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Apply to all days'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: isSaveEnabled ? _save : null,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesField(MacroGoal goal) {
    return TextField(
      controller: _calController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Calories',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      onChanged: (val) {
        final parsed = int.tryParse(val);
        if (parsed != null) {
          setState(() {
            goal.tdeeGoal = parsed.clamp(0, 10000);
            _recalculateGrams(goal);
          });
        }
      },
    );
  }

  Widget _buildMacroSliderRow({
    required String label,
    required double percent,
    required double grams,
    required Color color,
    required TextEditingController controller,
    required ValueChanged<double> onPercentChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            '$label (${percent.round()}% = ${grams.toStringAsFixed(1)}g)',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: color,
                  inactiveTrackColor: color.withOpacity(0.2),
                  thumbColor: color,
                  overlayColor: color.withOpacity(0.12),
                  valueIndicatorColor: color,
                ),
                child: Slider(
                  value: percent.clamp(0.0, 100.0),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (val) {
                    onPercentChanged(val);
                  },
                ),
              ),
            ),
            Container(
              width: 60,
              margin: const EdgeInsets.only(left: 8, right: 4),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixText: '%',
                ),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                onChanged: (val) {
                  final parsed = double.tryParse(val) ?? 0.0;
                  if (parsed != percent) {
                    onPercentChanged(parsed.clamp(0.0, 100.0));
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetSheet extends StatefulWidget {
  final int currentCalories;
  final double proteinPct;
  final double carbsPct;
  final double fatPct;
  final Function(int? calories, double proteinPct, double carbsPct, double fatPct) onPresetSelected;

  const _PresetSheet({
    required this.currentCalories,
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.onPresetSelected,
  });

  @override
  State<_PresetSheet> createState() => _PresetSheetState();
}

class _PresetSheetState extends State<_PresetSheet> {
  List<Map<String, dynamic>> _customPresets = [];

  @override
  void initState() {
    super.initState();
    _loadCustomPresets();
  }

  Future<void> _loadCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('custom_macro_presets');
    if (jsonStr != null) {
      try {
        final List<dynamic> decoded = json.decode(jsonStr);
        setState(() {
          _customPresets = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        });
      } catch (e) {
        debugPrint('Error decoding custom presets: $e');
      }
    }
  }

  Future<void> _saveCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_macro_presets', json.encode(_customPresets));
  }

  void _addCurrentAsPreset() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Preset'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            hintText: 'e.g., Summer Shred',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _customPresets.add({
                    'name': name,
                    'calories': widget.currentCalories,
                    'proteinPercentage': widget.proteinPct,
                    'carbsPercentage': widget.carbsPct,
                    'fatPercentage': widget.fatPct,
                  });
                });
                _saveCustomPresets();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _renamePreset(int index) {
    final nameController = TextEditingController(text: _customPresets[index]['name']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Preset'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Preset Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _customPresets[index]['name'] = name;
                });
                _saveCustomPresets();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deletePreset(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Preset?'),
        content: Text('Are you sure you want to delete "${_customPresets[index]['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _customPresets.removeAt(index);
              });
              _saveCustomPresets();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Macro Presets',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addCurrentAsPreset,
              icon: const Icon(Icons.add),
              label: const Text('Save Current Split as Preset'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Diet Preferences',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...['Balanced', 'Low Carb', 'Low Fat', 'High Protein'].map((diet) {
            final ratios = MacroCalculator.getRatiosForDiet(diet);
            final p = ((ratios['protein'] ?? 0.27) * 100).round();
            final c = ((ratios['carbs'] ?? 0.49) * 100).round();
            final f = ((ratios['fat'] ?? 0.24) * 100).round();
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(diet),
              subtitle: Text('P $p% | C $c% | F $f%'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                widget.onPresetSelected(null, p.toDouble(), c.toDouble(), f.toDouble());
                Navigator.pop(context);
              },
            );
          }),
          const SizedBox(height: 16),
          Text(
            'My Custom Presets',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (_customPresets.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No custom presets saved yet',
                  style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _customPresets.length,
                itemBuilder: (context, idx) {
                  final preset = _customPresets[idx];
                  final name = preset['name'] ?? 'Custom';
                  final calories = preset['calories'] ?? 2000;
                  final p = (preset['proteinPercentage'] ?? 27.0).round();
                  final c = (preset['carbsPercentage'] ?? 49.0).round();
                  final f = (preset['fatPercentage'] ?? 24.0).round();
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(name),
                    subtitle: Text('$calories kcal (P $p% | C $c% | F $f%)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _renamePreset(idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _deletePreset(idx),
                        ),
                      ],
                    ),
                    onTap: () {
                      widget.onPresetSelected(
                        calories,
                        (preset['proteinPercentage'] ?? 27.0).toDouble(),
                        (preset['carbsPercentage'] ?? 49.0).toDouble(),
                        (preset['fatPercentage'] ?? 24.0).toDouble(),
                      );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
