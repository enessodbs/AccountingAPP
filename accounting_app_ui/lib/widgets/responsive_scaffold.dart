import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/employee_list_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/products_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/business_contacts_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/income_expense_table_screen.dart';
import '../screens/currencies_screen.dart';
import '../screens/quotes_screen.dart';
import '../screens/barcode_stock_entry_screen.dart';
import '../screens/user_management_screen.dart';
import '../screens/leads_screen.dart';
import '../screens/pipeline_board_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/barcode_stock_entry_screen.dart';
/// A responsive scaffold that shows a persistent side rail on wide screens
/// and a standard drawer on narrow ones.
class ResponsiveScaffold extends StatefulWidget {
  final String currentRoute;
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  const ResponsiveScaffold({
    super.key,
    required this.currentRoute,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottom,
  });

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  List<String> _userRoles = [];
  List<String> _userPermissions = [];
  bool _isLoadingRoles = true;
  bool _railExtended = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final perms = await AuthService().getPermissions();
    final roles = await AuthService().getRoles();
    if (mounted) {
      setState(() {
        _userRoles = roles;
        _userPermissions = perms;
        _isLoadingRoles = false;
      });
    }
  }

  bool _hasPermission(String perm) =>
      _userRoles.contains('Admin') || _userPermissions.contains(perm);

  String _getRoleBadge() {
    if (_userRoles.contains('Admin')) return 'Admin';
    if (_userRoles.contains('SatışYönetici')) return 'Satış Yöneticisi';
    if (_userRoles.contains('Satış')) return 'Satış';
    if (_userRoles.contains('Pazarlama')) return 'Pazarlama';
    if (_userRoles.contains('Muhasebe')) return 'Muhasebe';
    if (_userRoles.contains('İK')) return 'İK';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;
    final isMedium = screenWidth >= 600 && screenWidth < 900;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    if (isWide || isMedium) {
      return Scaffold(
        body: Row(
          children: [
            _buildSideNav(theme, l, isWide),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.title, style: const TextStyle(fontSize: 18)),
                  centerTitle: true,
                  actions: widget.actions,
                  bottom: widget.bottom,
                  automaticallyImplyLeading: false,
                ),
                body: widget.body,
                floatingActionButton: widget.floatingActionButton,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile: standard drawer
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
        actions: widget.actions,
        bottom: widget.bottom,
      ),
      drawer: _buildDrawer(theme, l),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  // ─── Wide side navigation ───
  Widget _buildSideNav(ThemeData theme, AppLocalizations l, bool isWide) {
    final extended = isWide && _railExtended;
    final width = extended ? 240.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 72,
            padding: EdgeInsets.symmetric(horizontal: extended ? 16 : 8),
            alignment: extended ? Alignment.centerLeft : Alignment.center,
            child: extended
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.get('appTitle'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis),
                            if (_getRoleBadge().isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(_getRoleBadge(),
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                  ),
          ),
          const Divider(height: 1),
          // Nav items
          if (_isLoadingRoles)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSideNavItem(theme, Icons.dashboard_rounded, l.get('dashboard'), 'dashboard', const DashboardScreen(), extended),
                  if (_hasPermission('Personeller'))
                    _buildSideNavItem(theme, Icons.people_rounded, 'Personeller', 'employees', const EmployeeListScreen(), extended),
                  if (_hasPermission('Faturalar'))
                    _buildSideNavItem(theme, Icons.receipt_long_rounded, 'Faturalar', 'invoices', const InvoicesScreen(), extended),
                  if (_hasPermission('Urunler')) ...[
                    _buildSideNavItem(theme, Icons.inventory_2_rounded, 'Ürünler & Stok', 'products', const ProductsScreen(), extended),
                    _buildSideNavItem(theme, Icons.qr_code_scanner_rounded, 'Barkod ile Stok', 'barcodeStock', const BarcodeStockEntryScreen(), extended),
                  ],
                  if (_hasPermission('Faturalar') || _hasPermission('Urunler'))
                    _buildSideNavItem(theme, Icons.swap_horiz_rounded, 'İşlemler', 'transactions', const TransactionsScreen(), extended),
                  if (_hasPermission('IsOrtaklari'))
                    _buildSideNavItem(theme, Icons.business_rounded, 'İş Ortakları', 'contacts', const BusinessContactsScreen(), extended),
                  if (_hasPermission('Raporlar')) ...[
                    _buildSideNavItem(theme, Icons.bar_chart_rounded, 'Raporlar', 'reports', const ReportsScreen(), extended),
                    _buildSideNavItem(theme, Icons.currency_exchange_rounded, 'Döviz Kurları', 'currencies', const CurrenciesScreen(), extended),
                  ],
                  if (_hasPermission('Faturalar'))
                    _buildSideNavItem(theme, Icons.description_rounded, 'Teklifler', 'quotes', const QuotesScreen(), extended),
                  if (_hasPermission('Satis')) ...[
                    _buildSideNavItem(theme, Icons.person_search_rounded, l.get('leads'), 'leads', const LeadsScreen(), extended),
                    _buildSideNavItem(theme, Icons.view_kanban_rounded, l.get('pipeline'), 'pipeline', const PipelineBoardScreen(), extended),
                  ],
                  if (_hasPermission('KullaniciYonetimi') || _userRoles.contains('Admin'))
                    _buildSideNavItem(theme, Icons.admin_panel_settings_rounded, l.get('userManagement'), 'userManagement', const UserManagementScreen(), extended),
                  if (_userRoles.contains('Admin'))
                    _buildSideNavItem(theme, Icons.settings_rounded, 'Sistem Ayarları', 'settings', const SettingsScreen(), extended),
                ],
              ),
            ),
          const Divider(height: 1),
          // Theme toggle
          _buildBottomAction(
            theme,
            themeService.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            l.get('darkTheme'),
            extended,
            onTap: () => themeService.toggleTheme(),
            trailing: extended
                ? Switch(
                    value: themeService.isDarkMode,
                    onChanged: (_) => themeService.toggleTheme(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                : null,
          ),
          // Language toggle
          _buildBottomAction(
            theme,
            Icons.language_rounded,
            l.get('language'),
            extended,
            onTap: () => localeService.toggleLocale(),
            trailing: extended
                ? Text(
                    localeService.isTurkish ? 'TR' : 'EN',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.colorScheme.primary),
                  )
                : null,
          ),
          // Collapse / expand
          if (isWide)
            _buildBottomAction(
              theme,
              _railExtended ? Icons.chevron_left : Icons.chevron_right,
              _railExtended ? l.get('collapseMenu') : l.get('expandMenu'),
              extended,
              onTap: () => setState(() => _railExtended = !_railExtended),
            ),
          // Logout
          _buildBottomAction(
            theme,
            Icons.logout_rounded,
            l.get('logout'),
            extended,
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSideNavItem(ThemeData theme, IconData icon, String title, String route, Widget destination, bool extended) {
    final isSelected = widget.currentRoute == route;
    return Tooltip(
      message: extended ? '' : title,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (!isSelected) {
            Navigator.pushReplacement(context, _smoothRoute(destination));
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(horizontal: extended ? 12 : 0, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6)),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(ThemeData theme, IconData icon, String title, bool extended,
      {VoidCallback? onTap, Color? iconColor, Color? textColor, Widget? trailing}) {
    return Tooltip(
      message: extended ? '' : title,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: extended ? 16 : 0, vertical: 10),
          child: Row(
            mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: TextStyle(fontSize: 13, color: textColor ?? theme.colorScheme.onSurface)),
                ),
                if (trailing != null) trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Mobile drawer (reuses existing pattern) ───
  Widget _buildDrawer(ThemeData theme, AppLocalizations l) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.account_balance, size: 36, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(l.get('appTitle'),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(l.get('appSubtitle'),
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      if (_getRoleBadge().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_getRoleBadge(),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoadingRoles)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(context, theme, Icons.dashboard_rounded, l.get('dashboard'), 'dashboard', const DashboardScreen()),
                  if (_hasPermission('Personeller'))
                    _buildDrawerItem(context, theme, Icons.people_rounded, l.get('employees'), 'employees', const EmployeeListScreen()),
                  if (_hasPermission('Faturalar'))
                    _buildDrawerItem(context, theme, Icons.receipt_long_rounded, l.get('invoices'), 'invoices', const InvoicesScreen()),
                  if (_hasPermission('Urunler'))
                    _buildDrawerItem(context, theme, Icons.inventory_2_rounded, l.get('products'), 'products', const ProductsScreen()),
                  if (_hasPermission('Faturalar') || _hasPermission('Urunler'))
                    _buildDrawerItem(context, theme, Icons.swap_horiz_rounded, l.get('transactions'), 'transactions', const TransactionsScreen()),
                  if (_hasPermission('IsOrtaklari'))
                    _buildDrawerItem(context, theme, Icons.business_rounded, l.get('businessContacts'), 'contacts', const BusinessContactsScreen()),
                  if (_hasPermission('Raporlar')) ...[
                    _buildDrawerItem(context, theme, Icons.bar_chart_rounded, l.get('reports'), 'reports', const ReportsScreen()),
                    _buildDrawerItem(context, theme, Icons.currency_exchange_rounded, l.get('currencies'), 'currencies', const CurrenciesScreen()),
                  ],
                  if (_hasPermission('Faturalar'))
                    _buildDrawerItem(context, theme, Icons.description_rounded, l.get('quotes'), 'quotes', const QuotesScreen()),
                  if (_hasPermission('Satis')) ...[
                    _buildDrawerItem(context, theme, Icons.person_search_rounded, l.get('leads'), 'leads', const LeadsScreen()),
                    _buildDrawerItem(context, theme, Icons.view_kanban_rounded, l.get('pipeline'), 'pipeline', const PipelineBoardScreen()),
                  ],
                  if (_hasPermission('KullaniciYonetimi') || _userRoles.contains('Admin'))
                    _buildDrawerItem(context, theme, Icons.admin_panel_settings_rounded, l.get('userManagement'), 'userManagement', const UserManagementScreen()),
                  if (_userRoles.contains('Admin'))
                    _buildDrawerItem(context, theme, Icons.settings_rounded, 'Sistem Ayarları', 'settings', const SettingsScreen()),
                  const Divider(height: 1),
                ],
              ),
            ),
          const Divider(height: 1),
          // Theme
          SwitchListTile(
            dense: true,
            secondary: Icon(
              themeService.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: theme.colorScheme.primary, size: 20,
            ),
            title: Text(l.get('darkTheme'),
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
            value: themeService.isDarkMode,
            onChanged: (_) => themeService.toggleTheme(),
          ),
          // Language
          ListTile(
            dense: true,
            leading: Icon(Icons.language_rounded, size: 20, color: theme.colorScheme.primary),
            title: Text(l.get('language'),
                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
            trailing: Text(localeService.isTurkish ? 'TR' : 'EN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.colorScheme.primary)),
            onTap: () => localeService.toggleLocale(),
          ),
          // Logout
          ListTile(
            dense: true,
            leading: Icon(Icons.logout_rounded, size: 20, color: theme.colorScheme.error),
            title: Text(l.get('logout'),
                style: TextStyle(fontSize: 14, color: theme.colorScheme.error)),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, ThemeData theme, IconData icon, String title, String route, Widget destination) {
    final isSelected = widget.currentRoute == route;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6)),
      title: Text(title,
          style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          Navigator.pushReplacement(context, _smoothRoute(destination));
        }
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    try {
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null && scaffoldState.isDrawerOpen) {
        Navigator.pop(context);
      }
    } catch (_) {}
    await AuthService().logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        _smoothRoute(const LoginScreen()),
        (route) => false,
      );
    }
  }

  Route _smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
