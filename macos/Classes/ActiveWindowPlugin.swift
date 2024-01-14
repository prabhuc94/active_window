import Cocoa
import FlutterMacOS

public class ActiveWindowPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "active_window", binaryMessenger: registrar.messenger)
    let instance = ActiveWindowPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getActiveWindowInfo":
          let r = getWindowInfo()
          result(r);
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
