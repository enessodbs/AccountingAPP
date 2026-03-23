import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart'; // To access themeService
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/employee_list_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/products_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/business_contacts_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/currencies_screen.dart';
import '../screens/quotes_screen.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  List<String> _userRoles = [];
  bool _isLoadingRoles = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final roles = await AuthService().getRoles();
    if (mounted) {
      setState(() {
        _userRoles = roles;
        _isLoadingRoles = false;
      });
    }
  }

  bool _hasRole(String role) {
    return _userRoles.contains('Admin') || _userRoles.contains(role);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: const SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.account_balance, size: 36, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Muhasebe Yönetimi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Finans & İK Sistemi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
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
                // Dashboard is visible to everyone
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: 'dashboard',
                  destination: const DashboardScreen(),
                ),

                // HR & Admin
                if (_hasRole('İK'))
                  _buildNavItem(
                    context,
                    icon: Icons.people_rounded,
                    title: 'Personeller',
                    route: 'employees',
                    destination: const EmployeeListScreen(),
                  ),

                // Accounting & Admin
                if (_hasRole('Muhasebe')) ...[
                  _buildNavItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    title: 'Faturalar',
                    route: 'invoices',
                    destination: const InvoicesScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.inventory_2_rounded,
                    title: 'Ürünler & Stok',
                    route: 'products',
                    destination: const ProductsScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.swap_horiz_rounded,
                    title: 'İşlemler',
                    route: 'transactions',
                    destination: const TransactionsScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.business_rounded,
                    title: 'İş Ortakları',
                    route: 'contacts',
                    destination: const BusinessContactsScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'Raporlar',
                    route: 'reports',
                    destination: const ReportsScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.currency_exchange_rounded,
                    title: 'Döviz Kurları',
                    route: 'currencies',
                    destination: const CurrenciesScreen(),
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.description_rounded,
                    title: 'Teklifler',
                    route: 'quotes',
                    destination: const QuotesScreen(),
                  ),
                ],
                const Divider(height: 1),
              ],
            ),
          ),
          const Divider(height: 1),
          // Tema değiştirici
          SwitchListTile(
            dense: true,
            secondary: Icon(
              themeService.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            title: Text(
              'Karanlık Tema',
              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
            ),
            value: themeService.isDarkMode,
            onChanged: (val) {
              themeService.toggleTheme();
            },
          ),
          ListTile(
            dense: true,
            leading: Icon(Icons.logout_rounded, size: 20, color: theme.colorScheme.error),
            title: Text(
              'Çıkış Yap',
              style: TextStyle(fontSize: 14, color: theme.colorScheme.error),
            ),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required Widget destination,
  }) {
    final isSelected = widget.currentRoute == route;
    final theme = Theme.of(context);

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 20,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {
        Navigator.pop(context); // close drawer
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
    );
  }

  void _handleLogout(BuildContext context) async {
    Navigator.pop(context); // close drawer
    await AuthService().logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
