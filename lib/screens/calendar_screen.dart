import 'package:flutter/material.dart';
import 'package:instasmart/models/reminder_data.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/reminder_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instasmart/models/login_functions.dart';
import 'package:provider/provider.dart';
import 'package:instasmart/models/reminder.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events = {};
  List _selectedEvents = [];
  DateTime currTime = DateTime.now();
  AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();

    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    _selectedEvents =
        _events[DateTime(currTime.year, currTime.month, currTime.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseFunctions>(context);
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('Users/${firebase.currUser.uid}/reminders')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildTableCalendar();
            } else {
              return Scaffold(
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    FutureBuilder<List<Reminder>>(
                        future: ReminderData().getAllReminders(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Reminder>> snapshot) {
                          if (!snapshot.hasData) {
                            return _buildTableCalendar();
                          } else {
                            _events = {};
                            for (var reminder in snapshot.data) {
                              int day = reminder.postTime.day;
                              int month = reminder.postTime.month;
                              int year = reminder.postTime.year;
                              try {
                                _events[DateTime(year, month, day)]
                                    .add(reminder);
                              } catch (e) {
                                _events[DateTime(year, month, day)] = [];
                                _events[DateTime(year, month, day)]
                                    .add(reminder);
                              }
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                _buildTableCalendar(),
                              ],
                            );
                          }
                        }),
                    const SizedBox(height: 16.0),
                    FutureBuilder(
                        future: ReminderData().getAllReminders(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Reminder>> snapshot) {
                          return Expanded(child: _buildEventList());
                        })
                  ],
                ),
              );
            }
          }),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepPurple,
        todayColor: Colors.deepPurple[200],
        markersColor: Colors.black,
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildEventList() {
    print('building events');
    return ReminderList(selectedEvents: _selectedEvents);
  }
}
