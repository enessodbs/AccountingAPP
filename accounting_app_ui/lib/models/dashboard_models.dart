class DashboardSummary {
  final double monthlyIncome;
  final double monthlyExpense;
  final int pendingInvoiceCount;
  final int overdueInvoiceCount;
  final String currencySymbol;
  final List<UpcomingItem> upcomingItems;
  final List<RecentInvoice> recentInvoices;
  final List<StockAlert> stockAlerts;
  final List<OverdueInvoice> overdueInvoices;

  DashboardSummary({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.pendingInvoiceCount,
    required this.overdueInvoiceCount,
    required this.currencySymbol,
    required this.upcomingItems,
    required this.recentInvoices,
    required this.stockAlerts,
    required this.overdueInvoices,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      monthlyIncome: (json['monthlyIncome'] ?? 0).toDouble(),
      monthlyExpense: (json['monthlyExpense'] ?? 0).toDouble(),
      pendingInvoiceCount: json['pendingInvoiceCount'] ?? 0,
      overdueInvoiceCount: json['overdueInvoiceCount'] ?? 0,
      currencySymbol: json['currencySymbol'] ?? '₺',
      upcomingItems: (json['upcomingItems'] as List<dynamic>?)
              ?.map((e) => UpcomingItem.fromJson(e))
              .toList() ??
          [],
      recentInvoices: (json['recentInvoices'] as List<dynamic>?)
              ?.map((e) => RecentInvoice.fromJson(e))
              .toList() ??
          [],
      stockAlerts: (json['stockAlerts'] as List<dynamic>?)
              ?.map((e) => StockAlert.fromJson(e))
              .toList() ??
          [],
      overdueInvoices: (json['overdueInvoices'] as List<dynamic>?)
              ?.map((e) => OverdueInvoice.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UpcomingItem {
  final String title;
  final String date;
  final double amount;
  final String currencySymbol;
  final String type; // "income" or "expense"

  UpcomingItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.currencySymbol,
    required this.type,
  });

  factory UpcomingItem.fromJson(Map<String, dynamic> json) {
    return UpcomingItem(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currencySymbol: json['currencySymbol'] ?? '₺',
      type: json['type'] ?? 'expense',
    );
  }

  bool get isIncome => type == 'income';
}

class RecentInvoice {
  final String id;
  final String invoiceNumber;
  final String contactName;
  final double totalAmount;
  final String currencyCode;
  final int status;
  final DateTime issueDate;

  RecentInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.contactName,
    required this.totalAmount,
    required this.currencyCode,
    required this.status,
    required this.issueDate,
  });

  factory RecentInvoice.fromJson(Map<String, dynamic> json) {
    return RecentInvoice(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'] ?? '',
      contactName: json['contactName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currencyCode: json['currencyCode'] ?? 'TRY',
      status: json['status'] ?? 1,
      issueDate: DateTime.parse(json['issueDate']),
    );
  }
}

class MonthlyChartData {
  final List<MonthlyDataPoint> incomeData;
  final List<MonthlyDataPoint> expenseData;

  MonthlyChartData({required this.incomeData, required this.expenseData});

  factory MonthlyChartData.fromJson(Map<String, dynamic> json) {
    return MonthlyChartData(
      incomeData: (json['incomeData'] as List<dynamic>?)
              ?.map((e) => MonthlyDataPoint.fromJson(e))
              .toList() ??
          [],
      expenseData: (json['expenseData'] as List<dynamic>?)
              ?.map((e) => MonthlyDataPoint.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MonthlyDataPoint {
  final int month;
  final String monthName;
  final double amount;

  MonthlyDataPoint({
    required this.month,
    required this.monthName,
    required this.amount,
  });

  factory MonthlyDataPoint.fromJson(Map<String, dynamic> json) {
    return MonthlyDataPoint(
      month: json['month'] ?? 1,
      monthName: json['monthName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class StockAlert {
  final int productId;
  final String productName;
  final String productCode;
  final double currentStock;
  final double minStock;

  StockAlert({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.currentStock,
    required this.minStock,
  });

  factory StockAlert.fromJson(Map<String, dynamic> json) {
    return StockAlert(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      productCode: json['productCode'] ?? '',
      currentStock: (json['currentStock'] ?? 0).toDouble(),
      minStock: (json['minStock'] ?? 10).toDouble(),
    );
  }
}

class OverdueInvoice {
  final String id;
  final String invoiceNumber;
  final String contactName;
  final double totalAmount;
  final String currencyCode;
  final DateTime dueDate;
  final int daysOverdue;

  OverdueInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.contactName,
    required this.totalAmount,
    required this.currencyCode,
    required this.dueDate,
    required this.daysOverdue,
  });

  factory OverdueInvoice.fromJson(Map<String, dynamic> json) {
    return OverdueInvoice(
      id: json['id'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      contactName: json['contactName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currencyCode: json['currencyCode'] ?? 'TRY',
      dueDate: DateTime.parse(json['dueDate']),
      daysOverdue: json['daysOverdue'] ?? 0,
    );
  }
}
