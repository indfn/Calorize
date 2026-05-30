import 'package:flutter/material.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/services/notification_service.dart';

void showDevOptionsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _DevOptionsSheet(),
  );
}

class _DevOptionsSheet extends StatefulWidget {
  const _DevOptionsSheet();

  @override
  State<_DevOptionsSheet> createState() => _DevOptionsSheetState();
}

class _DevOptionsSheetState extends State<_DevOptionsSheet> {
  bool _isGeneratingData = false;
  bool _isTestingNotification = false;
  bool _debugLogsEnabled = NotificationService().debugLogsEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.code, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Developer Options',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isGeneratingData ? null : _generateSampleData,
              icon: _isGeneratingData
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.dataset),
              label: Text(_isGeneratingData
                  ? 'Generating...'
                  : 'Generate Sample Data'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isTestingNotification ? null : _triggerTestNotification,
              icon: _isTestingNotification
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.notifications_active),
              label: Text(_isTestingNotification
                  ? 'Running...'
                  : 'Trigger Test Notification'),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notification Debug Logs'),
            subtitle: const Text('Print verbose scheduling info'),
            value: _debugLogsEnabled,
            onChanged: (value) {
              setState(() {
                _debugLogsEnabled = value;
                NotificationService().debugLogsEnabled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateSampleData() async {
    setState(() => _isGeneratingData = true);
    try {
      await DatabaseService().generateSampleData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sample data generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingData = false);
    }
  }

  Future<void> _triggerTestNotification() async {
    setState(() => _isTestingNotification = true);
    try {
      await NotificationService().scheduleTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Triggered! Check logs for details.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTestingNotification = false);
    }
  }
}
