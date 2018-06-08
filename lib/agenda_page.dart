import 'package:dation_app/dation_ws_client.dart';
import 'package:dation_app/page_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgendaPage extends StatelessWidget {
  final DationWsClient client;

  AgendaPage(this.client);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: client.getAgendaBlocks(
          instructor: Instructor(1),
          date: DateTime.now(),
        ),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData)
            // Shows progress indicator until the data is load.
            return PageLoadingIndicator('Afspraken ophalen...');

          List events = snapshot.data;

          return Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(icon: Icon(Icons.arrow_left), onPressed: null),
                    Text(
                      DateFormat('d MMMM y').format(DateTime.now()),
                      style: TextStyle(color: Theme.of(context).accentColor),
                    ),
                    IconButton(icon: Icon(Icons.arrow_right), onPressed: null),
                  ],
                ),
              ),
              Expanded(
                  child:
                      ListView(children: _buildEventSummaries(context, events)))
            ],
          );
        });
  }

  List<Widget> _buildEventSummaries(
      BuildContext context, List<AgendaEvent> events) {
    List<Widget> widgetList = List<Widget>();
    if (events != null) {
      var timeFormatter = DateFormat('HH:mm');
      for (var event in events) {
        var tile;
        print("Building widget for $event");
        if (event is Appointment) {
          tile = ListTile(
              leading: Column(children: <Widget>[
                Text(timeFormatter.format(event.start)),
                Text(timeFormatter.format(event.stop)),
              ]),
              title: Wrap(
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: List.from([
                    Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(event.itemType))
                  ])
                    ..addAll(event.students.map((student) {
                      return Chip(label: Text(student.name));
                    }))),
              trailing: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AppointmentDetailsPage(event)));
              });
        }
        if (event is AgendaBlock) {
          tile = ListTile(
              leading: Column(children: <Widget>[
                Text(timeFormatter.format(event.start)),
                Text(timeFormatter.format(event.stop)),
              ]),
              title: Text('(vrij blok)'),
              trailing: Icon(Icons.add, color: Theme.of(context).primaryColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => AppointmentEditPage(
                          Appointment(start: event.start, stop: event.stop),
                        ),
                  ),
                );
              });
        }

        widgetList.add(tile);
      }
    }
    return widgetList;
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
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          // Item Type
          ListTile(
            leading: Icon(Icons.label),
            title: Text(appointment.itemType ?? '(onbekend)'),
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
                DateFormat('HH:MM').format(appointment.stop)),
          ),
          // Students
          ListTile(
            leading: Icon(Icons.people),
            title: appointment.students == null
                ? Text('(geen leerlingen)')
                : Wrap(
                    spacing: 8.0,
                    children: appointment.students.map((student) {
                      return Chip(label: Text(student.name));
                    }).toList()),
          ),
          // Vehicles
          ListTile(
            leading: Icon(Icons.directions_car),
            title: appointment.students == null
                ? Text('(geen voertuig)')
                : Wrap(
                    spacing: 8.0,
                    children: appointment.students.map((student) {
                      return Chip(label: Text('Grijze Volvo'));
                    }).toList()),
          ),
          // Remarks
          ListTile(
              leading: Icon(Icons.comment),
              title: Text(appointment.remark ?? '')),
        ],
      ),
    );
  }

  void _onEdit() {}
}

class AppointmentEditPage extends StatelessWidget {
  final Appointment appointment;

  AppointmentEditPage(this.appointment);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text('Nieuwe afspraak'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            // Item Type
            ListTile(
              leading: Icon(Icons.label),
              title: Text(appointment.itemType ?? '(onbekend)'),
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
                  DateFormat('HH:MM').format(appointment.stop)),
            ),
            // Students
            ListTile(
              leading: Icon(Icons.people),
              title: appointment.students == null
                  ? Text('(geen leerlingen)')
                  : Wrap(
                      spacing: 8.0,
                      children: appointment.students.map((student) {
                        return Chip(label: Text(student.name));
                      }).toList()),
            ),
            // Vehicles
            ListTile(
              leading: Icon(Icons.directions_car),
              title: appointment.students == null
                  ? Text('(geen voertuig)')
                  : Wrap(
                      spacing: 8.0,
                      children: appointment.students.map((student) {
                        return Chip(label: Text('Grijze Volvo'));
                      }).toList()),
            ),
            // Remarks
            ListTile(
                leading: Icon(Icons.comment),
                title: Text(appointment.remark ?? '')),
          ],
        ),
      ),
    );
  }
}
