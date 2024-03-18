import 'package:flutter/material.dart';

class AppNotifier extends ChangeNotifier{

  bool _isLoading = false;
  bool get isLoading => _isLoading;


  setLoading(bool loading){
    _isLoading = loading;
    notifyListeners();
  }





}