import 'package:flutter/material.dart';
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
    'Polish': 'pl',
  };

  String _currentLanguage = 'English';
  String _currentLanguageCode = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  _loadCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguageCode = (prefs.getString('language') ?? 'en');
      _currentLanguage = languageCodes.entries
          .firstWhere((element) => element.value == _currentLanguageCode,
              orElse: () => const MapEntry('English', 'en'))
          .key;
    });
  }

  _updateCurrentLanguage(String languageName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var languageCode = languageCodes[languageName];
    prefs.setString('language', languageCode!);
    setState(() {
      _currentLanguage = languageName;
      _currentLanguageCode = languageCode!;
    });
  }

  FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Change language',
              style: TextStyle(fontSize: 20),
            ),
          ),
          DropdownButton<String>(
            value: _currentLanguage,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _currentLanguage = newValue!;
                String languageCode = languageCodes[newValue]!;
                flutterTts.setLanguage(languageCode);
                _updateCurrentLanguage(newValue);
              });
            },
            items: <String>['English', 'Polish']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
