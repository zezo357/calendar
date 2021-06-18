import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class TableEventsExample extends StatefulWidget {
  @override
  _TableEventsExampleState createState() => _TableEventsExampleState();
}

class _TableEventsExampleState extends State<TableEventsExample> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  TextEditingController eventText=TextEditingController();
  TextEditingController eventPriority=TextEditingController();
  TextEditingController eventTimeRequired=TextEditingController();

  @override
  void initState() {
    super.initState();
    createEvents(200);
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        //print("selectedDay"+selectedDay.toString());
        //print("focusedDay"+focusedDay.toString());
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }
  static const List<String> popMenuOptionsSearchOptions=[
    "Sort using priority",
    "Sort using time",
    "Sort using time Required",
    "Get month events"
  ];
  List<Event> priority(List<Event> events) {
    events.sort((a, b) => (a.priority).compareTo(b.priority));
    return events.reversed.toList();
    }

  List<Event> dueDate(List<Event> events) {
    events.sort((a, b) => (a.dueDate).compareTo(b.dueDate));
    return events;
  }
  List<Event> timeRequired(List<Event> events) {
    events.sort((a, b) => (a.timeRequired).compareTo(b.timeRequired));
    return events;
  }
  Future<void> addEventAtDay() async {
    await showDialog(builder: (context) => new Dialog(
      backgroundColor: Colors.blueGrey[100],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(15)

        ),
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(5),
                child: TextFormField(
                    controller: eventText,
                    autovalidateMode: AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: "Event Name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                    )
                )
            ),
            Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(5),
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: eventPriority,

                    autovalidateMode: AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: "Event Priority",

                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                    )
                )
            ),
            Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(5),
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: eventTimeRequired,

                    autovalidateMode: AutovalidateMode.disabled,
                    decoration: InputDecoration(
                      labelText: "Event Time Required",

                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      focusedBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                    )
                )
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black54, // background
                onPrimary: Colors.white, // foreground
              ),
              child: Text("Add"),
              onPressed: (){

                Navigator.pop(context);
                setState(() {
                  addEvent(_focusedDay, Event(eventText.text,_focusedDay,int.parse(eventTimeRequired.text ),priority: int.parse(eventPriority.text )));
                  _selectedEvents.value = _getEventsForDay(_focusedDay);
                });
                eventText.text="";
                eventPriority.text="";
              },
            )
          ],
        ),
      ),

    ), context: context);
  }
  void popUpMenuSelectionSearchSort(String selection){
    switch(selection){
      case "Sort using priority":
        setState(() {
        _selectedEvents.value=priority(_selectedEvents.value);
        });
        int timeRequired=0;
        _selectedEvents.value.forEach((element) {timeRequired+=element.timeRequired; });
        showDialog(builder: (context) => new Dialog(
          backgroundColor: Colors.blueGrey[100],
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(15)
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(5),
              child: Text("Average time required: ${(timeRequired/_selectedEvents.value.length).toStringAsFixed(2)}",style: TextStyle(fontSize:20 ),),
            ),
          ),

        ), context: context);
        break;
      case "Sort using Due Date":
        setState(() {
          _selectedEvents.value=dueDate(_selectedEvents.value);
        });

        break;
      case "Sort using time Required":
        setState(() {
          _selectedEvents.value=timeRequired(_selectedEvents.value);
        });
        break;
      case "Get month events":
        setState(() {
        DateTime start=DateTime.utc(_focusedDay.year,_focusedDay.month);
        DateTime end=DateTime.utc(_focusedDay.year,_focusedDay.month,30);
        _rangeStart = start;
        _rangeEnd = end;
        _selectedEvents.value = _getEventsForRange(start, end);
      });
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TableCalendar - Events'),
            PopupMenuButton<String>(
              color: Colors.black87,
              icon: Icon(
                Icons.sort,
                color: Colors.white,
                size: 30,
              ),
              onSelected: (String result) {
                popUpMenuSelectionSearchSort(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: popMenuOptionsSearchOptions[0],
                  child: Text(
                    popMenuOptionsSearchOptions[0],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                PopupMenuItem<String>(
                  value: popMenuOptionsSearchOptions[1],
                  child: Text(
                    popMenuOptionsSearchOptions[1],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                PopupMenuItem<String>(
                  value: popMenuOptionsSearchOptions[2],
                  child: Text(
                    popMenuOptionsSearchOptions[2],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                PopupMenuItem<String>(
                  value: popMenuOptionsSearchOptions[3],
                  child: Text(
                    popMenuOptionsSearchOptions[3],
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),

      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
      ElevatedButton(
      style: ElevatedButton.styleFrom(
      primary: Colors.black54, // background
      onPrimary: Colors.white, // foreground
    ),
    child: Text("Add Event",
    style: TextStyle(color: Colors.white),),

        onPressed: () {addEventAtDay();

    }),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Column(
                          children: [
                            Text('${value[index].title}'),
                            Text('Priority: '+'${value[index].priority}'),
                            Text('DueDate: '+'${DateFormat("dd-MM-yyyy").format(value[index].dueDate)}'),
                            Text('Time Required: '+'${value[index].timeRequired} min'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}