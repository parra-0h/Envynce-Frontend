import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/configuration_model.dart';
import '../theme/app_theme.dart';
import '../providers/config_provider.dart';

class ConfigurationModal extends ConsumerStatefulWidget {
  final String applicationId;
  final String environmentId;
  final ConfigurationItem? item;

  const ConfigurationModal({
    super.key,
    required this.applicationId,
    required this.environmentId,
    this.item,
  });

  @override
  ConsumerState<ConfigurationModal> createState() => _ConfigurationModalState();
}

class _ConfigurationModalState extends ConsumerState<ConfigurationModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  late TextEditingController _descController;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.item?.key ?? '');
    _valueController = TextEditingController(text: widget.item?.value ?? '');
    _descController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _isActive = widget.item?.isActive ?? true;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item == null
                      ? 'Create Configuration'
                      : 'Edit Configuration',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure key-value pairs for your application environment.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _keyController,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  readOnly: widget.item != null,
                  decoration: const InputDecoration(
                    labelText: 'Key Name',
                    hintText: 'e.g. FEATURE_FLAG_NEW_DASHBOARD',
                    helperText: 'Use uppercase snake_case for consistency.',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a key'
                      : null,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    hintText: 'e.g. true',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a value'
                      : null,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'What is this configuration for?',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v ?? false),
                      activeColor: AppTheme.primaryColor,
                    ),
                    const Text(
                      'Active',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    const Tooltip(
                      message:
                          'Inactive configurations are ignored by the client SDK.',
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.item == null
                                  ? 'Create Config'
                                  : 'Save Changes',
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final data = {
          if (widget.item != null) 'id': widget.item!.id,
          'key': _keyController.text,
          'value': _valueController.text,
          'description': _descController.text,
          'application_id': int.tryParse(widget.applicationId) ?? 0,
          'environment_id': int.tryParse(widget.environmentId) ?? 0,
          'is_active': _isActive,
        };

        await ref.read(saveConfigurationProvider(data).future);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
