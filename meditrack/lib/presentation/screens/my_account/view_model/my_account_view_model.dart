import 'package:meditrack/presentation/providers/local_storage_provider.dart';
import 'package:meditrack/presentation/screen/base/base_view_model.dart';
import 'package:meditrack/presentation/common_model/dropdown_value_model.dart';

import '../../../screen/base/screen_state.dart';

class MyAccountViewModel extends BaseViewModel {
  final AuthState _authState;

  MyAccountViewModel(this._authState);

  AuthState get authState => _authState;

  // Profile editing state
  DateTime? _selectedDate;
  bool _isDobSelected = false;
  double _age = 22.0;
  DropdownValueModel? _selectedGender;
  DropdownValueModel? _selectedCountry;

  DateTime? get selectedDate => _selectedDate;
  bool get isDobSelected => _isDobSelected;
  double get age => _age;
  DropdownValueModel? get selectedGender => _selectedGender;
  DropdownValueModel? get selectedCountry => _selectedCountry;

  final List<DropdownValueModel> genderOptions = [
    DropdownValueModel(title: 'Male', value: 'male'),
    DropdownValueModel(title: 'Female', value: 'female'),
    DropdownValueModel(title: 'Other', value: 'other'),
  ];

  final List<DropdownValueModel> countryOptions = [
    DropdownValueModel(title: 'India', value: 'india'),
    DropdownValueModel(title: 'USA', value: 'usa'),
    DropdownValueModel(title: 'UK', value: 'uk'),
    // Add more countries as needed
  ];

  // Methods to update profile state
  void updateSelectedDate(DateTime? date) {
    _selectedDate = date;
    _isDobSelected = date != null;
    notifyListeners();
  }

  void updateAge(double age) {
    _age = age;
    notifyListeners();
  }

  void updateSelectedGender(DropdownValueModel? gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void updateSelectedCountry(DropdownValueModel? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void loadProfileData() {
    // For now, set dummy data
    _selectedDate = DateTime(2003, 10, 12);
    _isDobSelected = _selectedDate != null;
    _age = 22.0;
    _selectedGender = genderOptions[0];
    _selectedCountry = countryOptions[0];
    Future.microtask(() => notifyListeners());
  }

  callApi() async {
    changeScreenState(ScreenState.apiProgress);
    await Future.delayed(Duration(seconds: 4));

    changeScreenState(ScreenState.content);
  }

  /// Initialize the screen state to loading for static pages
  void initStaticPage() {
    changeScreenState(ScreenState.apiProgress);
  }

  /// Called when the webpage starts loading
  void onPageStarted(String url) {
    changeScreenState(ScreenState.apiProgress);
  }

  /// Called when the webpage finishes loading
  void onPageFinished(String url) {
    changeScreenState(ScreenState.content);
  }

  /// Send contact us message
  Future<void> sendContactUs({
    required String fullName,
    required String email,
    required String message,
    String? attachmentPath,
  }) async {
    changeScreenState(ScreenState.apiProgress);
    try {
      // TODO: Implement API call to send contact us
      await Future.delayed(Duration(seconds: 2)); // Simulate API call
      changeScreenState(ScreenState.content);
    } catch (e) {
      changeScreenState(ScreenState.error);
    }
  }
}
