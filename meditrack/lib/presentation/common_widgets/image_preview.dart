import 'package:flutter/material.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

class ImagePreview extends StatelessWidget {
  final String imageUrl;
  const ImagePreview({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CloseButton(), title: Text('Image Preview')),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SmartImageView(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
