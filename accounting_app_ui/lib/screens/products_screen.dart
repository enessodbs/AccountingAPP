import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../models/product.dart';
import '../models/employee.dart';
import '../services/product_service.dart';
import '../services/lookup_service.dart';
import '../widgets/responsive_scaffold.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _productService = ProductService();
  final LookupService _lookupService = LookupService();
  List<Product> _products = [];
  List<CategoryLookup> _categories = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final q = _searchQuery.toLowerCase();
    return _products.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.code.toLowerCase().contains(q)).toList();
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
        _productService.getProducts(),
        _lookupService.getCategories(),
      ]);
      setState(() {
        _products = results[0] as List<Product>;
        _categories = results[1] as List<CategoryLookup>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentRoute: 'products',
      title: _isSearching ? '' : 'Ürünler & Stok',
      actions: [
        if (_isSearching)
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Ürün ara...',
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
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () async {
            var res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleBarcodeScannerPage(),
              ),
            );
            if (res is String && res != '-1') {
              setState(() {
                _isSearching = true;
                _searchController.text = res;
                _searchQuery = res;
              });
            }
          },
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProducts.isEmpty
              ? const Center(child: Text('Kayıtlı ürün bulunamadı.'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Dismissible(
                        key: Key(product.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) => _confirmDelete(product),
                        child: _buildProductCard(product, theme),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Ürün Ekle'),
      ),
    );
  }

  Widget _buildProductCard(Product product, ThemeData theme) {
    final stockColor = product.isPhysical
        ? (product.stockQuantity > 5
            ? theme.colorScheme.secondary
            : (product.stockQuantity > 0 ? const Color(0xFFF59E0B) : theme.colorScheme.error))
        : Colors.grey;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: product.isPhysical
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                product.isPhysical ? Icons.inventory_2_rounded : Icons.miscellaneous_services_rounded,
                color: product.isPhysical ? theme.colorScheme.primary : Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('${product.unitPrice.toStringAsFixed(2)} ${product.currencySymbol}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${product.code} • ${product.categoryName}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (product.barcode != null && product.barcode!.isNotEmpty) ...[
                        const Text(' • ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('Barkod: ${product.barcode}',
                            style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                      ],
                      if (product.serialNumber != null && product.serialNumber!.isNotEmpty) ...[
                        const Text(' • ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('SN: ${product.serialNumber}',
                            style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                      ],
                      const Spacer(),
                      if (product.isPhysical)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: stockColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('Stok: ${product.stockQuantity.toStringAsFixed(0)}',
                              style: TextStyle(color: stockColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Text('Hizmet',
                              style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
              onPressed: () => _confirmDelete(product),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(Product product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ürünü Sil', style: TextStyle(fontSize: 16)),
        content: Text('"${product.name}" ürünü silinecek. Onaylıyor musunuz?'),
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
        await _productService.deleteProduct(product.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ürün silindi'), backgroundColor: Colors.green),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
        }
      }
    }
    return false;
  }

  void _showAddProductDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final serialNoCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '0');
    int selectedType = 1;
    int? selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Yeni Ürün', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Fiziksel', style: TextStyle(fontSize: 12)),
                              selected: selectedType == 1,
                              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              onSelected: (_) => setDialogState(() => selectedType = 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Hizmet', style: TextStyle(fontSize: 12)),
                              selected: selectedType == 2,
                              selectedColor: Colors.purple.withOpacity(0.2),
                              onSelected: (_) => setDialogState(() => selectedType = 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: codeCtrl,
                        decoration: const InputDecoration(labelText: 'Ürün Kodu', isDense: true, border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Ürün Adı', isDense: true, border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: serialNoCtrl,
                        decoration: const InputDecoration(labelText: 'Seri No', isDense: true, border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: barcodeCtrl,
                              decoration: const InputDecoration(labelText: 'Barkod', isDense: true, border: OutlineInputBorder()),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: () async {
                              var res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SimpleBarcodeScannerPage(),
                                ),
                              );
                              if (res is String && res != '-1') {
                                setDialogState(() {
                                  barcodeCtrl.text = res;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Açıklama', isDense: true, border: OutlineInputBorder()),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: priceCtrl,
                              decoration: const InputDecoration(labelText: 'Birim Fiyat (₺)', isDense: true, border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty) ? 'Zorunlu' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selectedType == 1)
                            Expanded(
                              child: TextFormField(
                                controller: stockCtrl,
                                decoration: const InputDecoration(labelText: 'Stok', isDense: true, border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Dynamic categories from API
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: const InputDecoration(labelText: 'Kategori', isDense: true, border: OutlineInputBorder()),
                        items: _categories.map((cat) =>
                          DropdownMenuItem(value: cat.id, child: Text(cat.name, style: const TextStyle(fontSize: 13)))
                        ).toList(),
                        onChanged: (v) => setDialogState(() => selectedCategoryId = v),
                        validator: (v) => v == null ? 'Zorunlu' : null,
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
                      await _productService.createProduct({
                        'code': codeCtrl.text.trim(),
                        'name': nameCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'serialNumber': serialNoCtrl.text.trim(),
                        'barcode': barcodeCtrl.text.trim(),
                        'unitPrice': double.tryParse(priceCtrl.text) ?? 0,
                        'categoryId': selectedCategoryId,
                        'currencyId': 1,
                        'type': selectedType,
                        'stockQuantity': selectedType == 1 ? (double.tryParse(stockCtrl.text) ?? 0) : 0,
                      });
                      if (mounted) Navigator.pop(ctx);
                      _loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ürün oluşturuldu'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
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
