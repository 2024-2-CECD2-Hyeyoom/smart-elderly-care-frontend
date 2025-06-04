// lib/models/sleep_detail.dart

class SleepDetail {
  final String date; // yyyy-MM-dd
  final List<SleepEvent> events;

  SleepDetail({required this.date, required this.events});

  factory SleepDetail.fromJson(Map<String, dynamic> json) {
    return SleepDetail(
      date: json['date'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => SleepEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SleepEvent {
  final String timestamp; // yyyy-MM-dd hh:mm
  final int status; // 0 or 1

  SleepEvent({required this.timestamp, required this.status});

  factory SleepEvent.fromJson(Map<String, dynamic> json) {
    return SleepEvent(
      timestamp: json['timestamp'] as String,
      status: json['status'] as int,
    );
  }
}
