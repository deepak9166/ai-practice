import 'package:flutter/material.dart';

class ActionButtonAppBar extends StatelessWidget {
  final String title;
  final Function()? onPressed;
  const ActionButtonAppBar({super.key, required this.title, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 23,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: onPressed,
            child: Text(title, style: Theme.of(context).textTheme.labelMedium),
          ),
        ),
      
      ],
    );
  }
}
