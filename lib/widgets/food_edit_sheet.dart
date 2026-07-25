import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/food_log.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/widgets/food_autofill_overlay.dart';

class FoodEditSheet extends StatefulWidget {
  final FoodLog? initialLog;

  const FoodEditSheet({super.key, this.initialLog});

  @override
  State<FoodEditSheet> createState() => _FoodEditSheetState();
}

class _FoodEditSheetState extends State<FoodEditSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;

  bool _showMicros = false;

  final _nameKey = GlobalKey();
  final _nameFocusNode = FocusNode();
  final _nameLayerLink = LayerLink();
  final _overlayController = OverlayPortalController();
  Timer? _debounceTimer;
  List<FoodLog> _suggestions = [];
  bool _isAutofilling = false;

  bool get _isEditing => widget.initialLog?.id != null && widget.initialLog!.id > 0;

  @override
  void initState() {
    super.initState();
    final log = widget.initialLog;
    
    _nameController = TextEditingController(text: log?.foodName ?? '');
    _brandController = TextEditingController(text: log?.brandName ?? '');
    _caloriesController = TextEditingController(text: (log?.calories)?.toString() ?? '');
    
    _proteinController = TextEditingController(text: log?.macros.protein?.toStringAsFixed(1) ?? '');
    _carbsController = TextEditingController(text: log?.macros.carbs?.toStringAsFixed(1) ?? '');
    _fatController = TextEditingController(text: log?.macros.fat?.toStringAsFixed(1) ?? '');
    
    _fiberController = TextEditingController(text: log?.macros.fiber?.toStringAsFixed(1) ?? '');
    _sugarController = TextEditingController(text: log?.macros.sugar?.toStringAsFixed(1) ?? '');
    _sodiumController = TextEditingController(text: log?.macros.sodium?.toStringAsFixed(1) ?? '');

    _nameFocusNode.addListener(_onFocusChanged);
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_onFocusChanged);
    _nameFocusNode.dispose();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_nameFocusNode.hasFocus && !_isAutofilling) {
      _overlayController.hide();
      _debounceTimer?.cancel();
      setState(() => _suggestions = []);
    }
  }

  void _onNameChanged() {
    if (_isAutofilling) return;
    _debounceTimer?.cancel();
    final text = _nameController.text.trim();
    if (text.isEmpty) {
      setState(() => _suggestions = []);
      _overlayController.hide();
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(text);
    });
  }

  Future<void> _performSearch(String text) async {
    try {
      final results = await DatabaseService().searchFoodLogs(text);
      if (mounted && _nameController.text.trim() == text) {
        setState(() => _suggestions = results);
        if (results.isNotEmpty && _nameFocusNode.hasFocus) {
          _overlayController.show();
        } else {
          _overlayController.hide();
        }
      }
    } catch (e) {
      debugPrint('Autofill search failed: $e');
    }
  }

  void _onSuggestionSelected(FoodLog log) {
    _isAutofilling = true;
    _overlayController.hide();
    _debounceTimer?.cancel();
    setState(() {
      _suggestions = [];
      _nameController.text = log.foodName;
      _brandController.text = log.brandName ?? '';
      _caloriesController.text = log.calories.toString();
      _proteinController.text = log.macros.protein?.toStringAsFixed(1) ?? '';
      _carbsController.text = log.macros.carbs?.toStringAsFixed(1) ?? '';
      _fatController.text = log.macros.fat?.toStringAsFixed(1) ?? '';
      _fiberController.text = log.macros.fiber?.toStringAsFixed(1) ?? '';
      _sugarController.text = log.macros.sugar?.toStringAsFixed(1) ?? '';
      _sodiumController.text = log.macros.sodium?.toStringAsFixed(1) ?? '';
    });
    _nameFocusNode.unfocus();
    _isAutofilling = false;
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    final calories = int.tryParse(_caloriesController.text) ?? 0;
    
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    
    final fiber = double.tryParse(_fiberController.text);
    final sugar = double.tryParse(_sugarController.text);
    final sodium = double.tryParse(_sodiumController.text);

    final log = FoodLog()
      ..foodName = name
      ..brandName = brand.isEmpty ? null : brand
      ..calories = calories
      ..macros = Macros()
      ..macros.protein = protein
      ..macros.carbs = carbs
      ..macros.fat = fat
      ..macros.fiber = fiber
      ..macros.sugar = sugar
      ..macros.sodium = sodium;

    if (_isEditing) {
      // Edit mode: preserve existing id and timestamp
      log.id = widget.initialLog!.id;
      log.timestamp = widget.initialLog!.timestamp;
      await DatabaseService().updateFoodLog(log);
    } else {
      // Create mode: fresh timestamp
      log.timestamp = DateTime.now();
      await DatabaseService().addFoodLog(log);
    }
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${widget.initialLog!.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await DatabaseService().deleteFoodLog(widget.initialLog!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Name & Brand
              OverlayPortal(
                controller: _overlayController,
                overlayChildBuilder: (_) {
                  if (_suggestions.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final renderBox = _nameKey.currentContext?.findRenderObject() as RenderBox?;
                  final targetWidth = renderBox?.size.width;
                  if (targetWidth == null || targetWidth <= 0) {
                    return const SizedBox.shrink();
                  }
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _overlayController.hide();
                          _nameFocusNode.unfocus();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(color: Colors.transparent),
                      ),
                      CompositedTransformFollower(
                        link: _nameLayerLink,
                        targetAnchor: Alignment.bottomLeft,
                        followerAnchor: Alignment.topLeft,
                        child: SizedBox(
                          width: targetWidth,
                          child: FoodAutofillOverlay(
                            suggestions: _suggestions,
                            onSelected: _onSuggestionSelected,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                child: CompositedTransformTarget(
                  link: _nameLayerLink,
                  child: TextFormField(
                  key: _nameKey,
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      hintText: 'e.g. Apple',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand (Optional)',
                  hintText: 'e.g. Generic',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 24),
              
              // Calories (Big)
              Text(
                'Calories',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: 'kcal',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (int.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Macros Row
              Row(
                children: [
                  Expanded(child: _buildMacroField('Protein', _proteinController, 'g', Theme.of(context).brightness == Brightness.dark ? Colors.red.withValues(alpha: 0.2) : Colors.red[100]!)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMacroField('Carbs', _carbsController, 'g', Theme.of(context).brightness == Brightness.dark ? Colors.orange.withValues(alpha: 0.2) : Colors.orange[100]!)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMacroField('Fat', _fatController, 'g', Theme.of(context).brightness == Brightness.dark ? Colors.blue.withValues(alpha: 0.2) : Colors.blue[100]!)),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Collapsible Micros
              InkWell(
                onTap: () => setState(() => _showMicros = !_showMicros),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'More Details',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      Icon(_showMicros ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              
              if (_showMicros) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildMacroField('Fiber', _fiberController, 'g', Theme.of(context).brightness == Brightness.dark ? Colors.purple.withValues(alpha: 0.2) : Colors.purple[50]!)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMacroField('Sugar', _sugarController, 'g', Theme.of(context).brightness == Brightness.dark ? Colors.pink.withValues(alpha: 0.2) : Colors.pink[50]!)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMacroField('Sodium', _sodiumController, 'mg', Theme.of(context).brightness == Brightness.dark ? Colors.amber.withValues(alpha: 0.2) : Colors.amber[50]!)),
                  ],
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Meal' : 'Log Meal',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              
              if (_isEditing) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _confirmDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Delete entry',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroField(String label, TextEditingController controller, String suffix, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: color,
          ),
        ),
      ],
    );
  }
}
