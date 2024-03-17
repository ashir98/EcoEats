import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class AddFoodItemPage extends StatefulWidget {
  @override
  _AddFoodItemPageState createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  late String _selectedCategory;
  late List<String> _categories;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
    _expiryDateController = TextEditingController();
    _selectedCategory = "Bread"; // Default category
    _categories = ["Bread", "Milk", "Cheese"]; // Default categories
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('food_images/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(imageFile);
      return ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _addFoodItemToFirestore(FoodItem foodItem) async {
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(_imageFile!);
      }
      await FirebaseFirestore.instance.collection('foodItems').add({
        'category': foodItem.category,
        'name': foodItem.name,
        'quantity': foodItem.quantity,
        'expiryDate': foodItem.expiryDate,
        'imageUrl': imageUrl,
      });
      print('Food item added to Firestore.');
    } catch (e) {
      print('Error adding food item to Firestore: $e');
    }
  }







Future<void> _scanBarcode() async {
  String barcode = await FlutterBarcodeScanner.scanBarcode(
    '#ff6666', // Color for the scan button
    'Cancel', // Text for the cancel button
    false, // Whether to show flash icon
    ScanMode.BARCODE, // Scan mode
  );

  if (barcode != '-1') {
    // Retrieve item details from Firestore using the scanned barcode
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('admin_products').doc(barcode).get();

    if (snapshot.exists) {
      // Populate form fields with retrieved details
      setState(() {
        _nameController.text = snapshot['name'];
        _quantityController.text = snapshot['quantity'].toString();
        Timestamp expiryDateTimestamp = snapshot['expiryDate'];
        _expiryDateController.text = DateFormat('yyyy-MM-dd').format(expiryDateTimestamp.toDate());
        _selectedCategory = snapshot['category'];
      });
    } else {
      // Handle case where the item with the scanned barcode does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item with barcode $barcode not found.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food Item'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.0),
            _imageFile != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: Image.file(
                        _imageFile!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
            TextButton(
              onPressed: () {
                _getImage();
              },
              child: Text('Select Food Picture'),
            ),
            SizedBox(height: 16.0),
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

            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text.trim();
                double quantity = double.parse(_quantityController.text.trim());
                DateTime expiryDate = DateTime.parse(_expiryDateController.text.trim());

                // Create FoodItem object
                FoodItem foodItem = FoodItem(
                  category: _selectedCategory,
                  name: name,
                  quantity: quantity,
                  expiryDate: expiryDate,
                );

                // Save food item to Firestore
                _addFoodItemToFirestore(foodItem);

                // Clear input fields
                _nameController.clear();
                _quantityController.clear();
                _expiryDateController.clear();
                setState(() {
                  _imageFile = null; // Clear selected image
                });
              },
              child: Text('Add Food Item'),
            ),
          ],
        ),
      ),





      floatingActionButton: FloatingActionButton(
        onPressed: _scanBarcode,
        tooltip: 'Scan Barcode',
        child: Icon(Icons.qr_code_scanner),
      ),
    






      

    );
  }
}





class FoodItem {
  String category;
  String name;
  double quantity;
  DateTime expiryDate;
  String? imageUrl; // Add imageUrl field

  FoodItem({required this.category, required this.name, required this.quantity, required this.expiryDate, this.imageUrl});
}