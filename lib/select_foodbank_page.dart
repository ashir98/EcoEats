import 'package:eco_eats/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectCityPage extends StatefulWidget {
  final DocumentSnapshot foodItem;

  SelectCityPage({required this.foodItem});

  @override
  _SelectCityPageState createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {
  String _selectedCity = 'Select City';
  String _selectedFoodBankId = '';
  String _foodbankName = "";
  String _foodbankCity = "";

  void _donateItem() async {
    try {
      await FirebaseFirestore.instance.collection('donatedItems').add({
        'foodBankId': _selectedFoodBankId,
        'foodBankName' : _foodbankName,
        'foodBankCity ' : _foodbankCity,
        'itemCategory': widget.foodItem['category'],
        'itemName': widget.foodItem['name'],
        'quantity': widget.foodItem['quantity'],
        'expiryDate': widget.foodItem['expiryDate'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Item donated successfully!', style: TextStyle(color: Colors.purple.shade50)),
          backgroundColor: Colors.purple.shade300,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Error donating item: $e', style: TextStyle(color: Colors.purple.shade50)),
          backgroundColor: Colors.purple.shade300,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Food Bank'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('foodbanks').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                List<String> cities = ['Select City'];
                if (snapshot.hasData) {
                  cities.addAll(snapshot.data!.docs.map((doc) => doc['city'] as String).toSet().toList());
                }

                return DropdownButtonFormField<String>(
                  value: _selectedCity,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value!;
                    });
                  },
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Select City'),
                );
              },
            ),
            SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('foodbanks')
                  .where('city', isEqualTo: _selectedCity)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('Select a city to see the available foodbanks'),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot foodBank = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text(foodBank['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(foodBank['address']),
                            Text(foodBank['contact'])
                          ],
                        ),
                        trailing: TextButton(
                          onPressed: () {

                            setState(() {
                            _selectedFoodBankId = foodBank.id;
                            _foodbankCity = foodBank['city'];
                            _foodbankName = foodBank['name'];

                          });
                          _donateItem();
                            
                          },
                          child: Text("Donate", style: TextStyle(color: Colors.purple.shade400),),
                        ),
                        
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
