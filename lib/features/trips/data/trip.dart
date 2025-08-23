import 'package:isar/isar.dart';
part 'trip.g.dart';

@collection
class Trip {
  Id id = Isar.autoIncrement; // auto-increment primary key

  late String title;
  late DateTime startDate;
  late DateTime endDate;

  late List<TripDay> days;

  Trip();

  // JSON factory
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip()
      ..title = json['title']
      ..startDate = DateTime.parse(json['startDate'])
      ..endDate = DateTime.parse(json['endDate'])
      ..days = (json['days'] as List)
          .map((d) => TripDay.fromJson(d))
          .toList();
  }
}

@embedded
class TripDay {
  late DateTime date;
  late String summary;
  late List<TripItem> items;

  TripDay();

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay()
      ..date = DateTime.parse(json['date'])
      ..summary = json['summary']
      ..items = (json['items'] as List)
          .map((i) => TripItem.fromJson(i))
          .toList();
  }
}

@embedded
class TripItem {
  late String time;
  late String activity;
  late String location;

  TripItem();

  factory TripItem.fromJson(Map<String, dynamic> json) {
    return TripItem()
      ..time = json['time']
      ..activity = json['activity']
      ..location = json['location'];
  }
}
