import AppKit

@discardableResult
func runAppleScript(source: String) -> String? {
	NSAppleScript(source: source)?.executeAndReturnError(nil).stringValue
}


func toJson<T>(_ data: T) throws -> String {
	let json = try JSONSerialization.data(withJSONObject: data)
	return String(data: json, encoding: .utf8)!
}


// Show the system prompt if there's no permission.
func hasScreenRecordingPermission() -> Bool {
	CGDisplayStream(
		dispatchQueueDisplay: CGMainDisplayID(),
		outputWidth: 1,
		outputHeight: 1,
		pixelFormat: Int32(kCVPixelFormatType_32BGRA),
		properties: nil,
		queue: DispatchQueue.global(),
		handler: { _, _, _, _ in }
	) != nil
}



func getWindowInfo() -> String? {
  let disableScreenRecordingPermission = CommandLine.arguments.contains("--no-screen-recording-permission")

// Show accessibility permission prompt if needed. Required to get the complete window title.
if !AXIsProcessTrustedWithOptions(["AXTrustedCheckOptionPrompt": true] as CFDictionary) {
	print("active-win requires the accessibility permission in “System Preferences › Security & Privacy › Privacy › Accessibility”.")
	return nil
}

// Show screen recording permission prompt if needed. Required to get the complete window title.
if !disableScreenRecordingPermission && !hasScreenRecordingPermission() {
	print("active-win requires the screen recording permission in “System Preferences › Security & Privacy › Privacy › Screen Recording”.")
	return nil
}

guard
	let frontmostAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier,
	let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]]
else {
	return nil
}

for window in windows {
	let windowOwnerPID = window[kCGWindowOwnerPID as String] as! pid_t // Documented to always exist.
	if windowOwnerPID != frontmostAppPID {
		continue
	}

	// Skip transparent windows, like with Chrome.
	if (window[kCGWindowAlpha as String] as! Double) == 0 { // Documented to always exist.
		continue
	}

	// This should not fail as we're only dealing with apps, but we guard it just to be safe.
	guard let app = NSRunningApplication(processIdentifier: windowOwnerPID) else {
		continue
	}

	let appName = window[kCGWindowOwnerName as String] as? String ?? app.bundleIdentifier ?? "<Unknown>"

	let windowTitle = disableScreenRecordingPermission ? "" : window[kCGWindowName as String] as? String ?? ""

	let output: [String: Any] = [
		"title": windowTitle,
		"id": window[kCGWindowNumber as String] as! Int, 
		"appName": appName,
		"processId": windowOwnerPID,
		"bundleId": app.bundleIdentifier ?? ""
		]

	let string = try? toJson(output) 

	return string
}
return nil
}