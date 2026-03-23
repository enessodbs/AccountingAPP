class ApiConfig {
  // Backend API base URL
  // Flutter Web'de localhost, backend ile aynı makinadaysa sorunsuz çalışır.
  // Android emülatör için 10.0.2.2 kullanılmalıdır.
  static const String baseUrl = 'http://localhost:5188/api';

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
  static const String currencies = '$baseUrl/currencies';
  static const String businessContacts = '$baseUrl/businesscontacts';
  static const String stockMovements = '$baseUrl/stockmovements';
  static const String reports = '$baseUrl/reports';
}
