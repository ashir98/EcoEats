import 'package:eco_eats/admin/items/add_item_page.dart';
import 'package:eco_eats/admin/items/edit_item_page.dart'; // Import the edit item page
import 'package:eco_eats/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('admin_products').snapshots(),
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No products found.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];
              DateTime expiryDate = (product['expiryDate'] as Timestamp).toDate(); // Convert Timestamp to DateTime

              return ListTile(
                title: Text(
                  product['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category: ${product['category']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Quantity: ${product['quantity']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Expiry: ${DateFormat('yyyy-MM-dd').format(expiryDate)}', // Format the expiry date
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Barcode: ${product['barcode']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editProduct(product.id); // Navigate to edit product page
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          gotoPage(AddItemPage(), context);
        },
        label: Row(
          children: [
            Icon(Icons.add),
            Text("Add item"),
          ],
        ),
      ),
    );
  }

  void _editProduct(String productId) {
    gotoPage(EditItemPage(productId: productId), context); // Navigate to edit product page
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance.collection('admin_products').doc(productId).delete();
      print('Product deleted successfully');
    } catch (e) {
      print('Error deleting product: $e');
    }
  }
}
