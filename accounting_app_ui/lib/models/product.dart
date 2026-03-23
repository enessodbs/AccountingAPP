class Product {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String? serialNumber;
  final String? barcode;
  final double unitPrice;
  final int type; // 1: Physical, 2: Service
  final double stockQuantity;
  final int categoryId;
  final String categoryName;
  final int currencyId;
  final String currencyCode;
  final String currencySymbol;
  final bool isActive;

  Product({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.serialNumber,
    this.barcode,
    required this.unitPrice,
    required this.type,
    required this.stockQuantity,
    required this.categoryId,
    required this.categoryName,
    required this.currencyId,
    required this.currencyCode,
    required this.currencySymbol,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      serialNumber: json['serialNumber'],
      barcode: json['barcode'],
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      type: json['type'] ?? 1,
      stockQuantity: (json['stockQuantity'] ?? 0).toDouble(),
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      currencyId: json['currencyId'] ?? 1,
      currencyCode: json['currencyCode'] ?? 'TRY',
      currencySymbol: json['currencySymbol'] ?? '₺',
      isActive: json['isActive'] ?? true,
    );
  }

  String get typeText => type == 1 ? 'Fiziksel' : 'Hizmet';
  bool get isPhysical => type == 1;
}
