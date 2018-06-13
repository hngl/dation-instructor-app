import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:dation_app/dation_models.dart';
import 'package:dation_app/dation_ws_client.dart';
import 'package:dation_app/generic_pages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DationWsClient _client;

class AgendaPage extends StatefulWidget {
  AgendaPage(DationWsClient client) {
    _client = client;
  }

  @override
  _AgendaPageState createState() {
    return new _AgendaPageState(DateTime.now());
  }
}

class _AgendaPageState extends State<AgendaPage> {
  DateTime _date;

  _AgendaPageState(this._date);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_left),
                onPressed: _prevDay,
              ),
              Text(
                DateFormat('d MMMM y').format(_date),
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right),
                onPressed: _nextDay,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureEventListView(_date),
        )
      ],
    );
  }

  /// Flip to previous day
  void _prevDay() {
    setState(() {
      _date = _date.subtract(Duration(days: 1));
    });
  }

  /// Flip to next day
  void _nextDay() {
    setState(() {
      _date = _date.add(Duration(days: 1));
    });
  }
}

class FutureEventListView extends StatelessWidget {
  final DateTime _date;

  FutureEventListView(this._date);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _client.getAgendaOverview(
        instructor: Instructor(1),
        date: _date,
      ),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return PageLoadingError('Fout bij het ophalen van afspraken.');
        }

        if (!snapshot.hasData)
          // Shows progress indicator until the data is load.
          return PageLoadingIndicator('Afspraken ophalen...');

        List events = snapshot.data;

        return ListView(
          children: _buildEventSummaries(context, events),
        );
      },
    );
  }

  List<Widget> _buildEventSummaries(
      BuildContext context, List<AgendaEvent> events) {
    List<Widget> widgetList = List<Widget>();
    if (events != null) {
      for (var event in events) {
        if (event is Appointment) {
          widgetList.add(AppointmentSummary(event));
        }
        if (event is AgendaBlock) {
          widgetList.add(AgendaBlockSummary(event));
        }
      }
    }
    return widgetList;
  }
}

class AgendaBlockSummary extends StatelessWidget {
  final AgendaBlock event;

  AgendaBlockSummary(this.event);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        children: <Widget>[
          Text(DateFormat('HH:mm').format(event.start)),
          Text(DateFormat('HH:mm').format(event.end),
              style: TextStyle(color: Colors.black45)),
        ],
      ),
      title: Text('(vrij blok)'),
      trailing: Icon(Icons.add, color: Theme.of(context).primaryColor),
// TODO Implement proper editing
//              onTap: () {
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (BuildContext context) => AppointmentEditPage(
//                          Appointment(start: event.start, end: event.end),
//                        ),
//                  ),
//                );
//              },
    );
  }
}

class AppointmentSummary extends StatelessWidget {
  final Appointment event;

  AppointmentSummary(this.event);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(children: <Widget>[
        Text(DateFormat('HH:mm').format(event.start)),
        Text(DateFormat('HH:mm').format(event.end),
            style: TextStyle(color: Colors.black45)),
      ]),
      title: Wrap(
          spacing: 8.0,
          runSpacing: 6.0,
          children: List.from([
            Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(event.itemType.name))
          ])
            ..addAll(event.students.map((student) {
              return StudentChip(student);
            }))),
      trailing: Icon(Icons.more_horiz, color: Theme.of(context).primaryColor),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    MetaAppointmentDetailsPage(event)));
      },
    );
  }
}

class MetaAppointmentDetailsPage extends StatelessWidget {
  final Appointment appointment;

  MetaAppointmentDetailsPage(this.appointment);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _client.getAppointment(appointment),
      builder: (BuildContext context, AsyncSnapshot<Appointment> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Scaffold(
            body: PageLoadingError('Fout bij het ophalen van details.'),
          );
        }

        if (!snapshot.hasData)
          // Shows progress indicator until the data is load.
          return Scaffold(
            body: PageLoadingIndicator('Details ophalen...'),
          );

        return AppointmentDetailsPage(snapshot.data);
      },
    );
  }
}

class AppointmentDetailsPage extends StatelessWidget {
  final Appointment appointment;

  AppointmentDetailsPage(this.appointment);

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Building AppointmentDetailsPage for $appointment {students: ${appointment
            .students}, remark: ${appointment.remark}}");

    List detailWidgets = <Widget>[
      // Item Type
      ListTile(
        leading: Icon(Icons.label),
        title: Text(appointment.itemType.name ?? '(onbekend)'),
      ),
      // Date
      ListTile(
        leading: Icon(Icons.event),
        title: Text(DateFormat('dd MMMM y').format(appointment.start)),
      ),
      // Start time
      ListTile(
        leading: Icon(Icons.timelapse),
        title: Text(DateFormat('HH:MM').format(appointment.start) +
            ' - ' +
            DateFormat('HH:MM').format(appointment.end)),
      ),
      // Students
      ListTile(
        leading: Icon(Icons.people),
        title: (appointment.students == null ?? appointment.students.isEmpty)
            ? Text('(geen leerlingen)')
            : Wrap(
                spacing: 8.0,
                children: appointment.students.map((student) {
                  return new StudentChip(student);
                }).toList()),
      ),
    ];

    // Remarks
    if (appointment.remark != null && appointment.remark != '') {
      detailWidgets.add(ListTile(
        leading: Icon(Icons.comment),
        title: Text(appointment.remark),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Afspraak'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      AppointmentEditPage(appointment),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _client.deleteAppointment(appointment).then((value) {
                debugPrint("Deleted succesfully $appointment");
                Navigator.of(context).pop();
              }).catchError((error) {
                print("Failed deleting $appointment: $error");
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: detailWidgets,
      ),
    );
  }
}

class StudentChip extends StatelessWidget {
  final Student student;

  StudentChip(this.student);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(student.name),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => StudentDetailsPage(student),
          ),
        );
      },
    );
  }
}

class AppointmentEditPage extends StatefulWidget {
  final Appointment appointment;

  AppointmentEditPage(this.appointment);

  @override
  _AppointmentEditPageState createState() {
    return new _AppointmentEditPageState(this.appointment);
  }
}

class _AppointmentEditPageState extends State<AppointmentEditPage> {
  Appointment appointment;

  _AppointmentEditPageState(this.appointment);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: appointment.start,
      firstDate: new DateTime(2016),
      lastDate: new DateTime(2020),
    );

    if (picked != null) {
      setState(() {
        appointment.start = new DateTime(
          picked.year,
          picked.month,
          picked.day,
          appointment.start.hour,
          appointment.start.minute,
        );
        appointment.end = new DateTime(
          picked.year,
          picked.month,
          picked.day,
          appointment.end.hour,
          appointment.end.minute,
        );
      });
      debugPrint("Date selected: ${appointment.start}");
    }
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: new TimeOfDay.fromDateTime(appointment.start),
    );

    if (picked != null) {
      int diffHours = picked.hour - appointment.start.hour;
      int diffMinutes = picked.minute - appointment.start.minute;
      setState(() {
        appointment.start = new DateTime(
          appointment.start.year,
          appointment.start.month,
          appointment.start.day,
          appointment.start.hour + diffHours,
          appointment.start.minute + diffMinutes,
        );
        appointment.end = new DateTime(
          appointment.end.year,
          appointment.end.month,
          appointment.end.day,
          appointment.end.hour + diffHours,
          appointment.end.minute + diffMinutes,
        );
      });
      debugPrint("Date selected: ${appointment.start}");
    }
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: new TimeOfDay.fromDateTime(appointment.end),
    );

    if (picked != null) {
      setState(() {
        appointment.end = new DateTime(
          appointment.end.year,
          appointment.end.month,
          appointment.end.day,
          picked.hour,
          picked.minute,
        );
      });
      debugPrint("Date selected: ${appointment.start}");
    }
  }

  void _removeStudent(Student student) {
    setState(() {
      appointment.students.remove(student);
      debugPrint("Removed student $student from appointment $appointment");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(appointment.itemType.name == ''
            ? 'Afspraak bewerken'
            : 'Nieuwe afspraak'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            // Item Type
            ListTile(
              leading: Icon(Icons.label),
              title: Text(appointment.itemType.name ?? '(onbekend)'),
            ),
            // Date
            ListTile(
              leading: Icon(Icons.event),
              title: Text(DateFormat('dd MMMM y').format(appointment.start)),
              onTap: () {
                _selectDate(context);
              },
            ),
            // Start time
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text(DateFormat('HH:MM').format(appointment.start)),
              onTap: () {
                _selectStartTime(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.timelapse),
              title: Text(DateFormat('HH:MM').format(appointment.end)),
              onTap: () {
                _selectEndTime(context);
              },
            ),
            // Students
            ListTile(
              leading: Icon(Icons.people),
              title:
                  (appointment.students == null ?? appointment.students.isEmpty)
                      ? Text('(geen leerlingen)')
                      : Wrap(
                          spacing: 8.0,
                          runSpacing: 6.0,
                          children: appointment.students.map((student) {
                            return Chip(
                              label: Text(student.name),
                              onDeleted: () => _removeStudent(student),
                            );
                          }).toList()),
              trailing: Icon(Icons.add),
            ),
            // Remarks
            ListTile(
              leading: Icon(Icons.comment),
              title: TextFormField(
                initialValue: appointment.remark,
              ),
            ),
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                padding: EdgeInsets.all(16.0),
                child: new Text('Opslaan'),
                onPressed: () {
                  _client.saveAppointment(appointment, 17).then((v) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    debugPrint(
                      "Error while saving Appointment: ${error.toString()}",
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentDetailsPage extends StatelessWidget {
  final Student student;

  StudentDetailsPage(this.student);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.perm_identity),
            title: Text(student.name),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('0610593071'),
            trailing: Icon(Icons.call),
            onTap: () => launch('tel:+31610593071'),
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Spoorstraat 114, Hengelo'),
          ),
        ],
      ),
    );
  }
}
