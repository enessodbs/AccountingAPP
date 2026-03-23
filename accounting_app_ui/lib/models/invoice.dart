class Invoice {
  final String id;
  final String invoiceNumber;
  final String contactName;
  final int type; // 1: Sales, 2: Purchase
  final int status; // 1: Pending, 2: Paid, 3: Cancelled, 4: Overdue
  final DateTime issueDate;
  final DateTime dueDate;
  final double totalAmount;
  final String currencyCode;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.contactName,
    required this.type,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    required this.totalAmount,
    required this.currencyCode,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'] ?? '',
      contactName: json['contactName'] ?? '',
      type: json['type'] ?? 1,
      status: json['status'] ?? 1,
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currencyCode: json['currencyCode'] ?? 'TRY',
    );
  }

  String get statusText {
    switch (status) {
      case 1: return 'Ödenmemiş';
      case 2: return 'Ödenmiş';
      case 3: return 'İptal';
      case 4: return 'Gecikmiş';
      case 5: return 'Kesilmiş';
      case 6: return 'Kesilecek';
      default: return 'Bilinmiyor';
    }
  }

  String get typeText {
    return type == 1 ? 'Satış' : 'Alım';
  }

  bool get isPaid => status == 2;
  bool get isOverdue => status == 4;
}

class InvoiceDetail {
  final String id;
  final String invoiceNumber;
  final String businessContactId;
  final String contactName;
  final String? contactTaxNumber;
  final String? contactTaxOffice;
  final String? contactAddress;
  final int type;
  final int status;
  final DateTime issueDate;
  final DateTime dueDate;
  final double subTotal;
  final double taxAmount;
  final double totalAmount;
  final int currencyId;
  final String currencyCode;
  final double exchangeRate;
  final List<InvoiceLineItem> lines;
  final String? waybillNumber;
  final String? paymentTerms;

  InvoiceDetail({
    required this.id,
    required this.invoiceNumber,
    required this.businessContactId,
    required this.contactName,
    this.contactTaxNumber,
    this.contactTaxOffice,
    this.contactAddress,
    required this.type,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    required this.subTotal,
    required this.taxAmount,
    required this.totalAmount,
    required this.currencyId,
    required this.currencyCode,
    required this.exchangeRate,
    required this.lines,
    this.waybillNumber,
    this.paymentTerms,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'] ?? '',
      businessContactId: json['businessContactId'] ?? '',
      contactName: json['contactName'] ?? '',
      contactTaxNumber: json['contactTaxNumber'],
      contactTaxOffice: json['contactTaxOffice'],
      contactAddress: json['contactAddress'],
      type: json['type'] ?? 1,
      status: json['status'] ?? 1,
      issueDate: DateTime.parse(json['issueDate']),
      dueDate: DateTime.parse(json['dueDate']),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currencyId: json['currencyId'] ?? 1,
      currencyCode: json['currencyCode'] ?? 'TRY',
      exchangeRate: (json['exchangeRate'] ?? 1).toDouble(),
      lines: (json['lines'] as List<dynamic>?)
              ?.map((l) => InvoiceLineItem.fromJson(l))
              .toList() ??
          [],
      waybillNumber: json['waybillNumber'],
      paymentTerms: json['paymentTerms'],
    );
  }
}

class InvoiceLineItem {
  final String id;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double taxRate;
  final double lineTotal;

  InvoiceLineItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    required this.lineTotal,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      id: json['id'],
      productName: json['productName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      lineTotal: (json['lineTotal'] ?? 0).toDouble(),
    );
  }
}
