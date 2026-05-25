import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/services/database_service.dart';
import 'package:calorize/services/ai_routing_service.dart';
import 'package:calorize/data/models/ai_provider.dart';
import 'package:calorize/data/models/user_profile.dart';
import 'package:calorize/widgets/ai_provider_form.dart';

class AiProvidersScreen extends StatefulWidget {
  const AiProvidersScreen({super.key});

  @override
  State<AiProvidersScreen> createState() => _AiProvidersScreenState();
}

class _AiProvidersScreenState extends State<AiProvidersScreen> {
  List<AIProvider> _providers = [];
  bool _roundRobin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final profile = await DatabaseService().getUserProfile();
    if (mounted) {
      setState(() {
        _providers = profile?.aiProviders ?? [];
        _roundRobin = profile?.aiRoutingMode == 'round_robin';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProviders() async {
    await DatabaseService().saveAiProviders(_providers);
    await AiRoutingService().loadSettings();
  }

  Future<void> _saveRoutingMode(bool roundRobin) async {
    final profile = await DatabaseService().getUserProfile();
    if (profile != null) {
      final isar = DatabaseService().isar;
      await isar.writeTxn(() async {
        profile.aiRoutingMode = roundRobin ? 'round_robin' : null;
        await isar.userProfiles.put(profile);
      });
    }
    setState(() => _roundRobin = roundRobin);
    await AiRoutingService().loadSettings();
  }

  Future<void> _addProvider() async {
    if (_providers.length >= 3) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 AI providers allowed')),
        );
      }
      return;
    }

    final result = await showModalBottomSheet<AIProvider>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiProviderForm(),
    );

    if (result != null) {
      setState(() => _providers.add(result));
      await _saveProviders();
    }
  }

  Future<void> _editProvider(int index) async {
    final result = await showModalBottomSheet<AIProvider>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiProviderForm(
        existingProvider: _providers[index],
      ),
    );

    if (result != null) {
      setState(() => _providers[index] = result);
      await _saveProviders();
    }
  }

  Future<void> _deleteProvider(int index) async {
    setState(() => _providers.removeAt(index));
    await _saveProviders();
  }

  Future<void> _toggleProvider(int index, bool value) async {
    setState(() => _providers[index].isEnabled = value);
    await _saveProviders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure AI Providers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      'Configure multiple AI providers for fallback. Drag to reorder priority.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _providers.isEmpty
                        ? _buildEmptyState()
                        : _buildProviderList(),
                  ),
                  if (_providers.length >= 2) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _roundRobin
                            ? 'Round Robin — providers are used in rotation. If one fails, the next is tried.'
                            : 'Fill Up First — top provider is always used. Falls through on failure.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _buildRoutingToggle(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProvider,
        backgroundColor: _providers.length >= 3
            ? Colors.grey
            : Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap + to add your first AI provider',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _providers.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _providers.removeAt(oldIndex);
          _providers.insert(newIndex, item);
        });
        _saveProviders();
      },
      itemBuilder: (context, index) {
        final provider = _providers[index];
        return _buildProviderTile(provider, index);
      },
    );
  }

  Widget _buildProviderTile(AIProvider provider, int index) {
    final iconData = _getProviderIcon(provider.providerId);

    return Card(
      key: ValueKey('${provider.providerId}_$index'),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: Colors.grey[500],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name ?? provider.providerId ?? 'Unknown',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (provider.modelId != null)
                    Text(
                      provider.modelId!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            Switch(
              value: provider.isEnabled ?? true,
              onChanged: (val) => _toggleProvider(index, val),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.grey[500]),
              onPressed: () => _editProvider(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteProvider(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutingToggle() {
    final enabled = _providers.length >= 2;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Routing Mode',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _roundRobin
                          ? 'Round Robin — providers are used in rotation'
                          : 'Fill Up First — top provider is always used',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _roundRobin,
                onChanged: enabled ? (val) => _saveRoutingMode(val) : null,
              ),
            ],
          ),
          if (!enabled)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Add 2+ providers to change routing mode',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(String? providerId) {
    switch (providerId) {
      case 'openai':
        return Icons.smart_toy_outlined;
      case 'google':
        return Icons.auto_awesome;
      case 'anthropic':
        return Icons.psychology_outlined;
      default:
        return Icons.build_outlined;
    }
  }
}
