import 'package:flutter/material.dart';
import 'package:meditrack/config/png_config.dart';
import 'package:meditrack/presentation/common_widgets/smart_image_view.dart';
import 'package:meditrack/presentation/common_widgets/spacing_widgets.dart';

class MMGLevelPreview extends StatelessWidget {
  const MMGLevelPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: CloseButton(),
        title: Text('MMG-2.0 Preview'),
      ),

      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          VerticalSpacing.medium,
          Text('Basic split for beginners to Strength Training; ', style: Theme.of(context).textTheme.bodyLarge,),
          VerticalSpacing.small,
          Text(
            'Minor variation of MMG Split 3.1 (most popular) – Rear Shoulders also on Push Day; So, all Shoulder muscles on Push Day with Chest ',
          ),
          VerticalSpacing.medium,
          Text("Upper Body", style: Theme.of(context).textTheme.titleSmall,),
          VerticalSpacing.small,
          GridView.builder(
            itemCount: 3,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 160,
              crossAxisSpacing: 15,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).secondaryHeaderColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SmartImageView(
                      PngImageId.chest.path,
                      height: 62,
                      width: 62,
                    ),
                    Text(
                      "Chest, Front & Lateral Deltoids",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
