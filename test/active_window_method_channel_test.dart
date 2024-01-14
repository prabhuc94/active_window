import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:active_window/active_window_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelActiveWindow platform = MethodChannelActiveWindow();
  const MethodChannel channel = MethodChannel('active_window');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getActiveWindow', () async {
    expect(await platform.getActiveWindow(), '42');
  });
}
