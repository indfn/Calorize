import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/user_profile.dart';

class MacroSliders extends StatefulWidget {
  final UserProfile profile;
  final Function(double protein, double carbs, double fat) onChanged;

  const MacroSliders({
    super.key,
    required this.profile,
    required this.onChanged,
  });

  @override
  State<MacroSliders> createState() => _MacroSlidersState();
}

class _MacroSlidersState extends State<MacroSliders> {
  late double _protein;
  late double _carbs;
  late double _fat;

  @override
  void initState() {
    super.initState();
    // Ensure valid initial values
    _protein = widget.profile.proteinPercentage.isFinite && widget.profile.proteinPercentage > 0 
        ? widget.profile.proteinPercentage 
        : 30.0;
    _carbs = widget.profile.carbsPercentage.isFinite && widget.profile.carbsPercentage > 0 
        ? widget.profile.carbsPercentage 
        : 40.0;
    _fat = widget.profile.fatPercentage.isFinite && widget.profile.fatPercentage > 0 
        ? widget.profile.fatPercentage 
        : 30.0;
    
    // Normalize to 100% if needed
    final total = _protein + _carbs + _fat;
    if (total != 100 && total > 0) {
      _protein = (_protein / total * 100);
      _carbs = (_carbs / total * 100);
      _fat = (_fat / total * 100);
    }
  }

  void _updateProtein(double value) {
    setState(() {
      _protein = value;
      // Distribute remaining percentage proportionally between carbs and fat
      final remaining = 100 - _protein;
      final carbsFatTotal = _carbs + _fat;
      
      if (carbsFatTotal > 0) {
        _carbs = (remaining * (_carbs / carbsFatTotal)).roundToDouble();
        _fat = (remaining * (_fat / carbsFatTotal)).roundToDouble();
        
        // Handle rounding errors
        final sum = _protein + _carbs + _fat;
        if (sum != 100) {
          _fat += (100 - sum);
        }
      } else {
        _carbs = remaining / 2;
        _fat = remaining / 2;
      }
    });
    widget.onChanged(_protein, _carbs, _fat);
  }

  void _updateCarbs(double value) {
    setState(() {
      _carbs = value;
      final remaining = 100 - _carbs;
      final proteinFatTotal = _protein + _fat;
      
      if (proteinFatTotal > 0) {
        _protein = (remaining * (_protein / proteinFatTotal)).roundToDouble();
        _fat = (remaining * (_fat / proteinFatTotal)).roundToDouble();
        
        final sum = _protein + _carbs + _fat;
        if (sum != 100) {
          _fat += (100 - sum);
        }
      } else {
        _protein = remaining / 2;
        _fat = remaining / 2;
      }
    });
    widget.onChanged(_protein, _carbs, _fat);
  }

  void _updateFat(double value) {
    setState(() {
      _fat = value;
      final remaining = 100 - _fat;
      final proteinCarbsTotal = _protein + _carbs;
      
      if (proteinCarbsTotal > 0) {
        _protein = (remaining * (_protein / proteinCarbsTotal)).roundToDouble();
        _carbs = (remaining * (_carbs / proteinCarbsTotal)).roundToDouble();
        
        final sum = _protein + _carbs + _fat;
        if (sum != 100) {
          _carbs += (100 - sum);
        }
      } else {
        _protein = remaining / 2;
        _carbs = remaining / 2;
      }
    });
    widget.onChanged(_protein, _carbs, _fat);
  }

  int _calculateGrams(double percentage, int caloriesPerGram) {
    final weekday = DateTime.now().weekday;
    final tdee = widget.profile.getTdeeGoalForDay(weekday);
    if (percentage.isNaN || percentage.isInfinite || tdee == 0 || caloriesPerGram == 0) {
      return 0;
    }
    return ((tdee * percentage / 100) / caloriesPerGram).round();
  }

  Widget _buildMacroSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required Color color,
    required int caloriesPerGram,
  }) {
    final grams = _calculateGrams(value, caloriesPerGram);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: Text(
                '${value.round()}% = ${grams}g',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value.clamp(10.0, 70.0),
          min: 10,
          max: 70,
          divisions: 60,
          activeColor: color,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrient Split',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adjust your protein, carbs, and fat percentages. Total must equal 100%.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 24),
          _buildMacroSlider(
            label: 'Protein',
            value: _protein,
            onChanged: _updateProtein,
            color: Colors.blue,
            caloriesPerGram: 4,
          ),
          _buildMacroSlider(
            label: 'Carbs',
            value: _carbs,
            onChanged: _updateCarbs,
            color: Colors.orange,
            caloriesPerGram: 4,
          ),
          _buildMacroSlider(
            label: 'Fat',
            value: _fat,
            onChanged: _updateFat,
            color: Colors.red,
            caloriesPerGram: 9,
          ),
          const Divider(),
          Center(
            child: Text(
              'Total: ${(_protein + _carbs + _fat).round()}%',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: (_protein + _carbs + _fat).round() == 100 
                  ? Colors.green 
                  : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
