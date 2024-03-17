import 'package:eco_eats/admin/dashboard.dart';
import 'package:eco_eats/utils/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminLoginPage extends StatelessWidget {


  FirebaseAuth  _auth = FirebaseAuth.instance;


  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    emailController.text = "admin@ecoeats.com";
    passwordController.text = "admin123";


    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 100,
              color: Colors.purple.shade400,
            ),
            SizedBox(height: 20),
            Text(
              'Admin Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                _auth
                .signInWithEmailAndPassword(email: emailController.text, password: passwordController.text)
                .then((value){

                  displayMessage("Logged in as ${emailController.text}", context);
                  removeAllAndGotoPage( DashBoard() , context);


                });






 
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
