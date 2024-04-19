const String tableTimers = 'timers';

class TimerFields {
  static const String id = 'id';
  static const String title = 'title';
  static const String description = 'description';
  static const String durationTime = 'durationTime';
}

class Timer {
  final int? id;
  final String title;
  final String description;
  final Duration durationTime;

  Timer(
      {this.id,
      required this.title,
      required this.description,
      required this.durationTime});

  Timer copy(
      {int? id, String? title, String? description, Duration? durationTime}) {
    return Timer(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        durationTime: durationTime ?? this.durationTime);
  }

  static Timer fromJson(Map<String, Object?> json) {
    return Timer(
      id: json[TimerFields.id] as int?,
      title: json[TimerFields.title] as String,
      description: json[TimerFields.description] as String,
      durationTime: Duration(seconds: json[TimerFields.durationTime] as int),
    );
  }

  Map<String, Object?> toJson() => {
        TimerFields.id: id,
        TimerFields.title: title,
        TimerFields.description: description,
        TimerFields.durationTime: durationTime.inSeconds,
      };
}
