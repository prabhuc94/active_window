import 'package:active_window/active_window_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:active_window/active_window.dart';
import 'package:active_window/active_window_platform_interface.dart';
import 'package:active_window/active_window_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockActiveWindowPlatform
    with MockPlatformInterfaceMixin
    implements ActiveWindowPlatform {

  @override
  Future<ActiveWindowInfo?> getActiveWindow() => Future.value(ActiveWindowInfo(title: ""));
}

void main() {
  final ActiveWindowPlatform initialPlatform = ActiveWindowPlatform.instance;

  test('$MethodChannelActiveWindow is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelActiveWindow>());
  });

  test('getActiveWindow', () async {
    ActiveWindow activeWindowPlugin = ActiveWindow();
    MockActiveWindowPlatform fakePlatform = MockActiveWindowPlatform();
    ActiveWindowPlatform.instance = fakePlatform;

    expect(await activeWindowPlugin.getActiveWindow(), ActiveWindowInfo(title: ""));
  });
}
