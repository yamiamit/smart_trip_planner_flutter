import '../../features/trips/domain/models.dart';


enum ChangeType { added, removed, modified, unchanged }
class DayChange { final ItineraryDay day; final ChangeType type; DayChange(this.day,this.type); }


List<DayChange> diffDays(Itinerary oldI, Itinerary newI) {
  final mapOld = {for (final d in oldI.days) d.date: d};
  final mapNew = {for (final d in newI.days) d.date: d};
  final out = <DayChange>[];
  final dates = {...mapOld.keys, ...mapNew.keys};
  for (final date in dates) {
    final o = mapOld[date];
    final n = mapNew[date];
    if (o == null && n != null) {
      out.add(DayChange(n, ChangeType.added));
    } else if (n == null && o != null) {
      out.add(DayChange(o, ChangeType.removed));
    } else if (o != null && n != null) {
      final changedSummary = o.summary != n.summary;
      final setOld = o.items.map((e) => '${e.time}|${e.activity}').toSet();
      final setNew = n.items.map((e) => '${e.time}|${e.activity}').toSet();
      final modified = changedSummary || setOld.symmetricDifference(setNew).isNotEmpty;
      out.add(DayChange(n, modified ? ChangeType.modified : ChangeType.unchanged));
    }
  }
  out.sort((a, b) => a.day.date.compareTo(b.day.date));
  return out;
}


extension<T> on Set<T> {
  Set<T> symmetricDifference(Set<T> other) => {...difference(other), ...other.difference(this)};
}