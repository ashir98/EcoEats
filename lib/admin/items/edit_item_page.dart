import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class EditItemPage extends StatefulWidget {
  final String productId;

  const EditItemPage({Key? key, required this.productId}) : super(key: key);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
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
    _fetchProductDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('admin_products')
          .doc(widget.productId)
          .get();

      Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = productData['name'];
        _quantityController.text = productData['quantity'].toString();
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(productData['expiryDate'].toDate());
        _barcodeController.text = productData['barcode'];
        _selectedCategory = productData['category'];
      });
    } catch (e) {
      print('Error fetching product details: $e');
    }
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
        title: Text('Edit Product'),
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
                // Update product in Firestore
                _updateProduct();
              },
              child: Text('Update Product'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProduct() async {
    try {
      await FirebaseFirestore.instance.collection('admin_products').doc(widget.productId).update({
        'category': _selectedCategory,
        'name': _nameController.text.trim(),
        'quantity': double.parse(_quantityController.text.trim()),
        'expiryDate': DateTime.parse(_expiryDateController.text.trim()),
        'barcode': _barcodeController.text.trim(),
      });
      print('Product updated successfully');
    } catch (e) {
      print('Error updating product: $e');
    }
  }
}
