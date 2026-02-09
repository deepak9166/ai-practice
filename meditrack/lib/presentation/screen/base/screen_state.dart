// class ScreenState {
//   ScreenState._();

//   static const none = -1;
//   static const progress = 0;

//   static const content = 1;
//   static const empty = 2;
//   static const error = 3;
//   static const apiProgress = 4;
//   static const action = 6;
//   static const noInternet = 7;
//   static const refresh = 8;
// }

enum ScreenState {
  none,
  progress, // Full screen loading (initial)
  apiProgress, // In-place loading (e.g. pull-to-refresh or button action)
  content,
  empty,
  error,
  noInternet,
  refresh, // Same as content but triggers callback
  action, // User-triggered action (e.g. button press)
}
