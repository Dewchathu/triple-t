import 'package:flutter/material.dart';

class SoundProvider extends ChangeNotifier {
  bool _isSoundOn = true;

  bool get isSoundOn => _isSoundOn;

  void toggleSound() {
    _isSoundOn = !_isSoundOn;
    notifyListeners();
  }
}

