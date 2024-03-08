import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// dotenv.env['VAR_NAME'];

class PromtService extends ChangeNotifier{
  var result;
  var chatt;
  var model;
  late ChatSession chat;

  void promtFetch (  String Prompt)async{
    print(Prompt.toString());
    // dotenv.env['ApiKey']
    final key= dotenv.env['ApiKey'];
    model = GenerativeModel(model: 'gemini-pro', apiKey: key!);
    final content = [Content.text(Prompt)];

    // chat=await model.startChat();
    final response = await model.generateContent(content);
    result=response.text;
    print(result.toString());
    // print(chat.history.toList();
    notifyListeners();
  }
}