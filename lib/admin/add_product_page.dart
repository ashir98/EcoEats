import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  late TextEditingController _barcodeController;
  late String _selectedCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _expiryDateController = TextEditingController();
    _barcodeController = TextEditingController();
    _selectedCategory = "Bread"; // Default category
    _categories = ["Bread", "Milk", "Cheese"]; // Default categories
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    String scannedBarcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666', // Color for the scan button
      'Cancel', // Text for the cancel button
      false, // Whether to show the flash icon
      ScanMode.BARCODE, // Scan mode (you can also use ScanMode.QR for QR codes)
    );

    setState(() {
      _barcodeController.text = scannedBarcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            TextFormField(
              controller: _expiryDateController,
              decoration: InputDecoration(labelText: 'Expiry Date'),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _expiryDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
            ),
            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(labelText: 'Barcode'),
              readOnly: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Scan Barcode'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text.trim();
                double quantity = double.parse(_quantityController.text.trim());
                DateTime expiryDate = DateTime.parse(_expiryDateController.text.trim());
                String barcode = _barcodeController.text.trim();

                // Create Product object
                Product product = Product(
                  category: _selectedCategory,
                  name: name,
                  quantity: quantity,
                  expiryDate: expiryDate,
                  barcode: barcode,
                );

                // Save product to Firestore
                _addProductToFirestore(product);

                // Clear input fields
                _nameController.clear();
                _quantityController.clear();
                _expiryDateController.clear();
                _barcodeController.clear();
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProductToFirestore(Product product) async {
    try {
      await FirebaseFirestore.instance.collection('admin_products')
      .doc(product.barcode)
      .set({
        'category': product.category,
        'name': product.name,
        'quantity': product.quantity,
        'expiryDate': product.expiryDate,
        'barcode': product.barcode,
      });
      print('Product added to Firestore.');
    } catch (e) {
      print('Error adding product to Firestore: $e');
    }
  }
}

class Product {
  String category;
  String name;
  double quantity;
  DateTime expiryDate;
  String barcode;

  Product({
    required this.category,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.barcode,
  });
}
