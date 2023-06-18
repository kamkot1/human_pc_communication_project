import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final languageCodes = {
    'English': 'en',
    'Polski': 'pl',
  };

  String _currentLanguage = 'English';
  String _currentLanguageCode = 'en';

  bool _textToSpeechEnabled = true;
  bool _speechToTextEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadCurrentLanguage();
  }

  _loadCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguageCode = (prefs.getString('language') ?? 'en');
      _currentLanguage = languageCodes.entries
          .firstWhere((element) => element.value == _currentLanguageCode)
          .key;
    });
  }

  _updateCurrentLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', languageCodes[language]!);
    setState(() {
      _currentLanguage = language;
      _currentLanguageCode = languageCodes[language]!;
    });
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _textToSpeechEnabled = (prefs.getBool('textToSpeechEnabled') ?? true);
      _speechToTextEnabled = (prefs.getBool('speechToTextEnabled') ?? true);
    });
  }

  void _updatePreference(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.settings ?? ''),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(17.0),
            child: Text(
              AppLocalizations.of(context)?.change_language ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          DropdownButton<String>(
            value: _currentLanguage,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            //padding left - 50 pixels
            padding: const EdgeInsets.only(left: 20),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _currentLanguage = newValue!;
                String languageCode = newValue == 'English' ? 'en' : 'pl';
                flutterTts.setLanguage(languageCode);
                // Save the language preference so that it can be loaded when the app restarts.
                _updateCurrentLanguage(languageCode);

                // Show a dialog or a snackbar with the localized message.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        AppLocalizations.of(context)?.restart_message ?? ''),
                  ),
                );
              });
            },
            items: languageCodes.keys
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)?.text_to_speech ?? ''),
            value: _textToSpeechEnabled,
            onChanged: (bool value) {
              setState(() {
                _textToSpeechEnabled = value;
                _updatePreference('textToSpeechEnabled', value);
              });
            },
          ),
          SwitchListTile(
              title: Text(AppLocalizations.of(context)?.speech_to_text ?? ''),
              value: _speechToTextEnabled,
              onChanged: (bool value) {
                setState(() {
                  _speechToTextEnabled = value;
                  _updatePreference('speechToTextEnabled', value);
                });
              }),
        ],
      ),
    );
  }
}
