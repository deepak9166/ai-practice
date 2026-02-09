import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

ErrorHandler parseException(dynamic error) {
  if (error is GoogleSignInException) {
    String messageStr = "Unknow Error";
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        messageStr = "Sign-in cancelled by user.";
        break;

      case GoogleSignInExceptionCode.uiUnavailable:
        messageStr = "Google sign-in is currently unavailable on this device.";
        break;

      case GoogleSignInExceptionCode.interrupted:
        messageStr = "Sign-in was interrupted. Please try again.";
        break;

      case GoogleSignInExceptionCode.userMismatch:
        messageStr =
            "This Google account doesn’t match the previously used account.";
        break;

      case GoogleSignInExceptionCode.clientConfigurationError:
        messageStr =
            "App configuration issue detected. Please contact support.";
        break;

      default:
        messageStr =
            "Something went wrong during Google sign-in. Please try again.";
    }
    return ErrorHandler(
      error: error,
      errorMessage: messageStr,
      statusCode: error.code.index,
    );
  } else if (error is MissingPluginException) {
    return ErrorHandler(
      error: null,
      errorMessage: error.message ?? "",
      statusCode: -1,
    );
  } else
    // TODO: Handle here all types of error
    return ErrorHandler(
      error: null,
      errorMessage: 'Unknow Error',
      statusCode: -1,
    );
}

class ErrorHandler {
  String errorMessage;
  dynamic error;
  int statusCode;

  ErrorHandler({
    required this.error,
    required this.errorMessage,
    required this.statusCode,
  });
}
