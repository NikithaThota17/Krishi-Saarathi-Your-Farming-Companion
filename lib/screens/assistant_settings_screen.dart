import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_settings_service.dart';

class AssistantSettingsScreen extends StatefulWidget {
  const AssistantSettingsScreen({super.key});

  @override
  State<AssistantSettingsScreen> createState() => _AssistantSettingsScreenState();
}

class _AssistantSettingsScreenState extends State<AssistantSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController(
    text: 'gemini-2.5-flash',
  );
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _apiKeyController.text = prefs.getString('gemini_api_key') ?? '';
      _modelController.text =
          prefs.getString('gemini_model')?.trim().isNotEmpty == true
              ? prefs.getString('gemini_model')!
              : 'gemini-2.5-flash';
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', _apiKeyController.text.trim());
    await prefs.setString('gemini_model', _modelController.text.trim());
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI settings saved')),
    );
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gemini_api_key');
    await prefs.remove('gemini_model');
    if (!mounted) return;
    setState(() {
      _apiKeyController.clear();
      _modelController.text = 'gemini-2.5-flash';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI settings cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = AppSettingsService.instance.isTelugu;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTelugu
              ? '\u0c0e\u0c10 \u0c38\u0c46\u0c1f\u0c4d\u0c1f\u0c3f\u0c02\u0c17\u0c4d\u0c38\u0c4d'
              : 'AI Settings',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isTelugu
                ? '\u0c07\u0c28\u0c4d-\u0c2f\u0c3e\u0c2a\u0c4d \u0c30\u0c48\u0c24\u0c41 \u0c38\u0c39\u0c3e\u0c2f\u0c15\u0c3e\u0c28\u0c3f\u0c15\u0c3f \u0c2e\u0c40 Gemini API key \u0c28\u0c41 \u0c07\u0c15\u0c4d\u0c15\u0c21 \u0c38\u0c47\u0c35\u0c4d \u0c1a\u0c47\u0c2f\u0c02\u0c21\u0c3f.'
                : 'Save your Gemini API key here for the in-app farming assistant.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _modelController,
            decoration: InputDecoration(
              labelText: isTelugu ? '\u0c2e\u0c3e\u0c21\u0c32\u0c4d' : 'Model',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(
              _isSaving
                  ? (isTelugu
                      ? '\u0c38\u0c47\u0c35\u0c4d \u0c05\u0c35\u0c41\u0c24\u0c4b\u0c02\u0c26\u0c3f...'
                      : 'Saving...')
                  : (isTelugu
                      ? '\u0c0e\u0c10 \u0c38\u0c46\u0c1f\u0c4d\u0c1f\u0c3f\u0c02\u0c17\u0c4d\u0c38\u0c4d \u0c38\u0c47\u0c35\u0c4d \u0c1a\u0c47\u0c2f\u0c02\u0c21\u0c3f'
                      : 'Save AI Settings'),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.delete_outline),
            label: Text(
              isTelugu
                  ? '\u0c38\u0c47\u0c35\u0c4d \u0c1a\u0c47\u0c38\u0c3f\u0c28 key \u0c24\u0c40\u0c38\u0c3f\u0c35\u0c47\u0c2f\u0c02\u0c21\u0c3f'
                  : 'Clear Saved Key',
            ),
          ),
        ],
      ),
    );
  }
}
