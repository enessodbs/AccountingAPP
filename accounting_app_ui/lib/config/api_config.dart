class ApiConfig {
  // Backend API base URL
  // Build-time override: flutter run --dart-define=API_BASE_URL=http://your-server/api
  // Android emülatör için 10.0.2.2 kullanılmalıdır.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5188/api',
  );

  // Endpoint paths
  static const String auth = '$baseUrl/auth';
  static const String employees = '$baseUrl/employees';
  static const String invoices = '$baseUrl/invoices';
  static const String products = '$baseUrl/products';
  static const String transactions = '$baseUrl/transactions';
  static const String dashboard = '$baseUrl/dashboard';
  static const String departments = '$baseUrl/departments';
  static const String positions = '$baseUrl/positions';
  static const String categories = '$baseUrl/categories';
  static const String lookup = '$baseUrl/Lookup';
  static const String currencies = '$baseUrl/Currencies';
  static const String roles = '$baseUrl/Roles';
  static const String businessContacts = '$baseUrl/businesscontacts';
  static const String stockMovements = '$baseUrl/stockmovements';
  static const String reports = '$baseUrl/reports';
  static const String userManagement = '$baseUrl/usermanagement';
  static const String leads = '$baseUrl/leads';
  static const String opportunities = '$baseUrl/opportunities';
  static const String pipelineStages = '$baseUrl/pipelinestages';
  static const String activities = '$baseUrl/activities';
  static const String crmTasks = '$baseUrl/crmtasks';
}

