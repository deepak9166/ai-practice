import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

class PreviewImages extends StatelessWidget {
  final List<String> images;
  final double? size;
  const PreviewImages({super.key, required this.images, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < images.length; i++)
          Positioned(
            child: Padding(
              padding: EdgeInsets.only(left: i * 12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SmartImageView(
                  images[i],
                  height: size,
                  width: size,
                  radius: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
