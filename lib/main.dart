import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CashierPOSApp());
}

class Product {
  final int id;
  final String code;
  final String name;
  final String category;
  final String imageUrl;
  double price;
  int stock;
  final bool isPerishable;
  final DateTime? expiryDate;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.stock,
    this.isPerishable = false,
    this.expiryDate,
  });

  bool get isExpired => isPerishable && expiryDate != null && DateTime.now().isAfter(expiryDate!);

  String get expiryLabel {
    if (!isPerishable || expiryDate == null) return "Non-perishable";
    final diff = expiryDate!.difference(DateTime.now());
    if (diff.isNegative) return "EXPIRED";
    if (diff.inDays > 0) return "${diff.inDays}d left";
    return "${diff.inHours}h ${diff.inMinutes % 60}m left";
  }
}

class CartLine {
  final Product product;
  int quantity;

  CartLine({required this.product, this.quantity = 1});
  double get total => product.price * quantity;
}

class CashierPOSApp extends StatelessWidget {
  const CashierPOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store POS Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090D16),
        fontFamily: 'Segoe UI',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF131B2E),
        ),
      ),
      home: const CashierScreen(),
    );
  }
}

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  Timer? _timer;
  DateTime _currentDateTime = DateTime.now();

  final FocusNode _keyboardFocusNode = FocusNode();
  final TextEditingController _searchCtrl = TextEditingController();

  final String _shopName = "STORE SUPERMARKET";
  final String _upiId = "retailstore@icici";
  final String _merchantName = "Retail Store";

  String _selectedCat = "All";
  String _searchQuery = "";
  String _paymentMode = "CASH";
  double _cashTendered = 0.0;

  double _totalRegisterSales = 0.0;
  double _totalCashRevenue = 0.0;
  double _totalUpiRevenue = 0.0;
  int _orderCount = 0;

  final List<Product> _products = [
    // DAIRY
    Product(
      id: 1,
      code: "MILK-01",
      name: "Milma Rich Milk 500ml",
      category: "Dairy",
      price: 28.0,
      stock: 32,
      imageUrl: "https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80",
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(hours: 5)),
    ),
    Product(
      id: 2,
      code: "EGG-12",
      name: "Farm Eggs (Tray 12)",
      category: "Poultry",
      price: 84.0,
      stock: 20,
      imageUrl: "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=400&q=80",
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(days: 4)),
    ),
    Product(
      id: 8,
      code: "CURD-400",
      name: "Fresh Curd Pouch 400g",
      category: "Dairy",
      price: 32.0,
      stock: 18,
      imageUrl: "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=400&q=80",
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(hours: 8)),
    ),

    // BAKERY
    Product(
      id: 7,
      code: "BREAD-01",
      name: "Wheat Sandwich Bread",
      category: "Bakery",
      price: 45.0,
      stock: 14,
      imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=400&q=80",
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(hours: 18)),
    ),
    Product(
      id: 9,
      code: "CAKE-PLUM",
      name: "Rich Plum Cake 400g",
      category: "Bakery",
      price: 180.0,
      stock: 22,
      imageUrl: "https://images.unsplash.com/photo-1606890737304-57a1ca8a5b62?auto=format&fit=crop&w=400&q=80",
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
    ),
    Product(
      id: 10,
      code: "PUFF-EGG",
      name: "Crispy Egg Puff",
      category: "Bakery",
      price: 20.0,
      stock: 25,
      imageUrl: "https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=400&q=80",
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(hours: 6)),
    ),
    Product(
      id: 11,
      code: "COOK-BUTTER",
      name: "Butter Cookies Tin",
      category: "Bakery",
      price: 220.0,
      stock: 12,
      imageUrl: "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=400&q=80",
    ),
    Product(
      id: 12,
      code: "CHIP-BAN",
      name: "Kerala Banana Chips 250g",
      category: "Bakery",
      price: 115.0,
      stock: 30,
      imageUrl: "https://images.unsplash.com/photo-1621447504864-d8686e12698c?auto=format&fit=crop&w=400&q=80",
      isPerishable: true,
      expiryDate: DateTime.now().add(const Duration(days: 20)),
    ),

    // CANDIES & CHOCOLATES
    Product(
      id: 13,
      code: "CANDY-CHOC",
      name: "Cadbury Dairy Milk Silk",
      category: "Candies",
      price: 95.0,
      stock: 40,
      imageUrl: "https://images.unsplash.com/photo-1549007994-cb92caebd54b?auto=format&fit=crop&w=400&q=80",
    ),
    Product(
      id: 14,
      code: "CANDY-KITKAT",
      name: "Nestle KitKat 4-Finger",
      category: "Candies",
      price: 30.0,
      stock: 55,
      imageUrl: "https://images.unsplash.com/photo-1582293041079-7814c2f12063?auto=format&fit=crop&w=400&q=80",
    ),
    Product(
      id: 15,
      code: "CANDY-GUMMY",
      name: "Haribo Goldbears Gummy",
      category: "Candies",
      price: 80.0,
      stock: 35,
      imageUrl: "https://images.unsplash.com/photo-1582058091505-f87a2e55a40f?auto=format&fit=crop&w=400&q=80",
    ),
    Product(
      id: 16,
      code: "CANDY-CARAMEL",
      name: "Alpenliebe Caramel Pack",
      category: "Candies",
      price: 50.0,
      stock: 28,
      imageUrl: "https://images.unsplash.com/photo-1575224300306-1b8da36134ec?auto=format&fit=crop&w=400&q=80",
    ),

    // STAPLES
    Product(
      id: 3,
      code: "RICE-05",
      name: "Matta Rice 5kg Bag",
      category: "Grains",
      price: 290.0,
      stock: 15,
      imageUrl: "https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400&q=80",
    ),
    Product(
      id: 4,
      code: "OIL-01",
      name: "Pure Coconut Oil 1L",
      category: "Oils",
      price: 185.0,
      stock: 24,
      imageUrl: "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1?auto=format&fit=crop&w=400&q=80",
    ),
    Product(
      id: 5,
      code: "TEA-250",
      name: "Kannan Devan Tea 250g",
      category: "Beverages",
      price: 110.0,
      stock: 45,
      imageUrl: "https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=400&q=80",
    ),
  ];

  final List<CartLine> _cart = [];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentDateTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _keyboardFocusNode.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.fold(0.0, (acc, item) => acc + item.total);
  double get _gst => _subtotal * 0.05;
  double get _grandTotal => _subtotal + _gst;
  double get _changeDue => (_cashTendered - _grandTotal).clamp(0.0, 999999.0);

  int get _lowStockCount => _products.where((p) => p.stock <= 5).length;

  String get _formattedDateTime {
    const days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
    const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

    final dayName = days[_currentDateTime.weekday - 1];
    final monthName = months[_currentDateTime.month - 1];
    final dayNum = _currentDateTime.day.toString().padLeft(2, '0');
    final year = _currentDateTime.year;

    final hour24 = _currentDateTime.hour;
    final ampm = hour24 >= 12 ? "PM" : "AM";
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final mins = _currentDateTime.minute.toString().padLeft(2, '0');
    final secs = _currentDateTime.second.toString().padLeft(2, '0');

    return "$dayName, $dayNum $monthName $year • $hour12:$mins:$secs $ampm";
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.f1) {
      setState(() => _paymentMode = "CASH");
    } else if (event.logicalKey == LogicalKeyboardKey.f2) {
      setState(() => _paymentMode = "UPI / QR");
      if (_cart.isNotEmpty) _showUpiQrPaymentModal();
    } else if (event.logicalKey == LogicalKeyboardKey.f3) {
      setState(() => _cashTendered = _grandTotal);
    } else if (event.logicalKey == LogicalKeyboardKey.f4) {
      if (_cart.isNotEmpty) _clearCart();
    } else if (event.logicalKey == LogicalKeyboardKey.f5) {
      _showStockManagementModal();
    } else if (event.logicalKey == LogicalKeyboardKey.f9) {
      if (_cart.isNotEmpty) _checkout();
    }
  }

  void _processScannedBarcode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return;

    final matched = _products.cast<Product?>().firstWhere(
      (p) => p?.code.toUpperCase() == cleanCode,
      orElse: () => null,
    );

    if (matched != null) {
      _addToCart(matched);
      _searchCtrl.clear();
      setState(() => _searchQuery = "");
    }
  }

  void _addToCart(Product p) {
    if (p.isExpired) {
      _showToast("EXPIRED PRODUCT: Sale strictly prohibited!", Colors.redAccent);
      return;
    }
    if (p.stock <= 0) {
      _showToast("Out of stock! Press F5 to restock.", Colors.orangeAccent);
      return;
    }

    setState(() {
      final index = _cart.indexWhere((c) => c.product.id == p.id);
      if (index != -1) {
        if (_cart[index].quantity < p.stock) {
          _cart[index].quantity++;
        } else {
          _showToast("Max inventory limit reached!", Colors.amber);
        }
      } else {
        _cart.add(CartLine(product: p));
      }
      _cashTendered = _grandTotal;
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final item = _cart[index];
      final newQty = item.quantity + delta;
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else if (newQty <= item.product.stock) {
        item.quantity = newQty;
      }
      _cashTendered = _grandTotal;
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _cashTendered = 0.0;
    });
  }

  void _deleteProduct(Product p, StateSetter parentState) {
    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        backgroundColor: const Color(0xFF101726),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF263553))),
        title: const Text("Delete Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text("Are you sure you want to permanently delete '${p.name}' (${p.code}) from inventory?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(confirmCtx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(confirmCtx);
              setState(() {
                _products.removeWhere((item) => item.id == p.id);
                _cart.removeWhere((item) => item.product.id == p.id);
                _cashTendered = _grandTotal;
              });
              parentState(() {});
              _showToast("${p.name} deleted from stock", Colors.redAccent);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    if (_cart.isEmpty) return;

    final settledSubtotal = _subtotal;
    final settledGst = _gst;
    final settledAmount = _grandTotal;
    final tendered = _cashTendered;
    final change = _changeDue;
    final payment = _paymentMode;
    final itemsSold = List<CartLine>.from(_cart);
    final invNumber = 1000 + _orderCount + 1;
    final billTime = DateTime.now();

    setState(() {
      for (var item in _cart) {
        item.product.stock -= item.quantity;
      }
      _totalRegisterSales += settledAmount;
      if (payment == "CASH") {
        _totalCashRevenue += settledAmount;
      } else {
        _totalUpiRevenue += settledAmount;
      }
      _orderCount++;
      _cart.clear();
      _cashTendered = 0.0;
    });

    _showThermalReceiptDialog(
      invNumber: invNumber,
      timestamp: billTime,
      items: itemsSold,
      subtotal: settledSubtotal,
      gst: settledGst,
      total: settledAmount,
      tendered: tendered,
      change: change,
      paymentMode: payment,
    );
  }

  void _showStockManagementModal() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStockModalState) => AlertDialog(
          backgroundColor: const Color(0xFF131B2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF263553))),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF38BDF8), size: 22),
              ),
              const SizedBox(width: 12),
              const Text("Inventory & Stock Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.black),
                label: const Text("New Product", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  _openAddProductDialog(setStockModalState);
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          content: SizedBox(
            width: 760,
            height: 480,
            child: ListView.separated(
              itemCount: _products.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E293B), height: 1),
              itemBuilder: (context, idx) {
                final p = _products[idx];
                final isLow = p.stock <= 5;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF1E293B),
                              child: const Icon(Icons.inventory_2, color: Colors.grey, size: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text("Code: ${p.code} • ${p.category} • ₹${p.price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isLow ? Colors.red.withOpacity(0.2) : const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isLow ? Colors.redAccent.withOpacity(0.5) : const Color(0xFF10B981).withOpacity(0.4)),
                        ),
                        child: Text(
                          "${p.stock} in stock",
                          style: TextStyle(
                            color: isLow ? Colors.redAccent : const Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Quick Restock Buttons
                      _restockBtn("+5", () {
                        setState(() => p.stock += 5);
                        setStockModalState(() {});
                      }),
                      const SizedBox(width: 6),
                      _restockBtn("+10", () {
                        setState(() => p.stock += 10);
                        setStockModalState(() {});
                      }),
                      const SizedBox(width: 6),
                      _restockBtn("+25", () {
                        setState(() => p.stock += 25);
                        setStockModalState(() {});
                      }),
                      const SizedBox(width: 10),
                      // Delete Product Action
                      IconButton(
                        tooltip: "Delete Product",
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                        onPressed: () => _deleteProduct(p, setStockModalState),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _restockBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
        ),
        child: Text(label, style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }

  void _openAddProductDialog(StateSetter parentState) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final imgCtrl = TextEditingController(text: "https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=400&q=80");
    bool isPerish = false;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF101726),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF263553))),
          title: const Text("Add New Product to Store", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Product Name (e.g. Samosa)")),
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "Barcode / SKU Code (e.g. SAMOSA-01)")),
                TextField(controller: catCtrl, decoration: const InputDecoration(labelText: "Category (Bakery, Dairy, etc.)")),
                Row(
                  children: [
                    Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price (₹)"))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Initial Units"))),
                  ],
                ),
                TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: "Image URL")),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Perishable / Expiry Item", style: TextStyle(fontSize: 13)),
                  value: isPerish,
                  onChanged: (val) => setDialogState(() => isPerish = val),
                ),
                if (isPerish)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      selectedDate == null ? "Select Expiry Date" : "Expiry: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.calendar_month, color: Color(0xFF38BDF8)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) setDialogState(() => selectedDate = picked);
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final code = codeCtrl.text.trim().toUpperCase();
                final cat = catCtrl.text.trim();
                final p = double.tryParse(priceCtrl.text) ?? 0.0;
                final s = int.tryParse(stockCtrl.text) ?? 0;
                final img = imgCtrl.text.trim();

                if (name.isNotEmpty && code.isNotEmpty && p > 0 && s > 0) {
                  setState(() {
                    _products.add(Product(
                      id: DateTime.now().millisecondsSinceEpoch % 10000,
                      code: code,
                      name: name,
                      category: cat.isEmpty ? "General" : cat,
                      price: p,
                      stock: s,
                      imageUrl: img,
                      isPerishable: isPerish,
                      expiryDate: selectedDate,
                    ));
                  });
                  parentState(() {});
                  Navigator.pop(ctx);
                  _showToast("New product added to inventory!", const Color(0xFF10B981));
                }
              },
              child: const Text("Save & Add to Stock", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpiQrPaymentModal() {
    if (_grandTotal <= 0) return;

    final upiPayload = "upi://pay?pa=$_upiId&pn=${Uri.encodeComponent(_merchantName)}&am=${_grandTotal.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent('POS Bill')}";
    final qrApiUrl = "https://api.qrserver.com/v1/create-qr-code/?size=260x260&data=${Uri.encodeComponent(upiPayload)}";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF263553))),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF38BDF8), size: 24),
            ),
            const SizedBox(width: 12),
            const Text("Instant UPI Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F1D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF263553)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Payable:", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(
                    "₹${_grandTotal.toStringAsFixed(2)}",
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.15), blurRadius: 25, spreadRadius: 2),
                ],
              ),
              child: Image.network(
                qrApiUrl,
                width: 210,
                height: 210,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const SizedBox(
                    width: 210,
                    height: 210,
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _appBadge("GPay", const Color(0xFF4285F4)),
                const SizedBox(width: 8),
                _appBadge("PhonePe", const Color(0xFF5F259F)),
                const SizedBox(width: 8),
                _appBadge("Paytm", const Color(0xFF00BAF2)),
                const SizedBox(width: 8),
                _appBadge("BHIM", const Color(0xFF00796B)),
              ],
            ),
            const SizedBox(height: 10),
            Text("VPA: $_upiId", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check_circle, color: Colors.black),
              label: const Text("Confirm Payment & Print", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () {
                Navigator.pop(ctx);
                _checkout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBadge(String title, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: col.withOpacity(0.18), borderRadius: BorderRadius.circular(6), border: Border.all(color: col.withOpacity(0.6))),
      child: Text(title, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  void _showThermalReceiptDialog({
    required int invNumber,
    required DateTime timestamp,
    required List<CartLine> items,
    required double subtotal,
    required double gst,
    required double total,
    required double tendered,
    required double change,
    required String paymentMode,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: SizedBox(
          width: 330,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15)],
              ),
              child: DefaultTextStyle(
                style: const TextStyle(fontFamily: 'Courier', color: Colors.black, fontSize: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        _shopName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const Center(child: Text("Chengannur, Kerala")),
                    const Center(child: Text("GSTIN: 32AAAAA0000A1Z5")),
                    const SizedBox(height: 8),
                    const Text("--------------------------------"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("INV: #$invNumber"),
                        Text("${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}"),
                      ],
                    ),
                    Text("Date: ${timestamp.day}/${timestamp.month}/${timestamp.year}"),
                    const Text("--------------------------------"),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ITEM", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("QTY  TOTAL", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Text("--------------------------------"),
                    ...items.map((i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  i.product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text("${i.quantity}x ₹${i.total.toStringAsFixed(0)}"),
                            ],
                          ),
                        )),
                    const Text("--------------------------------"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Subtotal:"),
                        Text("₹${subtotal.toStringAsFixed(2)}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("GST (5%):"),
                        Text("₹${gst.toStringAsFixed(2)}"),
                      ],
                    ),
                    const Text("================================"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const Text("================================"),
                    Text("Mode: $paymentMode"),
                    if (paymentMode == "CASH") ...[
                      Text("Tendered: ₹${tendered.toStringAsFixed(2)}"),
                      Text("Change Due: ₹${change.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ] else ...[
                      Text("UPI Ref: TXN${timestamp.millisecondsSinceEpoch.toString().substring(5)}"),
                      Text("VPA: $_upiId"),
                    ],
                    const SizedBox(height: 10),
                    const Center(child: Text("*** THANK YOU VISIT AGAIN ***")),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.print, color: Colors.black, size: 18),
            label: const Text("Print / Settle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["All", ...{for (var p in _products) p.category}];
    final filtered = _products.where((p) {
      final matchesCat = _selectedCat == "All" || p.category == _selectedCat;
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(66),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_shopName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8)),
                    Text(_formattedDateTime, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 20),
                _shortcutTag("F1 Cash"),
                const SizedBox(width: 6),
                _shortcutTag("F2 UPI/QR"),
                const SizedBox(width: 6),
                _shortcutTag("F3 Exact"),
                const SizedBox(width: 6),
                _shortcutTag("F4 Clear"),
                const SizedBox(width: 6),
                _shortcutTag("F5 Stock"),
                const SizedBox(width: 6),
                _shortcutTag("F9 Print"),
                const Spacer(),
                if (_lowStockCount > 0)
                  InkWell(
                    onTap: _showStockManagementModal,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 15, color: Colors.redAccent),
                          const SizedBox(width: 6),
                          Text("$_lowStockCount Low Stock", style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF131B2E),
                    side: const BorderSide(color: Color(0xFF263553)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF38BDF8)),
                  label: const Text("Stock [F5]", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: _showStockManagementModal,
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF263553)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_rupee, size: 14, color: Colors.grey),
                      Text("Cash: ₹${_totalCashRevenue.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Icon(Icons.qr_code_2, size: 14, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 4),
                      Text("UPI: ₹${_totalUpiRevenue.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _statusPill("TOTAL: ₹${_totalRegisterSales.toStringAsFixed(2)}", Icons.account_balance_wallet, const Color(0xFF10B981)),
              ],
            ),
          ),
        ),
        body: Row(
          children: [
            // CATALOG PANE
            Expanded(
              flex: 6,
              child: Container(
                color: const Color(0xFF090D16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        onSubmitted: (code) => _processScannedBarcode(code),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Scan barcode or enter SKU (e.g. PUFF-EGG, MILK-01) & hit Enter...",
                          prefixIcon: const Icon(Icons.barcode_reader, color: Color(0xFF38BDF8)),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _searchQuery = "");
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF131B2E),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF263553))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B))),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final cat = categories[idx];
                          final active = cat == _selectedCat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: active,
                            selectedColor: const Color(0xFF38BDF8),
                            backgroundColor: const Color(0xFF131B2E),
                            labelStyle: TextStyle(
                              color: active ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            onSelected: (_) => setState(() => _selectedCat = cat),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          final isLow = item.stock <= 5;
                          final isOut = item.stock <= 0;
                          final expired = item.isExpired;

                          return InkWell(
                            onTap: () => _addToCart(item),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF131B2E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: expired
                                      ? Colors.redAccent.withOpacity(0.6)
                                      : (isOut
                                          ? Colors.red.withOpacity(0.8)
                                          : (isLow ? Colors.amber.withOpacity(0.6) : const Color(0xFF263553))),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            item.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: const Color(0xFF1E293B),
                                              child: const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 36),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                item.code,
                                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          if (item.isPerishable)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: expired ? Colors.redAccent.withOpacity(0.9) : Colors.orangeAccent.withOpacity(0.9),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  item.expiryLabel,
                                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item.name,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "₹${item.price.toStringAsFixed(0)}",
                                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8)),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isOut
                                                        ? Colors.red.withOpacity(0.3)
                                                        : (isLow ? Colors.amber.withOpacity(0.2) : Colors.black.withOpacity(0.35)),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    isOut ? "OUT OF STOCK" : "${item.stock} left",
                                                    style: TextStyle(
                                                      color: isOut ? Colors.redAccent : (isLow ? Colors.amber : Colors.grey[400]),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(width: 1, color: const Color(0xFF1E293B)),

            // TILL PANE
            Expanded(
              flex: 4,
              child: Container(
                color: const Color(0xFF0C1322),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.receipt_outlined, size: 20, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 8),
                              const Text("CURRENT TICKET", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _cart.isEmpty ? null : _clearCart,
                            icon: const Icon(Icons.delete_sweep_outlined, size: 18, color: Colors.redAccent),
                            label: const Text("Clear (F4)", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF1E293B)),
                    Expanded(
                      child: _cart.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.shopping_basket_outlined, size: 52, color: Colors.grey.shade700),
                                  const SizedBox(height: 10),
                                  const Text("Register Empty", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("Touch items on the left to add", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _cart.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final line = _cart[idx];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B2E),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF263553)),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          width: 44,
                                          height: 44,
                                          child: Image.network(
                                            line.product.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: const Color(0xFF1E293B),
                                              child: const Icon(Icons.inventory_2, color: Colors.grey, size: 20),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              line.product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            const SizedBox(height: 2),
                                            Text("₹${line.product.price} each", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(color: const Color(0xFF090D16), borderRadius: BorderRadius.circular(8)),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 16),
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                              onPressed: () => _updateQuantity(idx, -1),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 16),
                                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              padding: EdgeInsets.zero,
                                              onPressed: () => _updateQuantity(idx, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 55,
                                        child: Text(
                                          "₹${line.total.toStringAsFixed(0)}",
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF38BDF8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF101726),
                        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _paymentChip("CASH", Icons.money, "F1", () {
                                setState(() => _paymentMode = "CASH");
                              }),
                              const SizedBox(width: 8),
                              _paymentChip("UPI / QR", Icons.qr_code_2, "F2", () {
                                setState(() => _paymentMode = "UPI / QR");
                                if (_cart.isNotEmpty) _showUpiQrPaymentModal();
                              }),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_paymentMode == "CASH" && _grandTotal > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _tenderBtn("Exact (F3)", _grandTotal),
                                _tenderBtn("₹100", 100),
                                _tenderBtn("₹500", 500),
                                _tenderBtn("₹2000", 2000),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Subtotal:", style: TextStyle(color: Colors.grey)),
                              Text("₹${_subtotal.toStringAsFixed(2)}"),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Tax (GST 5%):", style: TextStyle(color: Colors.grey)),
                              Text("₹${_gst.toStringAsFixed(2)}"),
                            ],
                          ),
                          if (_paymentMode == "CASH" && _cashTendered >= _grandTotal && _grandTotal > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Change Due:", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                                Text("₹${_changeDue.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                          const Divider(color: Color(0xFF263553), height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("TOTAL PAYABLE:", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              Text("₹${_grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF38BDF8))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _paymentMode == "UPI / QR" ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _cart.isEmpty
                                  ? null
                                  : () {
                                      if (_paymentMode == "UPI / QR") {
                                        _showUpiQrPaymentModal();
                                      } else {
                                        _checkout();
                                      }
                                    },
                              child: Text(
                                _paymentMode == "UPI / QR" ? "SHOW UPI QR & PAY [F2]" : "PRINT RECEIPT & SETTLE [F9]",
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFF131B2E), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF263553))),
      child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusPill(String title, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: col.withOpacity(0.14), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: col),
          const SizedBox(width: 6),
          Text(title, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _paymentChip(String mode, IconData icon, String shortcut, VoidCallback onTap) {
    final active = _paymentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF38BDF8).withOpacity(0.18) : const Color(0xFF090D16),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? const Color(0xFF38BDF8) : const Color(0xFF263553)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? const Color(0xFF38BDF8) : Colors.grey),
              const SizedBox(width: 6),
              Text("$mode [$shortcut]", style: TextStyle(color: active ? const Color(0xFF38BDF8) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tenderBtn(String label, double val) {
    return InkWell(
      onTap: () => setState(() => _cashTendered = val),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF090D16),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF263553)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }
}
