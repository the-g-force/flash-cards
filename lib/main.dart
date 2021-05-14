import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FlashCard(),
    );
  }
}

class FlashCard extends StatefulWidget {
  FlashCard({Key key, this.speech}) : super(key: key);

  final SpeechToText speech;

  @override
  _FlashCardState createState() => _FlashCardState();
}

enum FlashCardResult { waiting, correct, incorrect }

class _FlashCardState extends State<FlashCard> {
  final SpeechToText speech = new SpeechToText();
  bool _hasSpeech;
  FlashCardResult _result = FlashCardResult.waiting;
  String _guess = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
        finalTimeout: Duration(milliseconds: 0));

    setState(() {
      _hasSpeech = hasSpeech;
      print("Has speech? " + (_hasSpeech ? "Yes" : "No"));
    });

    speech.listen(onResult: onSpeechResult, listenFor: Duration(seconds: 2));
  }

  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
  }

  void statusListener(String status) {
    print(
        'Received listener status: $status, listening: ${speech.isListening}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [Text("5*2"), Text(_guess), Text(_result.toString())]);
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      int spokenNumber = int.tryParse(result.recognizedWords);
      _guess = (spokenNumber == null) ? "" : result.recognizedWords;
      _result = result.recognizedWords.contains("10")
          ? FlashCardResult.correct
          : FlashCardResult.incorrect;
    });
  }
}
