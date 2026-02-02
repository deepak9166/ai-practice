import 'package:flutter/cupertino.dart';

import '../../../../config/png_config.dart';
import '../../../../data/network/dto/response/profile_setup/mmg_level_response.dart';
import '../../base/base_view_model.dart';

class MmgLevelViewModel extends BaseViewModel {
  List<MMGLevelResponse> mmgLevelList = [
    MMGLevelResponse(title: 'MMG-2.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-3.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-4.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-5.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-6.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
        MMGLevelResponse(title: 'MMG-2.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-3.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-4.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-5.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-6.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
        MMGLevelResponse(title: 'MMG-2.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-3.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-4.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-5.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
    MMGLevelResponse(title: 'MMG-6.0', description: 'Upper Body, Lower Body', image: PngImageId.yoga.path),
  ];

  ValueNotifier<int> selectItemIndex = ValueNotifier(-1);
}
