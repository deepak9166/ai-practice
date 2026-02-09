import 'package:flutter/material.dart';

class RichTextTitle extends StatelessWidget {
  final String title1;
  final String title2;
  final String description;
  const RichTextTitle({
    super.key,
    required this.description,
    required this.title1,
    required this.title2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.displaySmall,
              //  style: Theme.of(context).textTheme.displaySmall,
              children: [
                TextSpan(text: title1),
                TextSpan(
                  text: title2,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ),

        Text(description, style: Theme.of(context).textTheme.bodyLarge,),
      ],
    );
  }
}
