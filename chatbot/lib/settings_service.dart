import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  final SharedPreferences prefs;
  String _currentLanguageCode;

  SettingsService(this.prefs)
      : _currentLanguageCode = prefs.getString('language') ?? 'en';

  String get currentLanguageCode => _currentLanguageCode;

  set currentLanguageCode(String newLang) {
    _currentLanguageCode = newLang;
    prefs.setString('language', newLang);
    notifyListeners();
  }

  //setters and getters for _textToSpeechEnabled and _speechToTextEnabled
  bool get textToSpeechEnabled => prefs.getBool('textToSpeechEnabled') ?? false;

  set textToSpeechEnabled(bool value) {
    prefs.setBool('textToSpeechEnabled', value);
    notifyListeners();
  }

  bool get speechToTextEnabled => prefs.getBool('speechToTextEnabled') ?? false;

  set speechToTextEnabled(bool value) {
    prefs.setBool('speechToTextEnabled', value);
    notifyListeners();
  }
}
