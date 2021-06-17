import 'dart:collection';
import 'dart:math';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String title;
  final int priority;
  final DateTime dueDate;

  const Event(this.title,this.dueDate,{this.priority=1});

  @override
  String toString() => title;
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(createEvents(200));
Map<DateTime, List<Event>> createEvents(int count){
  Map<DateTime, List<Event>> events= {};
  for(int i=0; i<count;i++){

    Random random = Random();
    DateTime key=DateTime.utc(DateTime.now().year,random.nextInt(12)+1,random.nextInt(28)+1);
    if(events.containsKey(key)){
      events[key]!.add(Event('Event: $i',key,priority: random.nextInt(50)+1));
    }else{
    events[key]=[Event('Event $i',key,priority: random.nextInt(50)+1)];
    }
  }
  return events;
}
/*
final _kEventSource = Map.fromIterable(List.generate(200, (index) => index),
    key: (item) => DateTime.utc(DateTime.now().year,1, item * 25),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}',priority: index + 1)))
  ..addAll({
    //DateTime.now(): [Event('Today\'s Event 1'), Event('Today\'s Event 2'),],
  });
*/
int getHashCode(DateTime key) {
  return key.day * 100000000 + key.month * 1000000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kNow = DateTime.now();
final kFirstDay = DateTime(kNow.year, 1, 1);
final kLastDay = DateTime(kNow.year, 12, 31);