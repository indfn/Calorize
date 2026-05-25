import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:calorize/utils/macro_calculator.dart';
import 'package:calorize/screens/onboarding/plan_review_screen.dart';
import 'package:calorize/data/models/ai_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalPages = 10;

  // Data
  String _gender = 'Male';
  DateTime _dob = DateTime(2000, 1, 1);
  double _heightCm = 170; 
  double _weightKg = 70; 
  String _activityLevel = 'Sedentary';
  String _goalType = 'maintain';

  String _dietPreference = 'Balanced';
  double _targetWeightKg = 70; 
  double _weightLossRate = 0.5;
  bool _rolloverEnabled = false;
  AIProvider? _aiProvider;

  // UI Helpers
  bool _isMetricHeight = true;
  bool _isMetricWeight = true;
  
  // Imperial Helpers
  int _feet = 5;
  int _inches = 7;
  int _lbs = 154;

  // AI Provider form state
  String _aiProviderPreset = 'google';
  final _aiApiKeyController = TextEditingController();
  final _aiNameController = TextEditingController();
  final _aiModelIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateTotalPages();
    _selectAiPreset('google');
  }

  @override
  void dispose() {
    _aiApiKeyController.dispose();
    _aiNameController.dispose();
    _aiModelIdController.dispose();
    super.dispose();
  }

  void _selectAiPreset(String key) {
    _aiProviderPreset = key;
    switch (key) {
      case 'openai':
        _aiNameController.text = 'OpenAI';
        _aiModelIdController.text = 'gpt-4o';
      case 'google':
        _aiNameController.text = 'Google';
        _aiModelIdController.text = 'gemini-2.5-flash';
      case 'anthropic':
        _aiNameController.text = 'Anthropic';
        _aiModelIdController.text = 'claude-3-5-sonnet-20241022';
      case 'custom':
        _aiNameController.text = '';
        _aiModelIdController.text = '';
    }
  }

  void _updateTotalPages() {
    setState(() {
      if (_goalType == 'maintain') {
        _totalPages = 9; 
      } else {
        _totalPages = 11;
      }
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _buildAiProvider() {
    final key = _aiApiKeyController.text.trim();
    if (key.isEmpty) {
      _aiProvider = null;
      return;
    }

    String baseUrl;
    String apiType;
    switch (_aiProviderPreset) {
      case 'openai':
        baseUrl = 'https://api.openai.com/v1';
        apiType = 'openai';
      case 'google':
        baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
        apiType = 'google';
      case 'anthropic':
        baseUrl = 'https://api.anthropic.com/v1';
        apiType = 'anthropic';
      default:
        baseUrl = 'https://api.openai.com/v1';
        apiType = 'openai';
    }

    _aiProvider = AIProvider()
      ..providerId = _aiProviderPreset
      ..name = _aiNameController.text.isNotEmpty ? _aiNameController.text : _aiProviderPreset
      ..apiKey = key
      ..baseUrl = baseUrl
      ..modelId = _aiModelIdController.text
      ..apiType = apiType
      ..isEnabled = true;
  }

  String _getDefaultModelHint() {
    switch (_aiProviderPreset) {
      case 'openai': return 'gpt-4o';
      case 'google': return 'gemini-2.5-flash';
      case 'anthropic': return 'claude-3-5-sonnet-20241022';
      default: return 'gpt-4o';
    }
  }

  void _finishOnboarding() {
    if (!_isMetricHeight) {
      _heightCm = ((_feet * 12) + _inches) * 2.54;
    }
    if (!_isMetricWeight) {
      _weightKg = _lbs * 0.453592;
    }

    _buildAiProvider();

    final age = MacroCalculator.calculateAge(_dob);
    final bmr = MacroCalculator.calculateBMR(
      weightKg: _weightKg,
      heightCm: _heightCm,
      age: age,
      gender: _gender,
    );
    final tdee = MacroCalculator.calculateTDEE(
      bmr: bmr,
      activityLevel: _activityLevel,
    );
    final dailyTarget = MacroCalculator.calculateDailyTarget(
      tdee: tdee,
      goalType: _goalType,
      weightLossRate: _goalType == 'maintain' ? 0 : _weightLossRate,
    );
    final macros = MacroCalculator.calculateMacros(
      targetCalories: dailyTarget,
      weightKg: _weightKg,
      goalType: _goalType,
      dietPreference: _dietPreference,
      gender: _gender,
      age: age,
    );
    final weeksToGoal = MacroCalculator.calculateWeeksToGoal(
      currentWeight: _weightKg,
      targetWeight: _goalType == 'maintain' ? _weightKg : _targetWeightKg,
      rate: _weightLossRate,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanReviewScreen(
          calories: dailyTarget,
          macros: macros,
          weeksToGoal: weeksToGoal,
          userProfileData: {
            'gender': _gender,
            'dob': _dob,
            'height': _heightCm,
            'weight': _weightKg,
            'activityLevel': _activityLevel,
            'goalType': _goalType,

            'dietPreference': _dietPreference,
            'targetWeight': _goalType == 'maintain' ? _weightKg : _targetWeightKg,
            'weightLossRate': _weightLossRate,
            'rolloverEnabled': _rolloverEnabled,
            'isMetric': _isMetricWeight,
            'aiProvider': _aiProvider,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildGenderPage(),
      _buildDobPage(),
      _buildHeightPage(),
      _buildWeightPage(),
      _buildActivityPage(),

      _buildDietPreferencePage(),
      _buildGoalPage(),
      if (_goalType != 'maintain') _buildTargetWeightPage(),
      if (_goalType != 'maintain') _buildRatePage(),
      _buildApiKeyPage(),
      _buildRolloverPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: pages,
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: (_currentPage + 1) / _totalPages,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    );
  }

  Widget _buildBottomBar() {
    final isApiPage = _currentPage == _totalPages - 2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: _previousPage,
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          if (isApiPage) ...[
            TextButton(
              onPressed: () => _finishOnboarding(),
              child: const Text('Skip'),
            ),
          ],
          FilledButton(
            onPressed: _nextPage,
            child: Text(_currentPage == _totalPages - 1 ? 'Finish' : 'Next'),
          ),
        ],
      ),
    );
  }

  // --- Step Builders ---

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGenderPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('What is your gender?'),
        _buildSelectionCard('Male', _gender == 'Male', () => setState(() => _gender = 'Male')),
        _buildSelectionCard('Female', _gender == 'Female', () => setState(() => _gender = 'Female')),
      ],
    );
  }

  Widget _buildDobPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('When were you born?'),
        SizedBox(
          height: 200,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _dob,
            maximumDate: DateTime.now(),
            minimumDate: DateTime(1900),
            onDateTimeChanged: (date) => setState(() => _dob = date),
          ),
        ),
      ],
    );
  }

  Widget _buildHeightPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('How tall are you?'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('CM'),
            Switch(
              value: !_isMetricHeight,
              onChanged: (val) => setState(() => _isMetricHeight = !val),
            ),
            const Text('FT'),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: _isMetricHeight
              ? CupertinoPicker(
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    setState(() => _heightCm = (index + 100).toDouble());
                  },
                  scrollController: FixedExtentScrollController(initialItem: _heightCm.toInt() - 100),
                  children: List.generate(150, (index) => Center(child: Text('${index + 100} cm'))),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _feet = index + 1;
                            _heightCm = ((_feet * 12) + _inches) * 2.54;
                          });
                        },
                        scrollController: FixedExtentScrollController(initialItem: _feet - 1),
                        children: List.generate(8, (index) => Center(child: Text('${index + 1} ft'))),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _inches = index;
                            _heightCm = ((_feet * 12) + _inches) * 2.54;
                          });
                        },
                        scrollController: FixedExtentScrollController(initialItem: _inches),
                        children: List.generate(12, (index) => Center(child: Text('$index in'))),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildWeightPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('How much do you weigh?'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('KG'),
            Switch(
              value: !_isMetricWeight,
              onChanged: (val) {
                setState(() {
                  _isMetricWeight = !val;
                  if (!_isMetricWeight) {
                    _lbs = (_weightKg * 2.20462).round();
                  }
                });
              },
            ),
            const Text('LBS'),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 32,
            onSelectedItemChanged: (index) {
              setState(() {
                if (_isMetricWeight) {
                  _weightKg = (index + 30).toDouble();
                } else {
                  _lbs = index + 66;
                  _weightKg = _lbs * 0.453592;
                }
              });
            },
            scrollController: FixedExtentScrollController(
              initialItem: _isMetricWeight ? _weightKg.toInt() - 30 : (_weightKg * 2.20462).round() - 66
            ),
            children: List.generate(
              300, 
              (index) => Center(child: Text(_isMetricWeight ? '${index + 30} kg' : '${index + 66} lbs'))
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityPage() {
    final levels = [
      {'title': 'Sedentary', 'desc': 'Little or no exercise'},
      {'title': 'Light', 'desc': 'Exercise 1-3 times per week'},
      {'title': 'Moderate', 'desc': 'Exercise 4-5 times per week'},
      {'title': 'Active', 'desc': 'Daily exercise or Intense exercise 3-4 times per week'},
      {'title': 'Very Active', 'desc': 'Intense exercise 6-7 times per week'},
      {'title': 'Extra Active', 'desc': 'Very intense exercise daily, or physical job'},
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          _buildTitle('How active are you?'),
          ...levels.map((l) => _buildSelectionCard(
            l['title']!, 
            _activityLevel == l['title'], 
            () => setState(() => _activityLevel = l['title']!),
            subtitle: l['desc']
          )),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Exercise: 15-30 minutes of elevated heart rate activity.\n'
              'Intense exercise: 45-120 minutes of elevated heart rate activity.\n'
              'Very intense exercise: 2+ hours of elevated heart rate activity.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }



  Widget _buildDietPreferencePage() {
    final prefs = ['Balanced', 'Low Fat', 'Low Carb', 'High Protein'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('Any macro preferences?'),
        ...prefs.map((p) => _buildSelectionCard(p, _dietPreference == p, () => setState(() => _dietPreference = p))),
      ],
    );
  }

  Widget _buildGoalPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('What is your goal?'),
        _buildSelectionCard('Lose Weight', _goalType == 'lose', () {
          setState(() {
            _goalType = 'lose';
            _weightLossRate = 0.5;
            _updateTotalPages();
          });
        }),
        _buildSelectionCard('Maintain Weight', _goalType == 'maintain', () {
          setState(() {
            _goalType = 'maintain';
            _updateTotalPages();
          });
        }),
        _buildSelectionCard('Build Muscle', _goalType == 'gain', () {
          setState(() {
            _goalType = 'gain';
            _weightLossRate = 0.25;
            _updateTotalPages();
          });
        }),
      ],
    );
  }

  Widget _buildTargetWeightPage() {
    if (_goalType == 'lose' && _targetWeightKg > _weightKg) {
      _targetWeightKg = _weightKg;
    } else if (_goalType == 'gain' && _targetWeightKg < _weightKg) {
      _targetWeightKg = _weightKg;
    }

    int minVal, maxVal;
    int currentVal;

    if (_isMetricWeight) {
      if (_goalType == 'lose') {
        minVal = 30;
        maxVal = _weightKg.floor();
      } else {
        minVal = _weightKg.ceil();
        maxVal = 300;
      }
      currentVal = _targetWeightKg.round();
    } else {
      int weightLbs = (_weightKg * 2.20462).round();
      if (_goalType == 'lose') {
        minVal = 66;
        maxVal = weightLbs;
      } else {
        minVal = weightLbs;
        maxVal = 660;
      }
      currentVal = (_targetWeightKg * 2.20462).round();
    }

    if (currentVal < minVal) currentVal = minVal;
    if (currentVal > maxVal) currentVal = maxVal;

    int itemCount = maxVal - minVal + 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('Target Weight'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('KG'),
            Switch(
              value: !_isMetricWeight,
              onChanged: (val) {
                 setState(() {
                  _isMetricWeight = !val;
                });
              },
            ),
            const Text('LBS'),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 32,
            onSelectedItemChanged: (index) {
               setState(() {
                if (_isMetricWeight) {
                  _targetWeightKg = (minVal + index).toDouble();
                } else {
                  double valLbs = (minVal + index).toDouble();
                  _targetWeightKg = valLbs * 0.453592;
                }
              });
            },
            scrollController: FixedExtentScrollController(
              initialItem: currentVal - minVal
            ),
            children: List.generate(
              itemCount, 
              (index) => Center(child: Text(_isMetricWeight ? '${minVal + index} kg' : '${minVal + index} lbs'))
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildRatePage() {
    double minRate = 0.2;
    double maxRate = _goalType == 'lose' ? 0.9 : 0.5;
    
    if (_weightLossRate < minRate) _weightLossRate = minRate;
    if (_weightLossRate > maxRate) _weightLossRate = maxRate;

    String rateDisplay;
    if (_isMetricWeight) {
      rateDisplay = '${_weightLossRate.toStringAsFixed(2)} kg / week';
    } else {
      double rateLbs = _weightLossRate * 2.20462;
      rateDisplay = '${rateLbs.toStringAsFixed(1)} lbs / week';
    }

    int divisions;
    if (_isMetricWeight) {
      divisions = _goalType == 'lose' 
        ? ((maxRate - minRate) / 0.1).round() 
        : ((maxRate - minRate) / 0.05).round();
    } else {
      double minLbs = minRate * 2.20462;
      double maxLbs = maxRate * 2.20462;
      divisions = ((maxLbs - minLbs) / 0.1).round();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('Weekly Pace'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('KG'),
            Switch(
              value: !_isMetricWeight,
              onChanged: (val) => setState(() => _isMetricWeight = !val),
            ),
            const Text('LBS'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          rateDisplay,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const SizedBox(height: 24),
        Slider(
          value: _weightLossRate,
          min: minRate,
          max: maxRate,
          divisions: divisions > 0 ? divisions : 1,
          label: _isMetricWeight 
            ? '${_weightLossRate.toStringAsFixed(2)} kg'
            : '${(_weightLossRate * 2.20462).toStringAsFixed(1)} lbs',
          onChanged: (val) => setState(() => _weightLossRate = val),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            _goalType == 'lose' 
              ? (_isMetricWeight ? 'Recommended: 0.5 kg/week' : 'Recommended: 1.1 lbs/week')
              : (_isMetricWeight ? 'Recommended: 0.25 kg/week' : 'Recommended: 0.5 lbs/week'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildRolloverPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTitle('Rollover Calories?'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            'If enabled, unused calories (up to 200) will be added to the next day.',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        Switch(
          value: _rolloverEnabled,
          onChanged: (val) => setState(() => _rolloverEnabled = val),
        ),
        Text(_rolloverEnabled ? 'Enabled' : 'Disabled'),
      ],
    );
  }

  Widget _buildSelectionCard(String label, bool isSelected, VoidCallback onTap, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeyPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          _buildTitle('Enable AI Features'),
          const Text(
            'Select an AI provider and paste your API key to enable AI food analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildAiPresetCard('Google', 'google', Icons.auto_awesome),
              const SizedBox(width: 8),
              _buildAiPresetCard('OpenAI', 'openai', Icons.smart_toy_outlined),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildAiPresetCard('Anthropic', 'anthropic', Icons.psychology_outlined),
              const SizedBox(width: 8),
              _buildAiPresetCard('Custom', 'custom', Icons.build_outlined),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _aiNameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'My Provider',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiApiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'Paste your key here',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiModelIdController,
            decoration: InputDecoration(
              labelText: 'Model ID',
              hintText: _getDefaultModelHint(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You can skip this and configure providers later in Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAiPresetCard(String label, String key, IconData icon) {
    final selected = _aiProviderPreset == key;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectAiPreset(key)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
