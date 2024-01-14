import 'dart:convert';
import 'dart:io';

import 'package:active_window/active_window_error.dart';
import 'package:active_window/active_window_info.dart';
import 'package:active_window/extensions.dart';
import 'package:active_window/window_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'active_window_platform_interface.dart';

/// An implementation of [ActiveWindowPlatform] that uses method channels.
class MethodChannelActiveWindow extends ActiveWindowPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('active_window');

  @override
  Future<ActiveWindowInfo?> getActiveWindow() async {
    final rawResult = await methodChannel.invokeMethod('getActiveWindowInfo');
    ActiveWindowInfo? info;
    if (Platform.isWindows) {
      info = fromWindows(rawResult);
    } else {
      info = fromString(rawResult as String?);
    }
    if (info == null || info.title.isEmpty == true) {
      return null;
    } else {
      info.hostName = Platform.localHostname;
      return info;
    }
  }

  static ActiveWindowInfo? fromString(String? windowInfo) {
    if (windowInfo == null || windowInfo.isEmpty) {
      return null;
    }
    ActiveWindowInfo result;
    if (Platform.isMacOS) {
      result = ActiveWindowInfo.fromJson(windowInfo);
      result.userName = Platform.environment['LOGNAME'];
    } else if (Platform.isWindows) {
      throw ActiveWindowError(number: 0, message: 'This could not happen!');
    } else {
      result = fromLinuxString(windowInfo);
    }
    result.rawResult = windowInfo;
    return result;
  }

  static ActiveWindowInfo fromLinuxString(String map) {
    final values = map.split('\n');
    final wmClass = _getValue(values, 'WM_CLASS', split: ',');
    return ActiveWindowInfo(
      title: _getValue(values, 'WM_NAME(')!,
      bundleId: _getValue(values, '_GTK_APPLICATION_ID(UTF8_STRING)') ?? wmClass,
      appName: wmClass,
      userName: Platform.environment['USER'],
    );
  }

  static ActiveWindowInfo fromWindows(dynamic rawResult) {
    final result = WindowsResult.fromJson(json.encode(rawResult));
    return ActiveWindowInfo(
      title: result.title ?? 'ERROR',
      bundleId: result.exe,
      appName: result.name,
      userName: Platform.environment['USERNAME'],
    );
  }

  static String? _getValue(List<String> values, String key, {String? split}) {
    final line = values.firstWhereOrNull((element) => element.startsWith(key));
    final lineValues = line?.split('=');
    String? result;
    if (lineValues != null && lineValues.length > 1) {
      result = lineValues[1].replaceAll('"', '');

      if (split != null) {
        final parts = result.split(split);
        result = parts.length > 1 ? parts[1] : parts[0];
      }
    }
    return result?.trim();
  }
}
