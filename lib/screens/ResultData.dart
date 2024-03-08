import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myapp/Services/PromptServices.dart';
import 'package:provider/provider.dart';

class ResultScreen extends StatelessWidget {
   final String text;
  final bool isFromUser;
  ResultScreen({super.key,required this.isFromUser,required this.text});

  @override
  Widget build(BuildContext context) {
      final provider=Provider.of<PromtService>(context);

    return  Row(
      mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Colors.red//Theme.of(context).colorScheme.primaryContainer
                  : Colors.green,//Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: MarkdownBody(
              selectable: true,
              data:text,
            ),
          ),
        ),
      ],
    );
  }
}