import 'package:flutter/material.dart';
import 'package:meditrack/data/network/dto/response/profile_setup/mmg_level_response.dart';
import 'package:meditrack/log/app_logs.dart';
import '../../../../core/router/app_router.dart';
import 'mmg_level_card.dart';
import 'mmg_level_preview.dart';

class MMGLevelList extends StatefulWidget {
  final List<MMGLevelResponse> mmgLevelList;
  const MMGLevelList({super.key, required this.mmgLevelList});

  @override
  State<MMGLevelList> createState() => _MMGLevelListState();
}

class _MMGLevelListState extends State<MMGLevelList> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          leading: CloseButton(),
          title: Text("Select MMG Level"),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ListView.builder(
            itemCount: widget.mmgLevelList.length,
            itemBuilder: (context, index) {
              var item = widget.mmgLevelList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MMGLevelCard(
                  title: item.title,
                  description: item.description,
                  imageUrl: item.image,
                  isSelected: selectedIndex == index,
                  onPreview: () {
                    appLog("preview for index : $index |  ${item.title}");
                    _openLevelPreview();
                  },
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              );
            },
          ),
        ),

        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  AppRouter.pop(context, argument: selectedIndex);
                },
                child: Text('CONTINUE'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openLevelPreview() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => MMGLevelPreview(),
    );
  }
}
