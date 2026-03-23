class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String identityNumber;
  final int departmentId;
  final String departmentName;
  final int positionId;
  final String positionName;
  final String contactEmail;
  final String phone;
  final double baseSalary;
  final int currencyId;
  final String currencyCode;
  final bool isActive;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.identityNumber,
    required this.departmentId,
    required this.departmentName,
    required this.positionId,
    required this.positionName,
    required this.contactEmail,
    required this.phone,
    required this.baseSalary,
    required this.currencyId,
    required this.currencyCode,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      identityNumber: json['identityNumber'] ?? '',
      departmentId: json['departmentId'] ?? 0,
      departmentName: json['departmentName'] ?? '',
      positionId: json['positionId'] ?? 0,
      positionName: json['positionName'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      phone: json['phone'] ?? '',
      baseSalary: (json['baseSalary'] ?? 0).toDouble(),
      currencyId: json['currencyId'] ?? 1,
      currencyCode: json['currencyCode'] ?? 'TRY',
      isActive: json['isActive'] ?? true,
    );
  }
}

/// Lookup model for Department dropdown
class DepartmentLookup {
  final int id;
  final String name;

  DepartmentLookup({required this.id, required this.name});

  factory DepartmentLookup.fromJson(Map<String, dynamic> json) {
    return DepartmentLookup(id: json['id'], name: json['name']);
  }
}

/// Lookup model for Position dropdown (with departmentId for filtering)
class PositionLookup {
  final int id;
  final String name;
  final int departmentId;

  PositionLookup({required this.id, required this.name, required this.departmentId});

  factory PositionLookup.fromJson(Map<String, dynamic> json) {
    return PositionLookup(
      id: json['id'],
      name: json['name'],
      departmentId: json['departmentId'] ?? 0,
    );
  }
}

/// Lookup model for Category dropdown
class CategoryLookup {
  final int id;
  final String name;

  CategoryLookup({required this.id, required this.name});

  factory CategoryLookup.fromJson(Map<String, dynamic> json) {
    return CategoryLookup(id: json['id'], name: json['name']);
  }
}
