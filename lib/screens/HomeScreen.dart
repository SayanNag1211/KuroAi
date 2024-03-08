import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myapp/Services/PromptServices.dart';
import 'package:myapp/screens/ResultData.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
  bool _loading=false;

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
  TextEditingController _PromtController=TextEditingController();
  FocusNode _focusController=FocusNode();
  final provider=Provider.of<PromtService>(context);
  bool hasApiKey = dotenv.env['API_KEY'] != null && dotenv.env['API_KEY']!.isNotEmpty;
  ScrollController _scrollcontroller=ScrollController();
  late final ChatSession _chat;
  late final GenerativeModel _model;

  void initState(){
     _model = GenerativeModel(model: "gemini-pro", apiKey: dotenv.env['ApiKey']!);
    _chat = _model.startChat();
    super.initState();
  }
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
      setState(() => _loading = false);
    }
  }

    return Scaffold(
      body: Container(
            height:double.maxFinite,
            width: double.maxFinite,
            // color: Colors.green,
            child: Column(
              children: [
                Container(
                  height: 110.h,
                  // color: Colors.red,
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical:16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("KuroAi",
                        style: GoogleFonts.prompt(
                          color: Colors.white,fontSize: 21.sp,fontWeight: FontWeight.w400)
                        ,),
                        // IconButton(onPressed: (){}, icon: Icon(Icons.m))
                        InkWell(
                          onTap: (){},
                        
                          child: Image.asset('assets/imgs/menu.png',
                          height: 20.h,width: 20.w,color: Colors.white,),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child:hasApiKey?ListView.builder(
                    controller: _scrollcontroller,
                    itemCount:  _chat.history.length,
                    itemBuilder: (context,index){
                    final content = _chat.history.toList()[index];
                    final text = content.parts.whereType<TextPart>().map<String>((e) => e.text).join('');
                    // provider.result;
                      return ResultScreen(isFromUser: content.role=='You', text: text,);
                    }
                ) :
                ListView(
                  children: [
                    Container(color: Colors.red,)
                  ],
                ),
                ),
                Container(
                    height: 120.h,
                    // color: Colors.blue,
                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical:16.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onSubmitted: (String value) {
                                 _sendChatMessage(value);
                              },
                              controller: _PromtController,
                              focusNode: _focusController,
                              style: TextStyle(color: Colors.white,),
                              
                              cursorColor: Colors.white60,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.search,
                              decoration:InputDecoration(
                              prefixIcon: IconButton(icon:Icon(Icons.photo,color: Colors.white),
                              onPressed: (){
                                
                              },),
                              suffixIcon: IconButton(icon:Icon(Icons.mic,color: Colors.white),
                               onPressed: () {

                               },),
                                hintText: "Search",
                                hintStyle: TextStyle(color: Colors.white60),
                                fillColor: Color(0xff343338),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.dg),
                                  // borderSide: BorderSide(width: 1.w,color: Colors.white)
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(35.dg),
                                  // borderSide: BorderSide(color: Colors.white,width: 1.w),
                                )
                                
                              ),
                              
                            ),
                          ),
                          SizedBox(width: 15.w,),
                          CircleAvatar(
                            radius: 25.r,
                            child: Center(
                            child: IconButton(onPressed: (){
                            _sendChatMessage(_PromtController.text);
                  
                            provider.promtFetch(_PromtController.text);
                            _focusController.unfocus();
                            },
                             icon: Icon(Icons.send,size: 28.h,)
                        )),)
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
