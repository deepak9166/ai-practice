import 'package:flutter/cupertino.dart';

extension KeyboardHideExtesion on BuildContext {
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
