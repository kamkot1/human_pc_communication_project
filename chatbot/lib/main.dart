//main.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'dart:convert' as convert;
import 'model.dart';
import 'constant.dart';
import 'settings_page.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSpeechToText(); // Initialize speech recognition
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(); // Or another loading indicator
        }

        SharedPreferences prefs = snapshot.data!;
        String languageCode = prefs.getString('language') ?? 'en';
        bool textToSpeechEnabled =
            (prefs.getBool('textToSpeechEnabled') ?? true);
        bool speechToTextEnabled =
            (prefs.getBool('speechToTextEnabled') ?? true);

        return MaterialApp(
          locale: Locale(languageCode),
          localizationsDelegates: const [
            _AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('pl', ''), // Polish
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.green),
          home: ChatPage(
            speechToTextEnabled: speechToTextEnabled,
            textToSpeechEnabled: textToSpeechEnabled,
          ),
          routes: {
            '/settings': (context) => SettingsPage(),
          },
        );
      },
    );
  }
}

class ChatPage extends StatefulWidget {
  final bool? speechToTextEnabled;
  final bool? textToSpeechEnabled;
  const ChatPage(
      {super.key, this.speechToTextEnabled, this.textToSpeechEnabled});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

int currentPage = 0;
const backgroundColor = Color.fromARGB(96, 255, 255, 255);
const botBackgroundColor = Color.fromARGB(85, 255, 255, 255);
late bool isLoading;
bool isEditing = false;
// ignore: prefer_final_fields
TextEditingController _textController = TextEditingController();
final _scrollController = ScrollController();
final List<ChatMessage> _messages = [];
var input = _textController.text;
String voiceInput = '';
bool stopListeningAfterSpeech = false;
bool isRequestInProgress = false;
var currentLanguage = "pl-PL";

stt.SpeechToText speech = stt.SpeechToText();
FlutterTts flutterTts = FlutterTts();

Future<bool> initializeSpeechToText() async {
  bool available = await speech.initialize();
  return available;
}

void _saveLanguagePreference(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('language', languageCode);
}

void initializeSpeechRecognition() async {
  bool available = await speech.initialize(
    onStatus: (status) {
      print('Speech recognition status: $status');
    },
    onError: (error) {
      print('Speech recognition error: $error');
    },
  );

  if (available) {
    // Speech recognition is available
    print('Speech recognition available');
  } else {
    // Speech recognition is not available
    print('Speech recognition not available');
  }
}

Future<bool> requestMicrophonePermission() async {
  PermissionStatus status = await Permission.microphone.request();
  return status.isGranted;
}

class _ChatPageState extends State<ChatPage> {
  late FocusNode _focusNode;
  CancelableOperation<String>? currentOperation;
  ValueNotifier<bool> isListening = ValueNotifier<bool>(false);
  final List<ChatMessage> _messages = []; // Move this line here
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    isListening.value = false;

    void _handleFocusChange() {
      if (_focusNode.hasFocus) {
        // Textfield ma focus, użytkownik jest w trakcie edycji
        isEditing = true;
      } else {
        // TextField straiło focus
        isEditing = false;
        if (isListening.value) {
          stopListening();
          sendMessage(voiceInput);
        }
      }
    }

    void _loadLanguagePreference() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String languageCode = prefs.getString('language') ?? 'en-US';
      setState(() {
        currentLanguage = languageCode == 'en-US' ? 'English' : 'Polski';
      });
      flutterTts.setLanguage(languageCode);
    }

    _loadLanguagePreference();
    // Nowy FocusNode z dodanym listenerem dla pola tekstowego
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    @override
    void dispose() {
      // Don't forget to dispose when done
      _focusNode.dispose();
      super.dispose();
    }

    flutterTts.setCompletionHandler(() {
      startListeningAfterSpeech();
    });
  }

  Future<String> generateResponse(String prompt, bool wasVoiceInput) async {
    const apiKey = apiSecretKey;
    var url = Uri.https("api.openai.com", "/v1/chat/completions");

    final messages = [
      {
        'role': 'system',
        'content':
            'You can start the conversation with a system message if needed.',
      },
      {'role': 'user', 'content': prompt},
    ];

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
          'temperature': 0.5,
          'max_tokens': 2000,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0
        }));

    //prompt od usera
    //zdekoduj wiadomość
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody =
          convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
      String newresponse = responseBody['choices'][0]['message']['content'];
      //jeżeli był użyty mikrofon, wtedy przeczytaj
      if (wasVoiceInput && widget.textToSpeechEnabled!) {
        await flutterTts.speak(newresponse);
      }
      return newresponse;
    } else {
      throw Exception('Failed to generate response: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.your_app ?? ''),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                //chat body
                Expanded(
                  child: _buildList(),
                ),
                Visibility(
                  visible: isLoading,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      //input
                      _buildInput(),

                      //submit
                      _buildSubmit(),
                    ],
                  ),
                )
              ],
            ),
            if (isListening.value == true)
              Center(
                child: FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      stopListening();
                    });
                  },
                  icon: Icon(Icons.stop),
                  label:
                      Text(AppLocalizations.of(context)?.stopListening ?? ''),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Timer? timer;
  static const pauseDuration =
      Duration(seconds: 2); // Change to fit requirements

  void sendMessage(voiceInput) {
    if (_textController.text.isNotEmpty && !isListening.value) {
      isRequestInProgress = true;
      bool voiceInputted = voiceInput == _textController.text;
      setState(() {
        _messages.add(ChatMessage(
            text: _textController.text,
            chatMessageType: ChatMessageType.user,
            wasVoiceInput: voiceInputted));
      });
      isLoading = true;
      Future.delayed(const Duration(milliseconds: 50))
          .then((value) => _scrollDown());
      generateResponse(_textController.text, voiceInputted).then((value) {
        setState(() {
          isLoading = false;
          _messages.add(ChatMessage(
              text: value,
              chatMessageType: ChatMessageType.bot,
              wasVoiceInput: false));
        });
      });
      _textController.clear();
      voiceInput = '';
      isRequestInProgress = false;
    }
  }

  void stopListening() {
    timer?.cancel();
    isListening.value = false;
    speech.stop();
  }

  void startListening() {
    if (widget.speechToTextEnabled == true) {
      isListening.value = true;
      // check if speech to text is enabled
      if (isEditing) {
        return;
      }
      timer?.cancel();
      speech.listen(
        onResult: (result) {
          setState(() {
            voiceInput = result.recognizedWords;
            // Check if the voice input ends with "stop listening"
            if (voiceInput.toLowerCase().endsWith('stop listening')) {
              voiceInput = voiceInput
                  .substring(0, voiceInput.length - 'stop listening'.length)
                  .trim(); // remove "stop listening" from the voice input
              stopListening();
              stopListeningAfterSpeech = true;
            } else {
              _textController.text = voiceInput;
            }

            if (result.finalResult && !isEditing) {
              isListening.value = false;
              timer?.cancel(); // Cancel the timer when the result is final
              sendMessage(voiceInput);
              isListening.value = false;
            } else {
              timer?.cancel();
              timer = Timer(pauseDuration, () {
                stopListening();
                isListening.value = false;
              });
            }
          });
        },
      );
    }
  }

  void resetListeningAfterSpeech() {
    stopListeningAfterSpeech = false;
  }

  void startListeningAfterSpeech() {
    if (!isEditing && !stopListeningAfterSpeech) {
      Timer(Duration(seconds: 1), () {
        startListening();
      });
    }
  }

  void cancelRequest() {
    cancelCurrentOperation();
    setState(() {
      isRequestInProgress = false;
    });
  }

  void cancelCurrentOperation() {
    currentOperation?.cancel();
  }

  //Przycisk wysłania zapytania TODO: Wyłączyć animację naciśnięcia
  Widget _buildSubmit() {
    return Visibility(
      visible: !isRequestInProgress,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            color: botBackgroundColor,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: Colors.black87,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      startListening();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: Colors.black87,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_textController.text.isNotEmpty) {
                        bool voiceInputted = voiceInput == _textController.text;
                        _messages.add(ChatMessage(
                            text: _textController.text,
                            chatMessageType: ChatMessageType.user,
                            wasVoiceInput: voiceInputted));
                        isLoading = true;
                        Future.delayed(const Duration(milliseconds: 50))
                            .then((value) => _scrollDown());
                        _textController.clear();
                        voiceInput = '';
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: isRequestInProgress
                ? IconButton(
                    icon: Icon(Icons.cancel),
                    color: Colors.red,
                    onPressed: cancelRequest,
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  //Interfejs dla inputu użytkownika TODO: Dodać opcję inputu głosowego
  Expanded _buildInput() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(
            20.0, 0.0, 10.0, 10.0), // Left, Top, Right, Bottom
        child: TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.inputPlaceholder ?? '',
              hintStyle: TextStyle(color: Color.fromARGB(136, 151, 151, 151)),
              border: InputBorder.none,
            ),
            focusNode: _focusNode,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(color: Colors.black),
            controller: _textController,
            onChanged: (text) {
              setState(() {
                isEditing = true; // Użytkownik jest w trakcie edycji
                timer?.cancel(); // Cancel the timer
                if (isListening.value) {
                  // If listening, stop
                  speech.stop();
                }
                voiceInput = text;
              });
            }),
      ),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildList() {
    if (_messages.isEmpty) {
      return ListView(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  AppLocalizations.of(context)?.welcomeMessage ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: _messages.length + (isListening.value ? 1 : 0),
        controller: _scrollController,
        itemBuilder: ((context, index) {
          if (index < _messages.length) {
            var message = _messages[index];
            return ChatMessageWidget(
              text: message.text,
              chatMessageType: message.chatMessageType,
            );
          } else if (isListening.value) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    stopListening();
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop),
                    SizedBox(width: 8.0),
                    Text("Stop Listening"),
                  ],
                ),
              ),
            );
          } else {
            return SizedBox.shrink(); // This should never be reached
          }
        }),
      );
    }
  }
}

class ChatMessageWidget extends StatelessWidget {
  final String text;
  final ChatMessageType chatMessageType;
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: chatMessageType == ChatMessageType.bot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: const CircleAvatar(
                    //backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                    //child: Image.asset('images/ChatGPT_logo.svg'),
                    child: Icon(Icons.bubble_chart_outlined),
                  ),
                )
              : Container(),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: chatMessageType == ChatMessageType.bot
                    ? botBackgroundColor
                    : backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
            ),
          ),
          chatMessageType == ChatMessageType.user
              ? Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
