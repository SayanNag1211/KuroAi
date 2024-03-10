import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ignore: must_be_immutable
class ResultScreen extends StatefulWidget {
  final String text;
  final bool isFromUser;
  ResultScreen({super.key, required this.isFromUser, required this.text});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // bool iconChg = false;

  final FlutterTts flutterTts = FlutterTts();

  void _Speaktext(String quote) async {
    await flutterTts.setLanguage('en-IN');
    await flutterTts.setPitch(1);
    await flutterTts.speak(
      quote,
    );
    // flutterTts.setCompletionHandler(() {
    //   setState(() {
    //     iconChg = true;
    //   });
    // });
    // await flutterTts.awaitSpeakCompletion(true);
    // setState(() {
    //   iconChg = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final provider=Provider.of<PromtService>(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: widget.isFromUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  // color: Colors.transparent,

                  color: widget.isFromUser
                      ? Color(0xff343338)
                      //Theme.of(context).colorScheme.primaryContainer
                      : Colors
                          .transparent, //Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(widget.isFromUser ? 10.dg : 18.dg),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: 15.h,
                  horizontal: 20.w,
                ),
                margin: EdgeInsets.only(bottom: 8.h),
                child: MarkdownBody(
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    code: GoogleFonts.prompt(
                      fontSize: 13.sp,
                      color: Colors.black,
                    ),
                    tableBody: GoogleFonts.prompt(
                        fontSize: 13.sp, color: Colors.white),
                    p: GoogleFonts.prompt(
                        fontSize: 13.sp,
                        color: Colors.white), // Change the default text color
                    a: GoogleFonts.prompt(fontSize: 13.sp, color: Colors.white),
                  ),
                  selectable: true,
                  data: widget.text,
                ),
              ),
            ),
          ],
        ),
        !widget.isFromUser
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.multitrack_audio_sharp,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    onPressed: () {
                      _Speaktext(widget.text);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 28.r, left: 5.w),
                    child: IconButton(
                      icon: Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.text.toString()));
                        Fluttertoast.showToast(
                            msg: 'Copied text!',
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Color(0xff343338));
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ],
    );
  }
}
