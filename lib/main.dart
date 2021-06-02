import 'dart:math';

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
  bool _isButtonEnabled = true;

  int _leftOperand;
  int _rightOperand;

  @override
  void initState() {
    super.initState();
    initSpeech();
    _randomizeOperands();
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
    return Column(children: [
      Text("$_leftOperand x $_rightOperand"),
      Text(_guess),
      Text(_result.toString()),
      ElevatedButton(
        onPressed: _isButtonEnabled
            ? () {
                setState(() {
                  _isButtonEnabled = false;
                });
                startListening();
              }
            : null,
        child: Text(_isButtonEnabled ? "Ready" : "Speak Now"),
      ),
      Spacer(),
      ElevatedButton(
          onPressed: () {
            setState(() {
              _isButtonEnabled = true;
              _guess = "";
              _randomizeOperands();
            });
          },
          child: Text("Next Problem"))
    ]);
  }

  void _randomizeOperands() {
    _leftOperand = Random().nextInt(10);
    _rightOperand = Random().nextInt(10);
  }

  void startListening() async {
    speech.listen(
        onResult: onSpeechResult,
        listenFor: Duration(seconds: 3),
        pauseFor: Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true);
    await Future.delayed(Duration(seconds: 2)).then((value) => speech.stop());
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    print(
        "Recognized words: ${result.recognizedWords}; final result: ${result.finalResult}");
    setState(() {
      int spokenNumber = int.tryParse(result.recognizedWords);
      _guess = (spokenNumber == null) ? "" : result.recognizedWords;
      int answer = _leftOperand * _rightOperand;
      _result = result.recognizedWords.contains(answer.toString())
          ? FlashCardResult.correct
          : FlashCardResult.incorrect;
    });
  }
}
