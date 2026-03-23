import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('tr'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get(String key) {
    final map = locale.languageCode == 'tr' ? _tr : _en;
    return map[key] ?? _tr[key] ?? key;
  }

  // ─── Turkish ───
  static const Map<String, String> _tr = {
    // General
    'appTitle': 'Muhasebe Yönetimi',
    'appSubtitle': 'Finans & İK Sistemi',
    'login': 'GİRİŞ YAP',
    'logout': 'Çıkış Yap',
    'cancel': 'İptal',
    'delete': 'Sil',
    'save': 'Kaydet',
    'create': 'Oluştur',
    'update': 'Güncelle',
    'search': 'Ara...',
    'required': 'Zorunlu',
    'refresh': 'Yenile',
    'retryBtn': 'Tekrar Dene',
    'noData': 'Veri bulunamadı.',

    // Auth
    'username': 'KULLANICI ADI',
    'password': 'ŞİFRE',
    'rememberMe': 'Beni Hatırla',
    'forgotPassword': 'Şifremi Unuttum?',
    'forgotPasswordTitle': 'Şifremi Unuttum',
    'forgotPasswordDesc': 'Lütfen sistemde kayıtlı e-posta adresinizi girin.',
    'send': 'GÖNDER',
    'loginWelcome': 'Hoş Geldiniz.',
    'loginWelcomeDesc': 'Muhasebe uygulamamıza hoş geldiniz.\nUygulama üzerinden gelir giderlerinizi hızlıca yönetebilirsiniz.',

    // Navigation / Menu
    'dashboard': 'Ana Ekran',
    'employees': 'Personeller',
    'invoices': 'Faturalar',
    'products': 'Ürünler & Stok',
    'transactions': 'İşlemler',
    'businessContacts': 'İş Ortakları',
    'reports': 'Raporlar',
    'currencies': 'Döviz Kurları',
    'quotes': 'Teklifler',
    'darkTheme': 'Karanlık Tema',
    'language': 'Dil',
    'barcodeStockEntry': 'Barkod Stok Girişi',

    // Dashboard
    'income': 'Gelir',
    'expense': 'Gider',
    'pending': 'Bekleyen',
    'invoiceLabel': 'Fatura',
    'monthlyChart': 'Aylık Gelir & Gider',
    'monthDistribution': 'Bu Ay Dağılım',
    'net': 'Net',
    'overdueInvoices': 'Vadesi Geçen Faturalar',
    'lowStockAlerts': 'Düşük Stok Uyarıları',
    'recentInvoices': 'Son Faturalar',
    'upcomingTransactions': 'Yaklaşan İşlemler',
    'viewAll': 'Tümünü Gör',
    'view': 'Görüntüle',
    'overdueCount': '{count} faturanın vadesi geçmiş!',
    'lowStockCount': '{count} üründe stok düşük!',
    'noInvoicesYet': 'Henüz fatura yok',
    'noUpcoming': 'Yaklaşan işlem bulunmuyor',
    'daysOverdue': '{days} gün gecikmiş',

    // Products
    'searchProduct': 'Ürün ara...',
    'noProductsFound': 'Kayıtlı ürün bulunamadı.',
    'addProduct': 'Ürün Ekle',
    'newProduct': 'Yeni Ürün',
    'physical': 'Fiziksel',
    'service': 'Hizmet',
    'productCode': 'Ürün Kodu',
    'productName': 'Ürün Adı',
    'serialNo': 'Seri No',
    'barcode': 'Barkod',
    'description': 'Açıklama',
    'unitPrice': 'Birim Fiyat (₺)',
    'stock': 'Stok',
    'category': 'Kategori',
    'deleteProduct': 'Ürünü Sil',
    'deleteProductConfirm': '"{name}" ürünü silinecek. Onaylıyor musunuz?',
    'productDeleted': 'Ürün silindi',
    'productCreated': 'Ürün oluşturuldu',

    // Barcode Stock Entry
    'barcodeStockTitle': 'Barkod ile Stok Girişi',
    'scanBarcode': 'Barkod Tara',
    'scanBarcodeHint': 'Barkod tarayın veya elle girin',
    'quantity': 'Miktar',
    'stockIn': 'Stok Girişi',
    'stockOut': 'Stok Çıkışı',
    'productNotFound': 'Ürün bulunamadı',
    'stockUpdated': 'Stok güncellendi',
    'lastScans': 'Son Taramalar',

    // Employees  
    'searchEmployee': 'Personel ara...',
    'addEmployee': 'Personel Ekle',
    'noEmployeesFound': 'Personel bulunamadı.',

    // Invoices
    'allInvoices': 'Tümü',
    'salesInvoices': 'Satış',
    'purchaseInvoices': 'Alış',

    // Invoice Status
    'statusPaid': 'Ödenmiş',
    'statusIssued': 'Kesilmiş',
    'statusToBeIssued': 'Kesilecek',
    'statusCancelled': 'İptal',
    'statusUnpaid': 'Ödenmemiş',

    // Roles
    'roleAdmin': 'Admin',
    'roleAccounting': 'Muhasebe',
    'roleHR': 'İK',

    // About
    'about': 'Hakkımızda',
    'aboutDesc': 'Bu uygulama, küçük ve orta ölçekli işletmelerin finansal işlemlerini kolayca yönetebilmesi için geliştirilmiş modern bir muhasebe çözümüdür.',
    'contact': 'İletişim',
    'sendEmail': 'Bize E-Posta Gönderin',

    // Responsive
    'collapseMenu': 'Menüyü Daralt',
    'expandMenu': 'Menüyü Genişlet',
  };

  // ─── English ───
  static const Map<String, String> _en = {
    // General
    'appTitle': 'Accounting Management',
    'appSubtitle': 'Finance & HR System',
    'login': 'LOGIN',
    'logout': 'Logout',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'save': 'Save',
    'create': 'Create',
    'update': 'Update',
    'search': 'Search...',
    'required': 'Required',
    'refresh': 'Refresh',
    'retryBtn': 'Try Again',
    'noData': 'No data found.',

    // Auth
    'username': 'USERNAME',
    'password': 'PASSWORD',
    'rememberMe': 'Remember me',
    'forgotPassword': 'Forgot password?',
    'forgotPasswordTitle': 'Forgot Password',
    'forgotPasswordDesc': 'Enter your registered email address.',
    'send': 'SEND',
    'loginWelcome': 'Welcome.',
    'loginWelcomeDesc': 'Welcome to our accounting app.\nManage your income and expenses quickly.',

    // Navigation / Menu
    'dashboard': 'Dashboard',
    'employees': 'Employees',
    'invoices': 'Invoices',
    'products': 'Products & Stock',
    'transactions': 'Transactions',
    'businessContacts': 'Business Contacts',
    'reports': 'Reports',
    'currencies': 'Exchange Rates',
    'quotes': 'Quotes',
    'darkTheme': 'Dark Theme',
    'language': 'Language',
    'barcodeStockEntry': 'Barcode Stock Entry',

    // Dashboard
    'income': 'Income',
    'expense': 'Expense',
    'pending': 'Pending',
    'invoiceLabel': 'Invoice',
    'monthlyChart': 'Monthly Income & Expense',
    'monthDistribution': 'This Month Distribution',
    'net': 'Net',
    'overdueInvoices': 'Overdue Invoices',
    'lowStockAlerts': 'Low Stock Alerts',
    'recentInvoices': 'Recent Invoices',
    'upcomingTransactions': 'Upcoming Transactions',
    'viewAll': 'View All',
    'view': 'View',
    'overdueCount': '{count} invoices are overdue!',
    'lowStockCount': '{count} products have low stock!',
    'noInvoicesYet': 'No invoices yet',
    'noUpcoming': 'No upcoming transactions',
    'daysOverdue': '{days} days overdue',

    // Products
    'searchProduct': 'Search products...',
    'noProductsFound': 'No products found.',
    'addProduct': 'Add Product',
    'newProduct': 'New Product',
    'physical': 'Physical',
    'service': 'Service',
    'productCode': 'Product Code',
    'productName': 'Product Name',
    'serialNo': 'Serial No',
    'barcode': 'Barcode',
    'description': 'Description',
    'unitPrice': 'Unit Price (₺)',
    'stock': 'Stock',
    'category': 'Category',
    'deleteProduct': 'Delete Product',
    'deleteProductConfirm': '"{name}" will be deleted. Confirm?',
    'productDeleted': 'Product deleted',
    'productCreated': 'Product created',

    // Barcode Stock Entry
    'barcodeStockTitle': 'Barcode Stock Entry',
    'scanBarcode': 'Scan Barcode',
    'scanBarcodeHint': 'Scan barcode or enter manually',
    'quantity': 'Quantity',
    'stockIn': 'Stock In',
    'stockOut': 'Stock Out',
    'productNotFound': 'Product not found',
    'stockUpdated': 'Stock updated',
    'lastScans': 'Recent Scans',

    // Employees
    'searchEmployee': 'Search employees...',
    'addEmployee': 'Add Employee',
    'noEmployeesFound': 'No employees found.',

    // Invoices
    'allInvoices': 'All',
    'salesInvoices': 'Sales',
    'purchaseInvoices': 'Purchases',

    // Invoice Status
    'statusPaid': 'Paid',
    'statusIssued': 'Issued',
    'statusToBeIssued': 'Pending',
    'statusCancelled': 'Cancelled',
    'statusUnpaid': 'Unpaid',

    // Roles
    'roleAdmin': 'Admin',
    'roleAccounting': 'Accounting',
    'roleHR': 'HR',

    // About
    'about': 'About Us',
    'aboutDesc': 'A modern accounting solution for small and medium businesses to easily manage their financial operations.',
    'contact': 'Contact',
    'sendEmail': 'Send Us an Email',

    // Responsive
    'collapseMenu': 'Collapse Menu',
    'expandMenu': 'Expand Menu',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
