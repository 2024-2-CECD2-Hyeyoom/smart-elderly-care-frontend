// lib/models/outing_detail.dart

class OutingDetail {
  final String date; // yyyy-MM-dd
  final List<OutingEvent> events;

  OutingDetail({required this.date, required this.events});

  factory OutingDetail.fromJson(Map<String, dynamic> json) {
    return OutingDetail(
      date: json['date'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => OutingEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OutingEvent {
  final String timestamp;
  final int status;

  OutingEvent({required this.timestamp, required this.status});

  factory OutingEvent.fromJson(Map<String, dynamic> json) {
    return OutingEvent(
      timestamp: json['timestamp'] as String,
      status: json['status'] as int,
    );
  }
}
