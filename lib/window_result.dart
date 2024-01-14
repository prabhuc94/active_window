import 'dart:convert';

class WindowsResult {
  String? exe;
  String? name;
  String? title;
  WindowsResult({
    this.exe,
    this.name,
    this.title,
  });

  WindowsResult copyWith({
    String? exe,
    String? name,
    String? title,
  }) {
    return WindowsResult(
      exe: exe ?? this.exe,
      name: name ?? this.name,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exe': exe,
      'name': name,
      'title': title,
    };
  }

  factory WindowsResult.fromMap(Map<String, dynamic> map) {
    return WindowsResult(
      exe: map['exe'],
      name: map['name'],
      title: map['title'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WindowsResult.fromJson(String source) => WindowsResult.fromMap(json.decode(source));

  @override
  String toString() => '_WindowsResult(exe: $exe, name: $name, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WindowsResult && other.exe == exe && other.name == name && other.title == title;
  }

  @override
  int get hashCode => exe.hashCode ^ name.hashCode ^ title.hashCode;
}