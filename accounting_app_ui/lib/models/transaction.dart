class Transaction {
  final String id;
  final String? businessContactId;
  final String? businessContactName;
  final String? invoiceId;
  final String? invoiceNumber;
  final int type; // 1: Collection, 2: Payment
  final double amount;
  final int currencyId;
  final String currencyCode;
  final String currencySymbol;
  final double exchangeRate;
  final DateTime date;
  final int paymentMethod; // 1: Cash, 2: BankTransfer, 3: CreditCard
  final String? description;
  final bool isActive;

  Transaction({
    required this.id,
    this.businessContactId,
    this.businessContactName,
    this.invoiceId,
    this.invoiceNumber,
    required this.type,
    required this.amount,
    required this.currencyId,
    required this.currencyCode,
    required this.currencySymbol,
    required this.exchangeRate,
    required this.date,
    required this.paymentMethod,
    this.description,
    required this.isActive,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      businessContactId: json['businessContactId'],
      businessContactName: json['businessContactName'],
      invoiceId: json['invoiceId'],
      invoiceNumber: json['invoiceNumber'],
      type: json['type'] ?? 1,
      amount: (json['amount'] ?? 0).toDouble(),
      currencyId: json['currencyId'] ?? 1,
      currencyCode: json['currencyCode'] ?? 'TRY',
      currencySymbol: json['currencySymbol'] ?? '₺',
      exchangeRate: (json['exchangeRate'] ?? 1).toDouble(),
      date: DateTime.parse(json['date']),
      paymentMethod: json['paymentMethod'] ?? 1,
      description: json['description'],
      isActive: json['isActive'] ?? true,
    );
  }

  String get typeText => type == 1 ? 'Tahsilat' : 'Ödeme';
  bool get isIncome => type == 1;

  String get paymentMethodText {
    switch (paymentMethod) {
      case 1: return 'Nakit';
      case 2: return 'Havale/EFT';
      case 3: return 'Kredi Kartı';
      default: return 'Bilinmiyor';
    }
  }
}
