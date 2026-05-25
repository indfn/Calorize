import 'package:flutter/material.dart';
import 'package:calorize/screens/dashboard_screen.dart';
import 'package:calorize/screens/settings/settings_screen.dart';
import 'package:calorize/screens/progress_screen.dart';
import 'package:calorize/widgets/dev_options_sheet.dart';
import 'package:calorize/services/background_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final List<DateTime> _settingsTapTimes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BackgroundService().updateWidgetData();
    }
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProgressScreen(),
    const SettingsScreen(),
  ];

  void _onSettingsTabTapped() {
    final now = DateTime.now();
    _settingsTapTimes.add(now);
    _settingsTapTimes.removeWhere((t) => now.difference(t) > const Duration(seconds: 3));
    if (_settingsTapTimes.length >= 7) {
      _settingsTapTimes.clear();
      showDevOptionsSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) _onSettingsTabTapped();
          setState(() => _currentIndex = index);
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
