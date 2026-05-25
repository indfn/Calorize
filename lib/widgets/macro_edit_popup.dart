import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/data/models/macro_goal.dart';
import 'package:calorize/services/database_service.dart';

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
  final Map<int, TextEditingController> _calControllers = {};
  final Map<int, TextEditingController> _proteinControllers = {};
  final Map<int, TextEditingController> _carbsControllers = {};
  final Map<int, TextEditingController> _fatControllers = {};

  @override
  void initState() {
    super.initState();
    _currentDay = widget.initialDay.clamp(1, 7);
    _localEdits = {};
    _initFromProfile();
  }

  @override
  void dispose() {
    for (final c in _calControllers.values) c.dispose();
    for (final c in _proteinControllers.values) c.dispose();
    for (final c in _carbsControllers.values) c.dispose();
    for (final c in _fatControllers.values) c.dispose();
    super.dispose();
  }

  TextEditingController _controllerFor(Map<int, TextEditingController> map, int day, String text) {
    if (!map.containsKey(day)) {
      map[day] = TextEditingController(text: text);
    }
    return map[day]!;
  }

  void _initFromProfile() {
    for (int day = 1; day <= 7; day++) {
      final existing = widget.profile.getGoalForDay(day);
      _localEdits[day] = MacroGoal()
        ..dayOfWeek = day
        ..tdeeGoal = existing?.tdeeGoal ?? widget.profile.getTdeeGoalForDay(day)
        ..proteinGoal = existing?.proteinGoal ?? widget.profile.getProteinGoalForDay(day)
        ..carbsGoal = existing?.carbsGoal ?? widget.profile.getCarbsGoalForDay(day)
        ..fatGoal = existing?.fatGoal ?? widget.profile.getFatGoalForDay(day);
    }
  }

  void _previousDay() {
    setState(() {
      _currentDay = _currentDay == 1 ? 7 : _currentDay - 1;
    });
  }

  void _nextDay() {
    setState(() {
      _currentDay = _currentDay == 7 ? 1 : _currentDay + 1;
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

  @override
  Widget build(BuildContext context) {
    final dayGoal = _localEdits[_currentDay]!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            const SizedBox(height: 16),
            _buildCaloriesField(dayGoal),
            const SizedBox(height: 12),
            _buildMacroField(dayGoal, 'Protein (g)', dayGoal.proteinGoal!, _proteinControllers, (v) {
              setState(() => dayGoal.proteinGoal = v);
            }),
            const SizedBox(height: 8),
            _buildMacroField(dayGoal, 'Carbs (g)', dayGoal.carbsGoal!, _carbsControllers, (v) {
              setState(() => dayGoal.carbsGoal = v);
            }),
            const SizedBox(height: 8),
            _buildMacroField(dayGoal, 'Fat (g)', dayGoal.fatGoal!, _fatControllers, (v) {
              setState(() => dayGoal.fatGoal = v);
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _applyConstant,
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
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesField(MacroGoal goal) {
    final ctrl = _controllerFor(_calControllers, _currentDay, goal.tdeeGoal.toString());
    return TextField(
      controller: ctrl,
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
          setState(() => goal.tdeeGoal = parsed.clamp(0, 10000));
        }
      },
    );
  }

  Widget _buildMacroField(MacroGoal goal, String label, double value,
      Map<int, TextEditingController> ctrlMap, ValueChanged<double> onChanged) {
    final dayGoal = _localEdits[_currentDay]!;
    final ctrl = _controllerFor(ctrlMap, _currentDay, value.round().toString());
    final totalCal = dayGoal.tdeeGoal ?? 2000;
    final calPerGram = label.contains('Fat') ? 9 : 4;
    final pct = totalCal > 0 ? ((value * calPerGram) / totalCal * 100).round() : 0;

    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '$label ($pct%)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      onChanged: (val) {
        final parsed = double.tryParse(val);
        if (parsed != null) {
          onChanged(parsed.clamp(0, 2000));
        }
      },
    );
  }
}
