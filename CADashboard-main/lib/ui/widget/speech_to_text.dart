import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:cadashboard/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

Future showDialogForListen({required BuildContext context, required Function(String speech) onListing}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.white,
        insetAnimationCurve: Curves.slowMiddle,
        insetAnimationDuration: const Duration(seconds: 4),
        child: CustomSpeechToText(onListing: onListing),
      );
    },
  );
}

class CustomSpeechToText extends StatefulWidget {
  final Function(String speech) onListing;
  const CustomSpeechToText({super.key, required this.onListing});

  @override
  State<CustomSpeechToText> createState() => _CustomSpeechToTextState();
}

class _CustomSpeechToTextState extends State<CustomSpeechToText> {

  final SpeechToText speechToText = SpeechToText();

  ValueNotifier<bool> speechEnabled = ValueNotifier(false);
  String lastWords = '';

  String first = "1) To Change Status – Say “Change status to [Status]” (e.g., “Change status to Completed”).";
  String second = "2) To Add Notes – Say “Add note” followed by your message (e.g., “Add note Project needs review”).";
  String third = "3) To Add Effort – Say “Add effort on [Date] for [Hours or Minutes] – [Description]” (e.g., “Add effort on 20th Feb for 2 hours 20 minutes description Completed review”).";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    appPrint("AAA : ${speechToText.hasError}");
    speechEnabled.addListener(() {
      appPrint("addListener");
      if(speechEnabled.value == false){
        appPrint("Navigate POP : $lastWords");
        widget.onListing.call(lastWords);
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    appPrint("Call Dispose");
    speechEnabled.value = false;
    speechToText.stop();
    super.dispose();
    _stopListening();
  }

  Future<void> _requestPermissions() async {
    final microPhoneStatus = await Permission.microphone.request();
    if (microPhoneStatus.isDenied) {
      _showPermissionSnackBar(microPhoneStatus);
    } else if (microPhoneStatus.isGranted) {
      await _initSpeechToText();
    } else {
      await openAppSettings().then((value) => _requestPermissions());
    }
  }

  void _showPermissionSnackBar(PermissionStatus cameraStatus) {
    String message = 'Permissions required: ';
    if (cameraStatus.isDenied) {
      message += 'Microphone ';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          '$message permission is required. Please enable it in settings.',
          style: const TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () => openAppSettings(),
        ),
      ),
    );
  }

  _initSpeechToText() async {
    try{
      await speechToText.initialize(
        onStatus: (status) async {
          appPrint("Speech onStatus : $status == done");
          if(status == "done"){
            Future.delayed(const Duration(milliseconds: 300), () async {
              await speechToText.stop();
              speechEnabled.value = false;
            });
            appPrint("Speech onStatus : ${speechEnabled.value}");
          }
        },
        onError: (errorNotification) async {
          appPrint("Speech onError : ${errorNotification.toJson()}");
          await speechToText.stop();
          if(mounted == true){
            speechEnabled.value = false;
          }
        },
      ).then((value) {
        appPrint("Then Value : $value");
        _startListening();
      });
    } catch (e) {
      appPrint("object Error");
    }
  }

  _startListening() async {
    await speechToText.listen(onResult: _onSpeechResults);
    speechEnabled.value = true;
  }

  _onSpeechResults(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    appPrint("Result : ${result.recognizedWords} :: ${result.finalResult} :: ${result.hasConfidenceRating}");

    if (result.finalResult && result.hasConfidenceRating) {
      _stopListening();
      speechEnabled.value = false;
    }
  }

  _stopListening() async {
    await speechToText.stop();
    appPrint("object : $lastWords :: ${speechEnabled.value}");
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: speechEnabled,
        builder: (context, speech, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(top: 25),
                child: Text("$first\n\n$second\n\n$third", style: const TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _startListening();
                  });
                },
                child: AvatarGlow(
                  curve: Curves.decelerate,
                  repeat: true,
                  animate: true,
                  glowColor: Colors.redAccent,
                  glowCount: !speech ? 0 : 2,
                  glowRadiusFactor: !speech ? 0 : 1,
                  duration: const Duration(seconds: 2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Icon(
                      !speech ? Icons.mic_off : Icons.mic,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: speechToText.isListening ? 1.0 : 0.5,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(lastWords == ""
                    ? 'Tap the microphone to start listening...'
                    : lastWords
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        }
    );
  }
}

