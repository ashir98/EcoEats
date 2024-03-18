import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  String text;
  bool isLoading;
  VoidCallback onTap;

  CustomButton({super.key, required this.text,  this.isLoading = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap, 
        child: isLoading? SizedBox( width: 25 ,height: 25 , child: CircularProgressIndicator()) : Text(text)
      ),
    );
  }
}