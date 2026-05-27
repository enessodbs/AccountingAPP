import '../widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../services/lookup_service.dart';
import '../widgets/responsive_scaffold.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeService _employeeService = EmployeeService();
  final LookupService _lookupService = LookupService();
  List<Employee> _employees = [];
  List<DepartmentLookup> _departments = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<Employee> get _filteredEmployees {
    if (_searchQuery.isEmpty) return _employees;
    final q = _searchQuery.toLowerCase();
    return _employees.where((e) =>
        '${e.firstName} ${e.lastName}'.toLowerCase().contains(q) ||
        e.departmentName.toLowerCase().contains(q) ||
        e.contactEmail.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _employeeService.getEmployees(),
        _lookupService.getDepartments(),
      ]);
      setState(() {
        _employees = results[0] as List<Employee>;
        _departments = results[1] as List<DepartmentLookup>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CustomToast.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: 'employees',
      title: _isSearching ? '' : 'Personel Listesi',
      actions: [
        if (_isSearching)
          SizedBox(
            width: 200,
            child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Personel ara...',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
          ),
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) { _searchQuery = ''; _searchController.clear(); }
          }),
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredEmployees.isEmpty
              ? const Center(child: Text('Kayıtlı personel bulunamadı.'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (context, index) => _buildEmployeeCard(_filteredEmployees[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployeeDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Personel Ekle'),
      ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _copyContactToClipboard(employee),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: employee.isActive ? Colors.blue.shade100 : Colors.grey.shade300,
                child: Text(
                  employee.firstName.isNotEmpty ? employee.firstName[0] : '?',
                  style: TextStyle(
                    color: employee.isActive ? Colors.blue.shade900 : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${employee.firstName} ${employee.lastName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: employee.isActive ? TextDecoration.none : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${employee.departmentName} — ${employee.positionName}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.email, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(employee.contactEmail,
                              style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.phone, size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(employee.phone, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${employee.baseSalary.toStringAsFixed(0)}₺',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.close, size: 18, color: Colors.red[400]),
                        onPressed: () {
                          _confirmDelete(employee);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyContactToClipboard(Employee employee) {
    final contactInfo = '${employee.firstName} ${employee.lastName}\nE-posta: ${employee.contactEmail}\nTelefon: ${employee.phone}';
    Clipboard.setData(ClipboardData(text: contactInfo));
    CustomToast.showSuccess(context, '${employee.firstName} ${employee.lastName} iletişim bilgisi kopyalandı!');
  }

  Future<void> _confirmDelete(Employee employee) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Personel Sil', style: TextStyle(fontSize: 16)),
        content: Text('${employee.firstName} ${employee.lastName} adlı personeli silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _employeeService.deleteEmployee(employee.id);
        _loadData();
        if (mounted) {
          CustomToast.showSuccess(context, 'Personel başarıyla silindi');
        }
      } catch (e) {
        if (mounted) {
          CustomToast.showError(context, e.toString());
        }
      }
    }
  }

  /// Personel ekleme dialog'u — Departman seçince pozisyonlar dinamik yüklenir
  void _showAddEmployeeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final idNoCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final salaryCtrl = TextEditingController();

    int? selectedDeptId;
    int? selectedPosId;
    List<PositionLookup> availablePositions = [];
    bool loadingPositions = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            /// Departman seçildiğinde pozisyonları yükle
            void onDepartmentChanged(int? deptId) async {
              setDialogState(() {
                selectedDeptId = deptId;
                selectedPosId = null;
                availablePositions = [];
                loadingPositions = true;
              });

              if (deptId != null) {
                try {
                  final positions = await _lookupService.getPositions(departmentId: deptId);
                  setDialogState(() {
                    availablePositions = positions;
                    loadingPositions = false;
                  });
                } catch (_) {
                  setDialogState(() => loadingPositions = false);
                }
              } else {
                setDialogState(() => loadingPositions = false);
              }
            }

            return AlertDialog(
              title: const Text('Yeni Personel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: idNoCtrl,
                        decoration: const InputDecoration(labelText: 'TC Kimlik No', isDense: true, border: OutlineInputBorder()),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Zorunlu';
                          if (v.length != 11) return '11 haneli olmalıdır';
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: firstNameCtrl,
                              decoration: const InputDecoration(labelText: 'Ad', isDense: true, border: OutlineInputBorder()),
                              validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: lastNameCtrl,
                              decoration: const InputDecoration(labelText: 'Soyad', isDense: true, border: OutlineInputBorder()),
                              validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(labelText: 'E-posta', isDense: true, border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                              return 'Geçerli e-posta giriniz';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'Telefon', isDense: true, border: OutlineInputBorder()),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: salaryCtrl,
                        decoration: const InputDecoration(labelText: 'Maaş (₺)', isDense: true, border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d*'))],
                        validator: (v) {
                          if (v != null && v.isNotEmpty) {
                            if (double.tryParse(v.replaceAll(',', '.')) == null) {
                              return 'Geçerli bir sayı giriniz';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Dynamic department dropdown from API
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedDeptId,
                              decoration: const InputDecoration(labelText: 'Departman', isDense: true, border: OutlineInputBorder()),
                              items: _departments.map((dept) =>
                                DropdownMenuItem(value: dept.id, child: Text(dept.name, style: const TextStyle(fontSize: 13)))
                              ).toList(),
                              onChanged: onDepartmentChanged,
                              validator: (v) => v == null ? 'Zorunlu' : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_box, color: Colors.blue),
                            onPressed: () {
                              final nameCtrl = TextEditingController();
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Yeni Departman', style: TextStyle(fontSize: 14)),
                                  content: TextField(
                                    controller: nameCtrl,
                                    decoration: const InputDecoration(labelText: 'Departman Adı', isDense: true, border: OutlineInputBorder()),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                                    FilledButton(
                                      onPressed: () async {
                                        if (nameCtrl.text.isEmpty) return;
                                        try {
                                          final newDept = await _lookupService.createDepartment(nameCtrl.text);
                                          Navigator.pop(ctx);
                                          setState(() => _departments.add(newDept));
                                          onDepartmentChanged(newDept.id);
                                        } catch (e) {
                                          CustomToast.showError(context, e.toString());
                                        }
                                      },
                                      child: const Text('Ekle'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Dynamic position dropdown — filtered by selected department
                      if (loadingPositions)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedPosId,
                                decoration: InputDecoration(
                                  labelText: 'Pozisyon',
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                  helperText: selectedDeptId == null ? 'Önce departman seçin' : null,
                                  helperStyle: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                items: availablePositions.map((pos) =>
                                  DropdownMenuItem(value: pos.id, child: Text(pos.name, style: const TextStyle(fontSize: 13)))
                                ).toList(),
                                onChanged: selectedDeptId == null ? null : (v) => setDialogState(() => selectedPosId = v),
                                validator: (v) => v == null ? 'Zorunlu' : null,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_box, color: selectedDeptId == null ? Colors.grey : Colors.blue),
                              onPressed: selectedDeptId == null ? null : () {
                                final nameCtrl = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Yeni Pozisyon', style: TextStyle(fontSize: 14)),
                                    content: TextField(
                                      controller: nameCtrl,
                                      decoration: const InputDecoration(labelText: 'Pozisyon Adı', isDense: true, border: OutlineInputBorder()),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                                      FilledButton(
                                        onPressed: () async {
                                          if (nameCtrl.text.isEmpty) return;
                                          try {
                                            final newPos = await _lookupService.createPosition(nameCtrl.text, selectedDeptId!);
                                            Navigator.pop(ctx);
                                            setDialogState(() {
                                              availablePositions.add(newPos);
                                              selectedPosId = newPos.id;
                                            });
                                          } catch (e) {
                                            CustomToast.showError(context, e.toString());
                                          }
                                        },
                                        child: const Text('Ekle'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    try {
                      await _employeeService.createEmployee({
                        'identityNumber': idNoCtrl.text.trim(),
                        'firstName': firstNameCtrl.text.trim(),
                        'lastName': lastNameCtrl.text.trim(),
                        'departmentId': selectedDeptId,
                        'positionId': selectedPosId,
                        'contactEmail': emailCtrl.text.trim(),
                        'phone': phoneCtrl.text.trim(),
                        'baseSalary': double.tryParse(salaryCtrl.text) ?? 0,
                        'currencyId': 1,
                        'hireDate': DateTime.now().toIso8601String(),
                      });
                      if (mounted) Navigator.pop(ctx);
                      _loadData();
                      if (mounted) {
                        CustomToast.showSuccess(context, 'Personel oluşturuldu');
                      }
                    } catch (e) {
                      if (mounted) {
                        CustomToast.showError(context, e.toString());
                      }
                    }
                  },
                  child: const Text('Oluştur'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
