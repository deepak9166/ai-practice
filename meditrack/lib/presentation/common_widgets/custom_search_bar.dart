import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

class CustomSearchBarView extends StatefulWidget {
  final String hintText;
  final Function()? onPressed;
  
  const CustomSearchBarView({super.key, required this.hintText, required this.onPressed});

  @override
  State<CustomSearchBarView> createState() => _CustomSearchBarViewState();
}

class _CustomSearchBarViewState extends State<CustomSearchBarView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            Expanded(child: TextField(
              controller: TextEditingController(),
              autofocus: false,
              decoration: InputDecoration(
              
                hintText: widget.hintText
              ),
            )),
            SizedBox(width: 5),
            SizedBox(
              height: 54,
              width: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:widget.onPressed,
                child: SmartImageView(
                  SvgImageId.search.path,
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
