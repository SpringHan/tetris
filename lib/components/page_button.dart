import 'package:flutter/material.dart';

class PageButton extends StatelessWidget {
  const PageButton({
      super.key,
      required this.content,
      required this.event,
  });

  final String content;
  final void Function() event;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      // style: ButtonStyle(
      // ),
      onPressed: event,
      child: Text(
        content,
        // style: TextStyle(
        // ),
      ),
    );
  }
}
