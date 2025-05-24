import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundProvider with ChangeNotifier {
  bool _isMusicOn = true;
  bool _isEffectsOn = true;
  double _musicVolume = 0.5;
  double _effectsVolume = 0.7;

  SoundProvider() {
    _loadSettings();
  }

  bool get isMusicOn => _isMusicOn;
  bool get isEffectsOn => _isEffectsOn;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;

  // Backward compatibility
  bool get isSoundOn => _isMusicOn && _isEffectsOn;

  void toggleMusic() {
    _isMusicOn = !_isMusicOn;
    _saveSettings();
    notifyListeners();
  }

  void toggleEffects() {
    _isEffectsOn = !_isEffectsOn;
    _saveSettings();
    notifyListeners();
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _saveSettings();
    notifyListeners();
  }

  void setEffectsVolume(double volume) {
    _effectsVolume = volume.clamp(0.0, 1.0);
    _saveSettings();
    notifyListeners();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('isMusicOn') ?? true;
    _isEffectsOn = prefs.getBool('isEffectsOn') ?? true;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _effectsVolume = prefs.getDouble('effectsVolume') ?? 0.7;
    notifyListeners();
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicOn', _isMusicOn);
    await prefs.setBool('isEffectsOn', _isEffectsOn);
    await prefs.setDouble('musicVolume', _musicVolume);
    await prefs.setDouble('effectsVolume', _effectsVolume);
  }
}
