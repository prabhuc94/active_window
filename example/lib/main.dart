import 'package:active_window/active_window_info.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:active_window/active_window.dart';
import 'package:active_window/auto_active_window.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ActiveWindowInfo? _platformVersion;
  final _activeWindowPlugin = ActiveWindow();
  final _autoActiveWindow = AutoActiveWindowInfo();

  @override
  void initState() {
    super.initState();
    _autoActiveWindow.startService();
    _autoActiveWindow.windowStream.listen((event) {
      print("ACTIVE-WINDOW: ${event?.toJson()}");
    });
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    ActiveWindowInfo? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _activeWindowPlugin.getActiveWindow();
    } on PlatformException {
      platformVersion = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: StreamBuilder(stream: _autoActiveWindow.windowStream, builder: (_, snapshot) => Center(
          child: Text.rich(TextSpan(
            text: "${snapshot.data?.title}\n",
            style: Theme.of(context).textTheme.labelMedium,
            children: [
              TextSpan(
                text: "${snapshot.data?.appName}",
                style: Theme.of(context).textTheme.labelSmall
              )
            ]
          )),
        ),),
      ),
    );
  }
}
