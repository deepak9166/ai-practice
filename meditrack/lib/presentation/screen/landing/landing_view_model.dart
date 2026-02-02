import 'package:meditrack/presentation/providers/local_storage_provider.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';

import '../base/screen_state.dart';

class LandingViewModel extends BaseViewModel {
  final AuthState _authState;

  LandingViewModel(this._authState);

   AuthState get authState =>  _authState;

  callApi() async {
    changeScreenState(ScreenState.apiProgress);
    await Future.delayed(Duration(seconds: 4));
    changeScreenState(ScreenState.content);
  }
}
