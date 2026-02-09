import 'package:flutter/material.dart';
import 'package:meditrack/config/svg_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';

class EditImageCardWidget extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onEditTap;

  const EditImageCardWidget({
    super.key,
    required this.title,
    required this.imageUrl,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: InkWell(
        onTap: onEditTap,
        child: Row(
          children: [
            SmartImageView(imageUrl, width: 50, height: 50),
            const SizedBox(width: 12),
            SmartImageView(SvgImageId.edit.path, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
