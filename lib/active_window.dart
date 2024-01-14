import 'package:active_window/active_window_info.dart';
import 'active_window_platform_interface.dart';

class ActiveWindow {
  Future<ActiveWindowInfo?> getActiveWindow() {
    return ActiveWindowPlatform.instance.getActiveWindow();
  }
}
