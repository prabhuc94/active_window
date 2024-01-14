import 'package:active_window/active_window_info.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'active_window_method_channel.dart';

abstract class ActiveWindowPlatform extends PlatformInterface {
  /// Constructs a ActiveWindowPlatform.
  ActiveWindowPlatform() : super(token: _token);

  static final Object _token = Object();

  static ActiveWindowPlatform _instance = MethodChannelActiveWindow();

  /// The default instance of [ActiveWindowPlatform] to use.
  ///
  /// Defaults to [MethodChannelActiveWindow].
  static ActiveWindowPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ActiveWindowPlatform] when
  /// they register themselves.
  static set instance(ActiveWindowPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<ActiveWindowInfo?> getActiveWindow() {
    throw UnimplementedError('getActiveWindow() has not been implemented.');
  }
}
