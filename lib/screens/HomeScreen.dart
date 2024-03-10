import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart';
import 'package:myapp/screens/ResultData.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  // @override
  void _startListening() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone.request();
    }
    if (status.isGranted) {
      if (!_isListening) {
        bool available = await _speech.initialize(
          onStatus: (status) => print('onStatus: $status'),
          onError: (error) => print('onError: $error'),
        );

        if (available) {
          setState(() {
            _isListening = true;
          });

          _speech.listen(
            onResult: (result) {
              setState(() {
                _text = result.recognizedWords;
              });
            },
            // listenFor: Duration(seconds: 10),
          );
        }
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      print('Recognition result: $_text');

      _speech.stop();
      setState(() {
        _isListening = false;
        _addToTextField(_text);
      });

      // Automatically add the recognized text to the TextField when stopped
    }
  }

  void _addToTextField(String text) {
    // Add the recognized text to the TextField
    setState(() {
      _PromtController.text = text;
    });
  }

  late final ChatSession _chat;
  late final GenerativeModel _model;
  bool _loading = false;

  @override
  void initState() {
    _model =
        GenerativeModel(model: "gemini-pro", apiKey: dotenv.env['ApiKey']!);
    _chat = _model.startChat();
    _speech = stt.SpeechToText();
    super.initState();
  }

  TextEditingController _PromtController = TextEditingController();
  FocusNode _focusController = FocusNode();
  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<PromtService>(context);
    bool hasApiKey =
        dotenv.env['ApiKey'] != null && dotenv.env['ApiKey']!.isNotEmpty;

    Future<void> _sendChatMessage(String message) async {
      setState(() => _loading = true);

      try {
        final response = await _chat.sendMessage(Content.text(message));
        final text = response.text;
        if (text == null) {
          debugPrint('No response from API.');
          return;
        }
        setState(() => _loading = false);
      } catch (e) {
        debugPrint(e.toString());
      } finally {
        _PromtController.clear();
        setState(() => {_loading = false, _isListening = false});
      }
    }

    final ScrollController _controller = ScrollController();

// This is what you're looking for!
    void _scrollDown() {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(seconds: 2),
        curve: Curves.fastOutSlowIn,
      );
    }

    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        // color: Colors.green,
        child: Column(
          children: [
            SizedBox(
              height: 12.h,
            ),
            Container(
              height: 70.h,
              // color: Colors.red,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "KuroAi",
                      style: GoogleFonts.prompt(
                          color: Colors.white,
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w400),
                    ),
                    // IconButton(onPressed: (){}, icon: Icon(Icons.m))
                    InkWell(
                      onTap: () {
                        // _chat.history.length,
                        setState(() {});
                      },
                      child: Image.asset(
                        'assets/imgs/menu.png',
                        height: 20.h,
                        width: 20.w,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: hasApiKey
                  ? (_loading
                      ? Center(
                          child: Container(
                            // color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            child: Lottie.asset('assets/imgs/ani.json'),
                          ),
                        )
                      : (_chat.history.toList().length == 0
                          ? !_isListening
                              ? (Center(
                                  child: Container(
                                      // color: Colors.white,
                                      width: 50.w,
                                      child: Image.asset('assets/imgs/int.gif')
                                      //Lottie.asset('assets/imgs/robo.json'),
                                      ),
                                ))
                              : Center(
                                  child: Container(
                                      // color: Colors.white,
                                      width: 60.w,
                                      height: 70.h,
                                      child:
                                          Image.asset('assets/imgs/stop1.gif')
                                      //Lottie.asset('assets/imgs/stop.json'),
                                      ),
                                )
                          : _isListening
                              ? Center(
                                  child: Container(
                                      // color: Colors.white,
                                      width: 60.w,
                                      height: 70.h,
                                      child: GestureDetector(
                                          onTap: () {
                                            _stopListening();
                                          },
                                          child: Image.asset(
                                              'assets/imgs/stop1.gif'))
                                      //Lottie.asset('assets/imgs/stop.json'),
                                      ),
                                )
                              : (ListView.builder(
                                  controller: _controller,
                                  itemCount: _chat.history.length,
                                  // scrollDirectio,
                                  // reverse: true,
                                  itemBuilder: (context, index) {
                                    final content =
                                        _chat.history.toList()[index];
                                    final text = content.parts
                                        .whereType<TextPart>()
                                        .map<String>((e) => e.text)
                                        .join('');
                                    // provider.result;
                                    return ResultScreen(
                                      isFromUser: content.role == 'user',
                                      text: text,
                                    );
                                  }))))
                  : ListView(
                      children: [Container()],
                    ),
            ),
            Container(
              height: 68.h,
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 1.h),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        // onChanged: (String value) {
                        //   _sendChatMessage(value);
                        // },
                        controller: _PromtController,
                        focusNode: _focusController,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        cursorColor: Colors.white60,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                            // prefixIcon: IconButton(
                            //   icon:
                            //       const Icon(Icons.photo, color: Colors.white),
                            //   onPressed: () {},
                            // ),
                            suffixIcon: IconButton(
                              icon: Icon(!_isListening ? Icons.mic : Icons.stop,
                                  color: Colors.white),
                              onPressed: () {
                                _isListening
                                    ? _stopListening()
                                    : _startListening();
                                // print("=======>>$_text");
                              },
                            ),
                            hintText: "Search",
                            hintStyle: TextStyle(color: Colors.white60),
                            fillColor: Color(0xff343338),
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.dg),
                              // borderSide: BorderSide(width: 1.w,color: Colors.white)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(35.dg),
                              // borderSide: BorderSide(color: Colors.white,width: 1.w),
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 15.w,
                    ),
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: Colors.white,
                      child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                              onPressed: () {
                                // print('=====>Prompt${_PromtController.text}');
                                if (_PromtController.text.isNotEmpty) {
                                  _sendChatMessage(_PromtController.text);
                                  _focusController.unfocus();
                                }
                              },
                              icon: _loading
                                  ? Icon(
                                      Icons.stop,
                                      size: 24.h,
                                    )
                                  : Icon(
                                      Icons.send,
                                      size: 24.h,
                                    ))),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
