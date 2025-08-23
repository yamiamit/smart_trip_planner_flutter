class ItineraryItem {
  final String activity;
  final String location; // "lat,lng"
  final String time;
  ItineraryItem({required this.time, required this.activity, required this.location});
  factory ItineraryItem.fromJson(Map<String, dynamic> j) => ItineraryItem(
    time: j['time'] ?? '',
    activity: j['activity'] ?? '',
    location: j['location'] ?? '',
  );
  Map<String, dynamic> toJson() => {'time': time, 'activity': activity, 'location': location};
}


class ItineraryDay {
  final String date; // YYYY-MM-DD
  final String summary;
  final List<ItineraryItem> items;
  ItineraryDay({required this.date, required this.summary, required this.items});
  factory ItineraryDay.fromJson(Map<String, dynamic> j) => ItineraryDay(
    date: j['date'] ?? '',
    summary: j['summary'] ?? '',
    items: ((j['items'] ?? []) as List).map((e) => ItineraryItem.fromJson(e)).toList(),
  );
  Map<String, dynamic> toJson() => {
    'date': date,
    'summary': summary,
    'items': items.map((e) => e.toJson()).toList(),
  };
}


class Itinerary {
  final String title;
  final String startDate;
  final String endDate;
  final List<ItineraryDay> days;
  Itinerary({required this.title, required this.startDate, required this.endDate, required this.days});
  factory Itinerary.fromJson(Map<String, dynamic> j) => Itinerary(
    title: j['title'] ?? '',
    startDate: j['startDate'] ?? '',
    endDate: j['endDate'] ?? '',
    days: ((j['days'] ?? []) as List).map((e) => ItineraryDay.fromJson(e)).toList(),
  );
  Map<String, dynamic> toJson() => {
    'title': title,
    'startDate': startDate,
    'endDate': endDate,
    'days': days.map((d) => d.toJson()).toList(),
  };
}