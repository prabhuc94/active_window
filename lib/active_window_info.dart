import 'dart:convert';

class ActiveWindowInfo {
  String title;
  String? appName;
  String? path;
  String? bundleId;
  String? rawResult;
  String? userName;
  String? hostName;
  String? deviceId;
  ActiveWindowInfo({
    required this.title,
    this.appName,
    this.path,
    this.bundleId,
    this.rawResult,
    this.userName,
    this.hostName,
    this.deviceId,
  });

  ActiveWindowInfo copyWith({
    String? title,
    String? appName,
    String? path,
    String? bundleId,
    String? rawResult,
    String? userName,
    String? hostName,
    String? deviceId,
  }) {
    return ActiveWindowInfo(
      title: title ?? this.title,
      appName: appName ?? this.appName,
      path: path ?? this.path,
      bundleId: bundleId ?? this.bundleId,
      rawResult: rawResult ?? this.rawResult,
      userName: userName ?? this.userName,
      hostName: hostName ?? this.hostName,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'appName': appName,
      'path': path,
      'bundleId': bundleId,
      'rawResult': rawResult,
      'userName': userName,
      'hostName': hostName,
      'deviceId': deviceId,
    };
  }

  factory ActiveWindowInfo.fromMap(Map<String, dynamic> map) {
    return ActiveWindowInfo(
      title: map['title'],
      appName: map['appName'],
      path: map['path'],
      bundleId: map['bundleId'],
      rawResult: map['rawResult'],
      userName: map['userName'],
      hostName: map['hostName'],
      deviceId: map['deviceId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ActiveWindowInfo.fromJson(String source) => ActiveWindowInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'WindowInfo(title: $title, appName: $appName, path: $path, bundleId: $bundleId, userName: $userName, hostName: $hostName, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ActiveWindowInfo &&
        other.title == title &&
        other.appName == appName &&
        other.path == path &&
        other.bundleId == bundleId &&
        // other.rawResult == rawResult &&
        other.userName == userName &&
        other.hostName == hostName &&
        other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        appName.hashCode ^
        path.hashCode ^
        bundleId.hashCode ^
        // rawResult.hashCode ^
        userName.hashCode ^
        hostName.hashCode ^
        deviceId.hashCode;
  }
}
