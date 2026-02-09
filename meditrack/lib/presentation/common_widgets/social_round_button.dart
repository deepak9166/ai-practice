import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

class SocialRoundButton extends StatelessWidget {
  final String path;
  final Function()? onPressed;
  const SocialRoundButton({super.key, required this.path, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      
      child: OutlinedButton(
        style:OutlinedButton.styleFrom(
          padding: EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30),)
          
        ) ,
        onPressed: onPressed, child: SmartImageView(path, width: 24,height: 24,)),
    );
  }
}