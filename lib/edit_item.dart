import 'dart:io';
import 'package:eco_eats/add_item.dart';
import 'package:eco_eats/provider/app_notifier.dart';
import 'package:eco_eats/select_foodbank_page.dart';
import 'package:eco_eats/utils/helper_functions.dart';
import 'package:eco_eats/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

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
    _quantityController = TextEditingController(text: widget.foodItem['quantity'].toString());
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

  // Show bottom sheet with options to pick image from camera or gallery
  await showModalBottomSheet(
    showDragHandle: true,
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
      displayMessage('item updated', context);
      Navigator.pop(context); // Navigate back to previous screen
    } catch (e) {
      displayMessage('Error updating food item: $e', context);
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
                      
                          :   Image.network(widget.foodItem['imageUrl'], fit: BoxFit.fill,)   ,
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

            
            Consumer<AppNotifier>(
              builder: (context, provalue, child) =>  CustomButton(
                isLoading: provalue.isLoading,
                onTap: () {
                  if (_nameController.text.isEmpty ||_quantityController.text.isEmpty || _expiryDateController.text.isEmpty) {
                    displayMessage("please fill all the fields", context);
                  } else {

                    provalue.setLoading(true);

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
                    _updateFoodItemInFirestore(foodItem).then((value){
                      provalue.setLoading(false);
                      
                    }).catchError((error){
                      provalue.setLoading(false);
                    });
                  }
                },
                text: 'Save Changes',
              
              ),
            ),

            SizedBox(height: 10.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  gotoPage( SelectCityPage(foodItem: widget.foodItem,) , context);
                },
                child: Text('Donate Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
