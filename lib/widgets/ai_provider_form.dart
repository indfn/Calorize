import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calorize/data/models/ai_provider.dart';

class AiProviderForm extends StatefulWidget {
  final AIProvider? existingProvider;

  const AiProviderForm({super.key, this.existingProvider});

  @override
  State<AiProviderForm> createState() => _AiProviderFormState();
}

class _AiProviderFormState extends State<AiProviderForm> {
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelIdController = TextEditingController();

  String? _selectedPreset;
  String _apiType = 'openai';
  final Map<String, String?> _fieldErrors = {};

  static const _presets = {
    'openai': {
      'label': 'OpenAI',
      'baseUrl': 'https://api.openai.com/v1',
      'modelId': 'gpt-4o',
      'apiType': 'openai'
    },
    'google': {
      'label': 'Google',
      'baseUrl': 'https://generativelanguage.googleapis.com/v1beta',
      'modelId': 'gemini-2.5-flash',
      'apiType': 'google'
    },
    'anthropic': {
      'label': 'Anthropic',
      'baseUrl': 'https://api.anthropic.com/v1',
      'modelId': 'claude-3-5-sonnet-20241022',
      'apiType': 'anthropic'
    },
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingProvider != null) {
      final p = widget.existingProvider!;
      _nameController.text = p.name ?? '';
      _apiKeyController.text = p.apiKey ?? '';
      _baseUrlController.text = p.baseUrl ?? '';
      _modelIdController.text = p.modelId ?? '';
      _selectedPreset = p.providerId;
      _apiType = p.apiType ?? 'openai';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelIdController.dispose();
    super.dispose();
  }

  void _selectPreset(String key) {
    setState(() {
      _selectedPreset = key;
      if (key != 'custom') {
        final preset = _presets[key]!;
        _nameController.text = preset['label']!;
        _baseUrlController.text = preset['baseUrl']!;
        _modelIdController.text = preset['modelId']!;
        _apiType = preset['apiType']!;
      } else {
        _nameController.clear();
        _baseUrlController.clear();
        _modelIdController.clear();
        _apiType = 'openai';
      }
    });
  }

  void _save() {
    _fieldErrors.clear();
    bool valid = true;

    if (_apiKeyController.text.isEmpty) {
      _fieldErrors['apiKey'] = 'API Key is required';
      valid = false;
    }
    if (_baseUrlController.text.isEmpty) {
      _fieldErrors['baseUrl'] = 'Base URL is required';
      valid = false;
    } else {
      final uri = Uri.tryParse(_baseUrlController.text);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        _fieldErrors['baseUrl'] = 'Invalid URL format';
        valid = false;
      }
    }
    if (_nameController.text.isEmpty) {
      _fieldErrors['name'] = 'Name is required';
      valid = false;
    }

    if (!valid) {
      setState(() {});
      return;
    }

    final provider = AIProvider()
      ..providerId = _selectedPreset ?? 'custom'
      ..name = _nameController.text
      ..apiKey = _apiKeyController.text
      ..baseUrl = _baseUrlController.text
      ..modelId = _modelIdController.text
      ..apiType = _apiType
      ..isEnabled = true;

    Navigator.pop(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 20),
            Text(
              widget.existingProvider != null ? 'Edit Provider' : 'Add AI Provider',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Provider',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _presetCard('OpenAI', 'openai', Icons.smart_toy_outlined)),
                const SizedBox(width: 8),
                Expanded(child: _presetCard('Google', 'google', Icons.auto_awesome)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _presetCard('Anthropic', 'anthropic', Icons.psychology_outlined)),
                const SizedBox(width: 8),
                Expanded(child: _presetCard('Custom', 'custom', Icons.build_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            if (_fieldErrors.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please fix the errors below.',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildTextField(_nameController, 'Name', 'My Provider', errorText: _fieldErrors['name']),
            const SizedBox(height: 12),
            _buildTextField(_apiKeyController, 'API Key', 'Paste your key here', obscure: true, errorText: _fieldErrors['apiKey']),
            if (_selectedPreset == 'custom') ...[
              const SizedBox(height: 12),
              _buildTextField(_baseUrlController, 'Base URL', 'https://api.example.com/v1', errorText: _fieldErrors['baseUrl']),
              const SizedBox(height: 12),
              _buildApiTypeDropdown(),
            ],
            if (_selectedPreset != null && _selectedPreset != 'custom') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _baseUrlController.text,
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildTextField(_modelIdController, 'Model ID', 'gpt-4o'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(widget.existingProvider != null ? 'Save' : 'Add'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _presetCard(String label, String key, IconData icon) {
    final selected = _selectedPreset == key;

    return GestureDetector(
      onTap: () => _selectPreset(key),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
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
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool obscure = false,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildApiTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _apiType,
      decoration: InputDecoration(
        labelText: 'API Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'openai', child: Text('OpenAI Compatible')),
        DropdownMenuItem(value: 'google', child: Text('Google Gemini')),
        DropdownMenuItem(value: 'anthropic', child: Text('Anthropic Claude')),
      ],
      onChanged: (val) {
        if (val != null) setState(() => _apiType = val);
      },
    );
  }
}
