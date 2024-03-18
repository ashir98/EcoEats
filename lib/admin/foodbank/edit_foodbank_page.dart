import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFoodBankForm extends StatefulWidget {
  final String docId; // Document ID of the food bank to be edited

  EditFoodBankForm({required this.docId});

  @override
  _EditFoodBankFormState createState() => _EditFoodBankFormState();
}

class _EditFoodBankFormState extends State<EditFoodBankForm> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _cityController; // Controller for the city field

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _cityController = TextEditingController(); // Initialize the city controller
    _fetchFoodBankDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _cityController.dispose(); // Dispose the city controller
    super.dispose();
  }

  Future<void> _fetchFoodBankDetails() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('foodbanks').doc(widget.docId).get();
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      _nameController.text = data['name'];
      _addressController.text = data['address'];
      _contactController.text = data['contact'];
      _cityController.text = data['city']; // Set the city controller value
    } catch (e) {
      print('Error fetching food bank details: $e');
    }
  }

  Future<void> _updateFoodBank() async {
    try {
      await FirebaseFirestore.instance.collection('foodbanks').doc(widget.docId).update({
        'name': _nameController.text,
        'address': _addressController.text,
        'contact': _contactController.text,
        'city': _cityController.text, // Update the city field
      });
      Navigator.pop(context); // Navigate back to the food bank list page after updating
    } catch (e) {
      print('Error updating food bank: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Food Bank'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contact'),
            ),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'), // Add city field
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateFoodBank,
              child: Text('Update Food Bank'),
            ),
          ],
        ),
      ),
    );
  }
}
