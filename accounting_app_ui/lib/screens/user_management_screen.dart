import 'package:flutter/material.dart';
import '../widgets/responsive_scaffold.dart';
import '../services/user_management_service.dart';
import '../l10n/app_localizations.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  final _service = UserManagementService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _allRoles = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _service.getUsers(),
        _service.getRoles(),
      ]);
      setState(() {
        _users = results[0];
        _allRoles = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    final q = _searchQuery.toLowerCase();
    return _users.where((u) {
      final username = (u['username'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return username.contains(q) || email.contains(q);
    }).toList();
  }

  // ─── Role helpers ───
  static const Map<String, IconData> _roleIcons = {
    'Admin': Icons.admin_panel_settings,
    'Muhasebe': Icons.account_balance_wallet,
    'İK': Icons.people_alt,
    'Satış': Icons.trending_up,
    'SatışYönetici': Icons.supervisor_account,
    'Pazarlama': Icons.campaign,
  };

  static const Map<String, Color> _roleColors = {
    'Admin': Color(0xFFEF4444),
    'Muhasebe': Color(0xFF3B82F6),
    'İK': Color(0xFF10B981),
    'Satış': Color(0xFFF59E0B),
    'SatışYönetici': Color(0xFFE97316),
    'Pazarlama': Color(0xFF8B5CF6),
  };

  Color _getRoleColor(String role) => _roleColors[role] ?? Colors.grey;
  IconData _getRoleIcon(String role) => _roleIcons[role] ?? Icons.person;

  String _localizeRole(String role, AppLocalizations l) {
    switch (role) {
      case 'Admin': return l.get('roleAdmin');
      case 'Muhasebe': return l.get('roleAccounting');
      case 'İK': return l.get('roleHR');
      case 'Satış': return l.get('roleSales');
      case 'SatışYönetici': return l.get('roleSalesManager');
      case 'Pazarlama': return l.get('roleMarketing');
      default: return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentRoute: 'userManagement',
      title: l.get('userManagement'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: l.get('refresh'),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateUserDialog(context, l, theme),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l.get('addUser')),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: [
          Tab(icon: const Icon(Icons.people, size: 18), text: l.get('userList')),
          Tab(icon: const Icon(Icons.security, size: 18), text: l.get('roleOverview')),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(l, theme)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsersTab(l, theme),
                    _buildRolesTab(l, theme),
                  ],
                ),
    );
  }

  // ─── Error State ───
  Widget _buildErrorState(AppLocalizations l, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: Text(l.get('retryBtn')),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  TAB 1 — Kullanıcı Listesi
  // ═══════════════════════════════════════════════════
  Widget _buildUsersTab(AppLocalizations l, ThemeData theme) {
    final filtered = _filteredUsers;
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: l.get('searchUser'),
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _statChip(theme, Icons.people, '${_users.length}', l.get('totalUsers')),
              const SizedBox(width: 8),
              _statChip(theme, Icons.security, '${_allRoles.length}', l.get('totalRoles')),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // User list
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(l.get('noData'), style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _buildUserCard(filtered[i], l, theme),
                ),
        ),
      ],
    );
  }

  Widget _statChip(ThemeData theme, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6)), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, AppLocalizations l, ThemeData theme) {
    final roles = (user['roles'] as List?)?.map((r) => r['name'] as String).toList() ?? [];
    final username = user['username'] ?? '';
    final email = user['email'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRoleEditDialog(context, user, l, theme),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: roles.isNotEmpty ? _getRoleColor(roles.first).withOpacity(0.15) : theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  roles.isNotEmpty ? _getRoleIcon(roles.first) : Icons.person,
                  color: roles.isNotEmpty ? _getRoleColor(roles.first) : theme.colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(username, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
                        if (roles.contains('Admin')) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: _getRoleColor('Admin').withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('ADMIN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _getRoleColor('Admin'))),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(email, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                    const SizedBox(height: 6),
                    // Role chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: roles.map((role) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _getRoleColor(role).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getRoleIcon(role), size: 12, color: _getRoleColor(role)),
                              const SizedBox(width: 4),
                              Text(_localizeRole(role, l),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getRoleColor(role))),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Actions — PopupMenu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'editInfo',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(l.get('editUserInfo'), style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'editRoles',
                    child: Row(
                      children: [
                        Icon(Icons.security_rounded, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(l.get('editRoles'), style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'resetPassword',
                    child: Row(
                      children: [
                        Icon(Icons.lock_reset_rounded, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(l.get('resetPassword'), style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 16, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Text(l.get('delete'), style: TextStyle(fontSize: 13, color: theme.colorScheme.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (action) {
                  switch (action) {
                    case 'editInfo':
                      _showEditUserInfoDialog(context, user, l, theme);
                      break;
                    case 'editRoles':
                      _showRoleEditDialog(context, user, l, theme);
                      break;
                    case 'resetPassword':
                      _showResetPasswordDialog(context, user, l, theme);
                      break;
                    case 'delete':
                      _showDeleteConfirm(context, user, l, theme);
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  //  TAB 2 — Rol Genel Görünümü
  // ═══════════════════════════════════════════════════
  Widget _buildRolesTab(AppLocalizations l, ThemeData theme) {
    // Her rol için kullanıcı sayısını hesapla
    final roleUserCounts = <String, int>{};
    for (final role in _allRoles) {
      final roleName = role['name'] as String;
      roleUserCounts[roleName] = _users.where((u) {
        final roles = (u['roles'] as List?)?.map((r) => r['name']).toList() ?? [];
        return roles.contains(roleName);
      }).length;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rol açıklama kartı
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.08),
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.get('roleOverviewDesc'),
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Rol kartları
        ..._allRoles.map((role) {
          final roleName = role['name'] as String;
          final count = roleUserCounts[roleName] ?? 0;
          final color = _getRoleColor(roleName);
          final icon = _getRoleIcon(roleName);
          final desc = _getRoleDescription(roleName, l);

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(_localizeRole(roleName, l), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$count ${l.get('user')}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(desc, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.55))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _getRoleDescription(String role, AppLocalizations l) {
    switch (role) {
      case 'Admin': return l.get('roleAdminDesc');
      case 'Muhasebe': return l.get('roleAccountingDesc');
      case 'İK': return l.get('roleHRDesc');
      case 'Satış': return l.get('roleSalesDesc');
      case 'SatışYönetici': return l.get('roleSalesManagerDesc');
      case 'Pazarlama': return l.get('roleMarketingDesc');
      default: return '';
    }
  }

  // ═══════════════════════════════════════════════════
  //  DIALOGS
  // ═══════════════════════════════════════════════════

  // ─── Rol Düzenleme Dialog ───
  void _showRoleEditDialog(BuildContext context, Map<String, dynamic> user, AppLocalizations l, ThemeData theme) {
    final currentRoles = (user['roles'] as List?)?.map((r) => r['name'] as String).toList() ?? [];
    final selectedRoles = Set<String>.from(currentRoles);
    final username = user['username'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.security_rounded, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${l.get('editRoles')} — $username', style: const TextStyle(fontSize: 16))),
                ],
              ),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.get('selectRolesDesc'), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 16),
                    ..._allRoles.map((role) {
                      final roleName = role['name'] as String;
                      final isSelected = selectedRoles.contains(roleName);
                      final color = _getRoleColor(roleName);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? color : theme.dividerColor,
                            width: isSelected ? 1.5 : 1,
                          ),
                          color: isSelected ? color.withOpacity(0.06) : null,
                        ),
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          title: Row(
                            children: [
                              Icon(_getRoleIcon(roleName), size: 18, color: color),
                              const SizedBox(width: 8),
                              Text(_localizeRole(roleName, l), style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                            ],
                          ),
                          subtitle: Text(_getRoleDescription(roleName, l), style: const TextStyle(fontSize: 10)),
                          value: isSelected,
                          activeColor: color,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedRoles.add(roleName);
                              } else {
                                selectedRoles.remove(roleName);
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.get('cancel')),
                ),
                ElevatedButton.icon(
                  onPressed: selectedRoles.isEmpty
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _updateUserRoles(user['id'], selectedRoles.toList(), l);
                        },
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: Text(l.get('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateUserRoles(String userId, List<String> roles, AppLocalizations l) async {
    try {
      final success = await _service.updateUserRoles(userId, roles);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.get('rolesUpdated')), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.get('error')}: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── Kullanıcı Silme Dialog ───
  void _showDeleteConfirm(BuildContext context, Map<String, dynamic> user, AppLocalizations l, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 24),
            const SizedBox(width: 8),
            Text(l.get('deleteUser'), style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: Text(
          l.get('deleteUserConfirm').replaceFirst('{name}', user['username'] ?? ''),
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.get('cancel')),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _service.deleteUser(user['id']);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.get('userDeleted')), backgroundColor: Colors.green),
                  );
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_rounded, size: 16),
            label: Text(l.get('delete')),
          ),
        ],
      ),
    );
  }

  // ─── Kullanıcı Oluşturma Dialog ───
  void _showCreateUserDialog(BuildContext context, AppLocalizations l, ThemeData theme) {
    final usernameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String? selectedRole = _allRoles.isNotEmpty ? _allRoles.first['name'] : null;
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(l.get('addUser'), style: const TextStyle(fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameCtrl,
                      decoration: InputDecoration(
                        labelText: l.get('username'),
                        prefixIcon: const Icon(Icons.person_outline, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: l.get('password'),
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: l.get('role'),
                        prefixIcon: const Icon(Icons.security_outlined, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: _allRoles.map((r) {
                        final name = r['name'] as String;
                        return DropdownMenuItem(
                          value: name,
                          child: Row(
                            children: [
                              Icon(_getRoleIcon(name), size: 16, color: _getRoleColor(name)),
                              const SizedBox(width: 8),
                              Text(_localizeRole(name, l), style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedRole = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.get('cancel')),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (usernameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty || selectedRole == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.get('fillAllFields')), backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    try {
                      await _service.createUser(
                        username: usernameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        password: passwordCtrl.text,
                        roleName: selectedRole!,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.get('userCreated')), backgroundColor: Colors.green),
                        );
                        _loadData();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(l.get('create')),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // ─── Kullanıcı Bilgisi Düzenleme Dialog ───
  void _showEditUserInfoDialog(BuildContext context, Map<String, dynamic> user, AppLocalizations l, ThemeData theme) {
    final usernameCtrl = TextEditingController(text: user['username'] ?? '');
    final emailCtrl = TextEditingController(text: user['email'] ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.edit_rounded, color: theme.colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${l.get('editUserInfo')} — ${user['username']}', style: const TextStyle(fontSize: 16))),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.get('editUserInfoDesc'), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 16),
                    TextField(
                      controller: usernameCtrl,
                      decoration: InputDecoration(
                        labelText: l.get('username'),
                        prefixIcon: const Icon(Icons.person_outline, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: Text(l.get('cancel')),
                ),
                ElevatedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newUsername = usernameCtrl.text.trim();
                          final newEmail = emailCtrl.text.trim();
                          if (newUsername.isEmpty || newEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.get('fillAllFields')), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            final msg = await _service.updateUserInfo(
                              user['id'],
                              username: newUsername,
                              email: newEmail,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg), backgroundColor: Colors.green),
                              );
                              _loadData();
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded, size: 16),
                  label: Text(l.get('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Şifre Sıfırlama Dialog ───
  void _showResetPasswordDialog(BuildContext context, Map<String, dynamic> user, AppLocalizations l, ThemeData theme) {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure1 = true;
    bool obscure2 = true;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.lock_reset_rounded, color: Colors.orange, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${l.get('resetPassword')} — ${user['username']}', style: const TextStyle(fontSize: 16))),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.get('resetPasswordWarning'),
                              style: const TextStyle(fontSize: 11, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: obscure1,
                      decoration: InputDecoration(
                        labelText: l.get('newPassword'),
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: Icon(obscure1 ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscure1 = !obscure1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmCtrl,
                      obscureText: obscure2,
                      decoration: InputDecoration(
                        labelText: l.get('confirmPassword'),
                        prefixIcon: const Icon(Icons.lock_outline, size: 18),
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          icon: Icon(obscure2 ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setDialogState(() => obscure2 = !obscure2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: Text(l.get('cancel')),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final pw = passwordCtrl.text;
                          final confirm = confirmCtrl.text;
                          if (pw.isEmpty || pw.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.get('passwordMinLength')), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (pw != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.get('passwordsDoNotMatch')), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            final msg = await _service.resetPassword(user['id'], pw);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg), backgroundColor: Colors.green),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  icon: isSaving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_reset_rounded, size: 16),
                  label: Text(l.get('resetPassword')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
