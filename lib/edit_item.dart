import 'dart:io';
import 'package:eco_eats/add_item.dart';
import 'package:eco_eats/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFoodItemPage extends StatefulWidget {
  final DocumentSnapshot foodItem;

  EditFoodItemPage({required this.foodItem});

  @override
  _EditFoodItemPageState createState() => _EditFoodItemPageState();
}

class _EditFoodItemPageState extends State<EditFoodItemPage> {


  // --- TEXT EDITING CONTROLLERS 
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  late String _selectedCategory;
  late List<String> _categories;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem['name']);
    _quantityController =TextEditingController(text: widget.foodItem['quantity'].toString());
    _expiryDateController = TextEditingController(text: widget.foodItem['expiryDate'].toDate().toString());
    _selectedCategory = widget.foodItem['category'];
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
        displayMessage('No image selected', context);
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

  Future<void> _updateFoodItemInFirestore(FoodItem foodItem) async {
    try {
      String? imageUrl = widget.foodItem['imageUrl']; // Keep the existing imageUrl by default
      if (_imageFile != null) {
        // If a new image is selected, upload it and get the download URL
        imageUrl = await _uploadImage(_imageFile!);
      }
      await FirebaseFirestore.instance
          .collection('foodItems')
          .doc(widget.foodItem.id)
          .update({
        'category': foodItem.category,
        'name': foodItem.name,
        'quantity': foodItem.quantity,
        'expiryDate': foodItem.expiryDate,
        'imageUrl': imageUrl, // Update imageUrl only if a new image is selected
      });
      displayMessage('Food item updated in Firestore.', context);
      Navigator.pop(context); // Navigate back to previous screen
    } catch (e) {
      displayMessage('Error updating food item in Firestore: $e', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Food Item'),
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
                : CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(widget.foodItem['imageUrl'])),
            ElevatedButton(
              onPressed: () {
                _getImage();
              },
              child: Text('Select Food Picture'),
            ),
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

                // Update food item in Firestore
                _updateFoodItemInFirestore(foodItem);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
