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
      'your_app': 'Chatbot app',
      'change_language': 'Change language',
      'english': 'English',
      'polish': 'Polish',
      "restart_message": "Changes will apply after restarting the app.",
      "text_to_speech": "Text to speech",
      "speech_to_text": "Speech to text",
      "welcomeMessage":
          "Welcome to the app! You can start using it simply by asking the chatbot a question. If you'd like to talk to it, just press the microphone!",
      "stop_listening": "Stop listening",
      "input_placeholder": "Enter message here...",
    },
    'pl': {
      'hello': 'Cześć',
      'goodbye': 'Do widzenia',
      'settings': 'Ustawienia',
      'text': 'Tekst',
      'your_app': 'Chatbot app',
      'change_language': 'Zmień język',
      'english': 'Angielski',
      'polish': 'Polski',
      "restart_message":
          "Zmiany zostaną wprowadzone po ponownym uruchomieniu aplikacji.",
      "text_to_speech": "Zamiana mowy na tekst",
      "speech_to_text": "Lektor czytający odpowiedzi",
      "welcomeMessage":
          "Witaj w aplikacji! Możesz zacząć jej używać zadając chatbotowi pytanie. Jeśli chcesz z nim porozmawiać, po prostu naciśnij mikrofon!",
      "stop_listening": "Przestań używać mikrofonu",
      "input_placeholder": "Napisz wiadomość...",
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

  String? get welcomeMessage {
    return _localizedValues[locale.languageCode]?['welcomeMessage'];
  }

  String? get stopListening {
    return _localizedValues[locale.languageCode]?['stop_listening'];
  }

  String? get inputPlaceholder {
    return _localizedValues[locale.languageCode]?['input_placeholder'];
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
