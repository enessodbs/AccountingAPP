import 'package:flutter/material.dart';
import '../widgets/custom_toast.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/responsive_scaffold.dart';

class BarcodeStockEntryScreen extends StatefulWidget {
  const BarcodeStockEntryScreen({super.key});

  @override
  State<BarcodeStockEntryScreen> createState() => _BarcodeStockEntryScreenState();
}

class _BarcodeStockEntryScreenState extends State<BarcodeStockEntryScreen> {
  final ProductService _productService = ProductService();
  final _barcodeController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  List<Product> _allProducts = [];
  Product? _foundProduct;
  bool _isLoading = true;
  bool _isStockIn = true;
  final List<_ScanRecord> _recentScans = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      _allProducts = await _productService.getProducts();
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _searchByBarcode(String barcode) {
    if (barcode.isEmpty) {
      setState(() => _foundProduct = null);
      return;
    }
    final q = barcode.toLowerCase();
    final match = _allProducts.cast<Product?>().firstWhere(
      (p) =>
          (p!.barcode != null && p.barcode!.toLowerCase() == q) ||
          p.code.toLowerCase() == q,
      orElse: () => null,
    );
    setState(() => _foundProduct = match);
  }

  Future<void> _scanBarcode() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SimpleBarcodeScannerPage()),
    );
    if (res is String && res != '-1') {
      _barcodeController.text = res;
      _searchByBarcode(res);
    }
  }

  Future<void> _applyStockChange() async {
    if (_foundProduct == null) return;
    final qty = double.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) {
      CustomToast.showError(context, 'Geçerli bir miktar girin');
      return;
    }

    try {
      await _productService.addStockMovement(
        _foundProduct!.id,
        qty,
        _isStockIn ? 1 : 2, // 1: In, 2: Out
      );

      final record = _ScanRecord(
        productName: _foundProduct!.name,
        productCode: _foundProduct!.code,
        barcode: _barcodeController.text,
        quantity: qty,
        isStockIn: _isStockIn,
        time: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _recentScans.insert(0, record);
          _barcodeController.clear();
          _foundProduct = null;
          _quantityController.text = '1';
        });

        if (_isStockIn) {
          CustomToast.showSuccess(context, '${record.productName}: +${qty.toStringAsFixed(0)} adet');
        } else {
          CustomToast.showError(context, '${record.productName}: -${qty.toStringAsFixed(0)} adet');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveScaffold(
      currentRoute: 'barcodeStock',
      title: 'Barkod ile Stok Girişi',
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Scan Area ───
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded,
                              size: 48, color: theme.colorScheme.primary.withOpacity(0.6)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _barcodeController,
                                  decoration: InputDecoration(
                                    hintText: 'Barkod tarayın veya elle girin',
                                    prefixIcon: const Icon(Icons.barcode_reader, size: 20),
                                    isDense: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: _searchByBarcode,
                                  onSubmitted: _searchByBarcode,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FilledButton.icon(
                                onPressed: _scanBarcode,
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                label: const Text('Tara'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stock direction toggle
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_circle_outline, size: 16,
                                          color: _isStockIn ? Colors.white : theme.colorScheme.secondary),
                                      const SizedBox(width: 4),
                                      Text('Stok Girişi',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: _isStockIn ? Colors.white : null)),
                                    ],
                                  ),
                                  selected: _isStockIn,
                                  selectedColor: theme.colorScheme.secondary,
                                  onSelected: (_) => setState(() => _isStockIn = true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ChoiceChip(
                                  label: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.remove_circle_outline, size: 16,
                                          color: !_isStockIn ? Colors.white : theme.colorScheme.error),
                                      const SizedBox(width: 4),
                                      Text('Stok Çıkışı',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: !_isStockIn ? Colors.white : null)),
                                    ],
                                  ),
                                  selected: !_isStockIn,
                                  selectedColor: theme.colorScheme.error,
                                  onSelected: (_) => setState(() => _isStockIn = false),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Quantity
                          Row(
                            children: [
                              const Text('Miktar:', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () {
                                  final v = (double.tryParse(_quantityController.text) ?? 1) - 1;
                                  if (v >= 1) _quantityController.text = v.toStringAsFixed(0);
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                visualDensity: VisualDensity.compact,
                              ),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: _quantityController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final v = (double.tryParse(_quantityController.text) ?? 0) + 1;
                                  _quantityController.text = v.toStringAsFixed(0);
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── Found product card ───
                  if (_foundProduct != null) ...[
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.secondary.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: theme.colorScheme.secondary, size: 20),
                                const SizedBox(width: 8),
                                const Text('Ürün Bulundu',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _infoRow('Ürün', _foundProduct!.name),
                            _infoRow('Kod', _foundProduct!.code),
                            if (_foundProduct!.barcode != null)
                              _infoRow('Barkod', _foundProduct!.barcode!),
                            _infoRow('Mevcut Stok', _foundProduct!.stockQuantity.toStringAsFixed(0)),
                            _infoRow('Fiyat', '${_foundProduct!.unitPrice.toStringAsFixed(2)} ${_foundProduct!.currencySymbol}'),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _applyStockChange,
                                icon: Icon(_isStockIn ? Icons.add : Icons.remove, size: 18),
                                label: Text(_isStockIn ? 'Stok Girişi Yap' : 'Stok Çıkışı Yap'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _isStockIn
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.error,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_barcodeController.text.isNotEmpty) ...[
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.error.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '"${_barcodeController.text}" barkodu ile eşleşen ürün bulunamadı.',
                                style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ─── Recent scans ───
                  if (_recentScans.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Son Taramalar',
                        style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    ...(_recentScans.take(20).map((scan) => Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: theme.dividerColor),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: (scan.isStockIn ? theme.colorScheme.secondary : theme.colorScheme.error)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                scan.isStockIn ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                color: scan.isStockIn ? theme.colorScheme.secondary : theme.colorScheme.error,
                                size: 18,
                              ),
                            ),
                            title: Text(scan.productName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text(
                              '${scan.productCode} • ${scan.barcode}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: Text(
                              '${scan.isStockIn ? "+" : "-"}${scan.quantity.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: scan.isStockIn ? theme.colorScheme.secondary : theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ))),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ScanRecord {
  final String productName;
  final String productCode;
  final String barcode;
  final double quantity;
  final bool isStockIn;
  final DateTime time;

  _ScanRecord({
    required this.productName,
    required this.productCode,
    required this.barcode,
    required this.quantity,
    required this.isStockIn,
    required this.time,
  });
}
