import 'package:eco_eats/admin/add_product_page.dart';
import 'package:eco_eats/admin/item_list.dart';
import 'package:eco_eats/home.dart';
import 'package:eco_eats/utils/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DashBoard extends StatelessWidget {
  DashBoard({super.key});


  FirebaseAuth  _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),

        actions: [
          IconButton(
            onPressed: (){
              showAlertDialouge(
                context,
                title: "Signout",
                content: "Are you sure you want to signout?",
                onConfirm: () {
                  _auth.signOut().then((value){  removeAllAndGotoPage( HomePage() , context);  });
                  Navigator.pop(context);
                },
              );
            }, 
            icon: Icon(Icons.logout)
          )
        ],

      ),



      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => gotoPage( ProductListPage() ,context),
                child: Card(
                  child: Center(child: Text("Products", style: TextStyle(color: Colors.purple.shade200, fontSize: 30),)),
                ),
              ),
            ),
          )
        ],

      ),






    );
  }
}