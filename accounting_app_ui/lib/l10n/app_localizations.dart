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
    'incomeExpenseTable': 'Gelir Gider Tablosu',
    'incomeExpenseTableDesc': 'Geçmiş dönem faturaları, tarih ve gelir/gider filtreleri',
    'periodStart': 'Başlangıç',
    'periodEnd': 'Bitiş',
    'applyPreviousMonth': 'Önceki ay',
    'typeFilterAll': 'Tümü',
    'typeFilterIncome': 'Gelir',
    'typeFilterExpense': 'Gider',
    'monthNetProfit': 'Dönem net karı',
    'yearNetProfit': 'Yıl net karı',
    'invoiceDate': 'Tarih',
    'invoiceAmount': 'Tutar',
    'counterparty': 'Cari',
    'currencies': 'Döviz Kurları',
    'quotes': 'Teklifler',
    'darkTheme': 'Karanlık Tema',
    'language': 'Dil',
    'barcodeStockEntry': 'Barkod Stok Girişi',
    'aiAssistant': 'AI Asistanı',
    'leads': 'Müşteri Adayları',
    'pipeline': 'Satış Hunisi',
    'opportunities': 'Fırsatlar',
    'newLead': 'Yeni Aday',
    'newOpportunity': 'Yeni Fırsat',
    'companyName': 'Firma Adı',
    'contactPerson': 'İlgili Kişi',
    'estimatedValue': 'Tahmini Değer',
    'leadSource': 'Kaynak',
    'leadStatus': 'Durum',
    'score': 'Puan',
    'probability': 'Olasılık',
    'expectedCloseDate': 'Tahmini Kapanış',
    'amount': 'Tutar',
    'stage': 'Aşama',
    'owner': 'Sorumlu',
    'won': 'Kazanıldı',
    'lost': 'Kaybedildi',
    'moveToStage': 'Aşamaya Taşı',
    'noLeadsYet': 'Henüz müşteri adayı yok',
    'noOpportunities': 'Henüz fırsat yok',
    'dragToMove': 'Taşımak için sürükleyin',

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
    'roleSales': 'Satış',
    'roleSalesManager': 'Satış Yöneticisi',
    'roleMarketing': 'Pazarlama',

    // Role Descriptions
    'roleAdminDesc': 'Tüm modüllere tam erişim',
    'roleAccountingDesc': 'Fatura, işlem, raporlama yönetimi',
    'roleHRDesc': 'Personel ve departman yönetimi',
    'roleSalesDesc': 'Lead, fırsat ve aktivite yönetimi (kendi verileri)',
    'roleSalesManagerDesc': 'Tüm satış verileri + pipeline yönetimi',
    'roleMarketingDesc': 'Lead oluşturma + kampanya yönetimi',

    // User Management
    'userManagement': 'Kullanıcı Yönetimi',
    'userList': 'Kullanıcılar',
    'roleOverview': 'Rol Görünümü',
    'roleOverviewDesc': 'Her rol, sisteme erişim düzeyini belirler. Kullanıcılar birden fazla role sahip olabilir.',
    'addUser': 'Kullanıcı Ekle',
    'searchUser': 'Kullanıcı ara...',
    'totalUsers': 'Kullanıcı',
    'totalRoles': 'Rol',
    'user': 'kullanıcı',
    'editRoles': 'Rolleri Düzenle',
    'selectRolesDesc': 'Bu kullanıcıya atanacak rolleri seçin:',
    'rolesUpdated': 'Roller başarıyla güncellendi',
    'deleteUser': 'Kullanıcıyı Sil',
    'deleteUserConfirm': '"{name}" kullanıcısı pasife alınacak. Onaylıyor musunuz?',
    'userDeleted': 'Kullanıcı silindi',
    'userCreated': 'Kullanıcı oluşturuldu',
    'role': 'Rol',
    'fillAllFields': 'Lütfen tüm alanları doldurun',
    'error': 'Hata',
    'editUserInfo': 'Bilgileri Düzenle',
    'editUserInfoDesc': 'Kullanıcı adı ve e-posta adresini güncelleyebilirsiniz.',
    'resetPassword': 'Şifre Sıfırla',
    'resetPasswordWarning': 'Bu işlem kullanıcının mevcut şifresini değiştirecektir. Kullanıcı yeni şifre ile giriş yapabilecektir.',
    'newPassword': 'Yeni Şifre',
    'confirmPassword': 'Şifre Tekrar',
    'passwordMinLength': 'Şifre en az 6 karakter olmalıdır',
    'passwordsDoNotMatch': 'Şifreler eşleşmiyor',

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
    'incomeExpenseTable': 'Income & Expense',
    'incomeExpenseTableDesc': 'Past invoices with date and income/expense filters',
    'periodStart': 'Start',
    'periodEnd': 'End',
    'applyPreviousMonth': 'Previous month',
    'typeFilterAll': 'All',
    'typeFilterIncome': 'Income',
    'typeFilterExpense': 'Expense',
    'monthNetProfit': 'Period net profit',
    'yearNetProfit': 'Year net profit',
    'invoiceDate': 'Date',
    'invoiceAmount': 'Amount',
    'counterparty': 'Counterparty',
    'currencies': 'Exchange Rates',
    'quotes': 'Quotes',
    'darkTheme': 'Dark Theme',
    'language': 'Language',
    'barcodeStockEntry': 'Barcode Stock Entry',
    'aiAssistant': 'AI Assistant',
    'leads': 'Leads',
    'pipeline': 'Sales Pipeline',
    'opportunities': 'Opportunities',
    'newLead': 'New Lead',
    'newOpportunity': 'New Opportunity',
    'companyName': 'Company Name',
    'contactPerson': 'Contact Person',
    'estimatedValue': 'Estimated Value',
    'leadSource': 'Source',
    'leadStatus': 'Status',
    'score': 'Score',
    'probability': 'Probability',
    'expectedCloseDate': 'Expected Close',
    'amount': 'Amount',
    'stage': 'Stage',
    'owner': 'Owner',
    'won': 'Won',
    'lost': 'Lost',
    'moveToStage': 'Move to Stage',
    'noLeadsYet': 'No leads yet',
    'noOpportunities': 'No opportunities yet',
    'dragToMove': 'Drag to move',

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
    'roleSales': 'Sales',
    'roleSalesManager': 'Sales Manager',
    'roleMarketing': 'Marketing',

    // Role Descriptions
    'roleAdminDesc': 'Full access to all modules',
    'roleAccountingDesc': 'Invoice, transaction & reporting management',
    'roleHRDesc': 'Employee & department management',
    'roleSalesDesc': 'Lead, opportunity & activity management (own data)',
    'roleSalesManagerDesc': 'All sales data + pipeline management',
    'roleMarketingDesc': 'Lead creation + campaign management',

    // User Management
    'userManagement': 'User Management',
    'userList': 'Users',
    'roleOverview': 'Role Overview',
    'roleOverviewDesc': 'Each role defines the level of access to the system. Users can have multiple roles.',
    'addUser': 'Add User',
    'searchUser': 'Search users...',
    'totalUsers': 'Users',
    'totalRoles': 'Roles',
    'user': 'user',
    'editRoles': 'Edit Roles',
    'selectRolesDesc': 'Select roles to assign to this user:',
    'rolesUpdated': 'Roles updated successfully',
    'deleteUser': 'Delete User',
    'deleteUserConfirm': '"{name}" will be deactivated. Confirm?',
    'userDeleted': 'User deleted',
    'userCreated': 'User created',
    'role': 'Role',
    'fillAllFields': 'Please fill in all fields',
    'error': 'Error',
    'editUserInfo': 'Edit Info',
    'editUserInfoDesc': 'You can update the username and email address.',
    'resetPassword': 'Reset Password',
    'resetPasswordWarning': 'This will change the user\'s current password. The user will need to log in with the new password.',
    'newPassword': 'New Password',
    'confirmPassword': 'Confirm Password',
    'passwordMinLength': 'Password must be at least 6 characters',
    'passwordsDoNotMatch': 'Passwords do not match',

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
