import 'dart:convert';

class ActiveWindowError extends Error {
  int number = 0;
  String message;  
  ActiveWindowError({
    required this.number,
    required this.message,
  });

  ActiveWindowError copyWith({
    int? number,
    String? message,
  }) {
    return ActiveWindowError(
      number: number ?? this.number,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'message': message,
    };
  }

  factory ActiveWindowError.fromMap(Map<String, dynamic> map) {
    return ActiveWindowError(
      number: map['number'],
      message: map['message'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ActiveWindowError.fromJson(String source) => ActiveWindowError.fromMap(json.decode(source));

  @override
  String toString() => 'ActiveWindowError(number: $number, message: $message)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ActiveWindowError &&
      other.number == number &&
      other.message == message;
  }

  @override
  int get hashCode => number.hashCode ^ message.hashCode;
}
