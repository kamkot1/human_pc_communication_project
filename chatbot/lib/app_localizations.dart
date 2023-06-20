import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'hello': 'Hello',
      'goodbye': 'Goodbye',
      'settings': 'Settings',
      'text': 'Text',
      'your_app': 'Your app',
      'change_language': 'Change language',
      'english': 'English',
      'polish': 'Polish',
      "restart_message": "Changes will apply after restarting the app.",
      "text_to_speech": "Text to speech",
      "speech_to_text": "Speech to text",
    },
    'pl': {
      'hello': 'Cześć',
      'goodbye': 'Do widzenia',
      'settings': 'Ustawienia',
      'text': 'Tekst',
      'your_app': 'Twoja aplikacja',
      'change_language': 'Zmień język',
      'english': 'Angielski',
      'polish': 'Polski',
      "restart_message":
          "Zmiany zostaną wprowadzone po ponownym uruchomieniu aplikacji.",
      "text_to_speech": "Zamiana mowy na tekst",
      "speech_to_text": "Lektor czytający odpowiedzi",
    },
  };

  String? get hello {
    return _localizedValues[locale.languageCode]?['hello'];
  }

  String? get goodbye {
    return _localizedValues[locale.languageCode]?['goodbye'];
  }

  String? get settings {
    return _localizedValues[locale.languageCode]?['settings'];
  }

  String? get text {
    return _localizedValues[locale.languageCode]?['text'];
  }

  // ignore: non_constant_identifier_names
  String? get your_app {
    return _localizedValues[locale.languageCode]?['your_app'];
  }

  // ignore: non_constant_identifier_names
  String? get change_language {
    return _localizedValues[locale.languageCode]?['change_language'];
  }

  String? get english {
    return _localizedValues[locale.languageCode]?['english'];
  }

  String? get polish {
    return _localizedValues[locale.languageCode]?['polish'];
  }

  String? get restart_message {
    return _localizedValues[locale.languageCode]?['restart_message'];
  }

  String? get text_to_speech {
    return _localizedValues[locale.languageCode]?['text_to_speech'];
  }

  String? get speech_to_text {
    return _localizedValues[locale.languageCode]?['speech_to_text'];
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pl'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
