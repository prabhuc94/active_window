import 'dart:async';
import 'package:active_window/active_window_info.dart';
import 'package:active_window/active_window_platform_interface.dart';

class AutoActiveWindowInfo {
  Timer? _timer;

  bool get isActive => _timer?.isActive ?? false;
  ActiveWindowInfo? _lastActiveWindow;

  late StreamController<ActiveWindowInfo?> _windowObserver;
  Stream<ActiveWindowInfo?> get windowStream => _windowObserver.stream;


  AutoActiveWindowInfo() {
    _windowObserver = StreamController.broadcast(sync: true);
  }

  Future<void> startService({int intervalSeconds = 5}) async {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      final value = await ActiveWindowPlatform.instance.getActiveWindow();
      _loadData(value);
    });
  }

  void _loadData(ActiveWindowInfo? info) {
    _lastActiveWindow ??= info;
    if (_windowObserver.isClosed) {
      print("Controller has been closed");
      return;
    }
    if (_lastActiveWindow?.title != info?.title || _lastActiveWindow?.appName != info?.appName) {
      _lastActiveWindow = info;
      _windowObserver.add(info);
    }
  }

  void stop() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _windowObserver.close();
  }
}