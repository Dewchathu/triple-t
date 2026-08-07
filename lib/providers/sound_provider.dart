import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundProvider extends ChangeNotifier {
  bool _isMusicOn = true;
  bool _isEffectsOn = true;
  double _musicVolume = 0.5;
  double _effectsVolume = 0.7;
  bool _isMusicPlaying = false;

  SoundProvider() {
    _loadSettings();
  }

  bool get isMusicOn => _isMusicOn;
  bool get isEffectsOn => _isEffectsOn;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;

  Future<void> initializeMusic() async {
    await _loadSettings();
    print('Initializing music, isPlaying: $_isMusicPlaying, isMusicOn: $_isMusicOn');
    if (_isMusicPlaying) {
      await FlameAudio.bgm.stop().catchError((e) {
        print('Error stopping existing music: $e');
      });
      _isMusicPlaying = false;
    }
    if (_isMusicOn) {
      await FlameAudio.bgm
          .play('theme.mp3', volume: _musicVolume)
          .catchError((e) {
        print('Error playing theme.mp3: $e');
      });
      _isMusicPlaying = true;
    }
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    print('Toggling music: $_isMusicOn -> ${!_isMusicOn}');
    _isMusicOn = !_isMusicOn;
    await _saveSettings();
    if (_isMusicOn) {
      if (_isMusicPlaying) {
        await FlameAudio.bgm.stop().catchError((e) {
          print('Error stopping music before replay: $e');
        });
      }
      await FlameAudio.bgm
          .play('theme.mp3', volume: _musicVolume)
          .catchError((e) {
        print('Error playing theme.mp3: $e');
      });
      _isMusicPlaying = true;
    } else {
      await FlameAudio.bgm.stop().catchError((e) {
        print('Error stopping theme.mp3: $e');
      });
      _isMusicPlaying = false;
    }
    notifyListeners();
  }

  Future<void> toggleEffects() async {
    _isEffectsOn = !_isEffectsOn;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setMusicVolume(double volume) async {
    print('Setting music volume: $volume');
    _musicVolume = volume;
    await _saveSettings();
    if (_isMusicOn && _isMusicPlaying) {
      await FlameAudio.bgm.audioPlayer.setVolume(volume).catchError((e) {
        print('Error setting music volume: $e');
      });
    }
    notifyListeners();
  }

  Future<void> setEffectsVolume(double volume) async {
    _effectsVolume = volume;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('isMusicOn') ?? true;
    _isEffectsOn = prefs.getBool('isEffectsOn') ?? true;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _effectsVolume = prefs.getDouble('effectsVolume') ?? 0.7;
    if (!_isMusicOn) {
      await FlameAudio.bgm.stop().catchError((e) {
        print('Error stopping music in _loadSettings: $e');
      });
      _isMusicPlaying = false;
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicOn', _isMusicOn);
    await prefs.setBool('isEffectsOn', _isEffectsOn);
    await prefs.setDouble('musicVolume', _musicVolume);
    await prefs.setDouble('effectsVolume', _effectsVolume);
  }
}
