class ConfigurationItem {
  final String id;
  final String key;
  final String value;
  final String environment;
  final String version;
  final DateTime lastUpdated;
  final bool isActive;

  ConfigurationItem({
    required this.id,
    required this.key,
    required this.value,
    required this.environment,
    required this.version,
    required this.lastUpdated,
    required this.isActive,
  });

  // Mock data
  static List<ConfigurationItem> get mockData {
    return [
      ConfigurationItem(
        id: '1',
        key: 'FEATURE_DARK_MODE',
        value: 'true',
        environment: 'Production',
        version: '1.0.2',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
      ),
      ConfigurationItem(
        id: '2',
        key: 'API_RATE_LIMIT',
        value: '1000',
        environment: 'Production',
        version: '2.1.0',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      ),
      ConfigurationItem(
        id: '3',
        key: 'MAINTENANCE_MODE',
        value: 'false',
        environment: 'Staging',
        version: '0.9.5',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
        isActive: false,
      ),
      ConfigurationItem(
        id: '4',
        key: 'SUPPORT_EMAIL',
        value: 'support@example.com',
        environment: 'Production',
        version: '1.0.0',
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
        isActive: true,
      ),
      ConfigurationItem(
        id: '5',
        key: 'MAX_UPLOAD_SIZE',
        value: '50MB',
        environment: 'Development',
        version: '3.0.1',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
        isActive: true,
      ),
    ];
  }
}
