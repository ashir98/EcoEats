import 'dart:io';
import 'package:eco_eats/provider/app_notifier.dart';
import 'package:eco_eats/utils/helper_functions.dart';
import 'package:eco_eats/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

class AddFoodItemPage extends StatefulWidget {
  @override
  _AddFoodItemPageState createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  // --- TEXT EDITING CONTROLLERS
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  late TextEditingController _barcodeController;
  late String _selectedCategory;
  late List<String> _categories;
  File? _imageFile;

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
    super.dispose();
  }


  Future<void> _getImage() async {
  final imagePicker = ImagePicker();

  // Show bottom sheet with options to pick image from camera or gallery
  await showModalBottomSheet(
    
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a picture'),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
                final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
                _setImage(pickedImage);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
                final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
                _setImage(pickedImage);
              },
            ),
          ],
        ),
      );
    },
  );
}

void _setImage(XFile? pickedImage) {
  setState(() {
    if (pickedImage != null) {
      _imageFile = File(pickedImage.path);
    } else {
      displayMessage('No image selected.', context);
    }
  });
}













  Future<String?> _uploadImage(File imageFile) async {
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('food_images/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(imageFile);
      return ref.getDownloadURL();
    } catch (e) {
      displayMessage('Error uploading image: $e', context);
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
        'imageUrl': imageUrl ?? "https://firebasestorage.googleapis.com/v0/b/ecoeats-f70a3.appspot.com/o/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg?alt=media&token=69f65be4-1d7c-42a0-ac1b-520e42efad7e",
      });
      displayMessage('item added successfuly', context);
    } catch (e) {
      displayMessage('Error adding food item: $e', context);
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
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin_products')
          .doc(barcode)
          .get();

      if (snapshot.exists) {
        showAlertDialouge(context,
            title: "Item found",
            content: "Found item with barcode: ${barcode}. do you want to keep details?",
            onConfirm: () {
          // Populate form fields with retrieved details
          setState(() {
            _barcodeController.text = barcode;
            _nameController.text = snapshot['name'];
            _quantityController.text = snapshot['quantity'].toString();
            Timestamp expiryDateTimestamp = snapshot['expiryDate'];
            _expiryDateController.text = DateFormat('yyyy-MM-dd').format(expiryDateTimestamp.toDate());
            _selectedCategory = snapshot['category'];
          });

          Navigator.pop(context);

          displayMessage('Item with barcode $barcode added', context);
        });
      } else {
        // Handle case where the item with the scanned barcode does not exist
        displayMessage('Item with barcode $barcode not found.', context);
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
          
          children: [
             SizedBox(
                  height: 130.h,
                  width: 150.w,
                  child: Card(
                    color: Colors.purple.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)
                    ),

                    child:  Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child:
                      
                        _imageFile != null?
                        
                        
                        
                         Image.file(
                            _imageFile!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill,
                          )
                      
                          :Icon(Icons.question_mark_rounded, color: Colors.white,size: 60.sp,),
                      ),
                    ),
                  ),
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
                    _expiryDateController.text =
                        DateFormat('yyyy-MM-dd').format(picked);
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
            Consumer<AppNotifier>(
              builder: (context, provalue, child) => CustomButton(
                isLoading: provalue.isLoading,
                onTap: () {
                  if (_nameController.text.isEmpty ||
                      _quantityController.text.isEmpty ||
                      _expiryDateController.text.isEmpty) {
                    displayMessage("please fill all the fields", context);
                  } else {
                    provalue.setLoading(true);

                    String name = _nameController.text.trim();
                    double quantity =
                        double.parse(_quantityController.text.trim());
                    DateTime expiryDate =
                        DateTime.parse(_expiryDateController.text.trim());

                    // Create FoodItem object
                    FoodItem foodItem = FoodItem(
                      category: _selectedCategory,
                      name: name,
                      quantity: quantity,
                      expiryDate: expiryDate,
                    );

                    // Save food item to Firestore
                    _addFoodItemToFirestore(foodItem).then((value) {
                      provalue.setLoading(false);

                      // Clear input fields
                      _nameController.clear();
                      _quantityController.clear();
                      _expiryDateController.clear();
                      setState(() {
                        _imageFile = null; // Clear selected image
                      });

                      Navigator.pop(context);
                    }).catchError((error) {
                      provalue.setLoading(false);
                    });
                  }
                },
                text: 'Add Food Item',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanBarcode,
        tooltip: 'Scan barcode to add item',
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

  FoodItem(
      {required this.category,
      required this.name,
      required this.quantity,
      required this.expiryDate,
      this.imageUrl});
}
