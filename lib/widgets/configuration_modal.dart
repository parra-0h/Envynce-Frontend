import 'package:flutter/material.dart';
import '../models/configuration_model.dart';
import '../theme/app_theme.dart';

class ConfigurationModal extends StatefulWidget {
  final ConfigurationItem? item;

  const ConfigurationModal({super.key, this.item});

  @override
  State<ConfigurationModal> createState() => _ConfigurationModalState();
}

class _ConfigurationModalState extends State<ConfigurationModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late TextEditingController _valueController;
  late String _environment;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.item?.key ?? '');
    _valueController = TextEditingController(text: widget.item?.value ?? '');
    _environment = widget.item?.environment ?? 'Production';
    _isActive = widget.item?.isActive ?? true;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
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
              DropdownButtonFormField<String>(
                value: _environment,
                decoration: const InputDecoration(
                  labelText: 'Target Environment',
                ),
                items: ['Production', 'Staging', 'Development']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _environment = value!),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      widget.item == null ? 'Create Config' : 'Save Changes',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
