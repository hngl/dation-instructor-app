import 'package:dation_app/dation_ws_client.dart';
import 'package:dation_app/page_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AgendaPage extends StatelessWidget {
  final DationWsClient client;

  AgendaPage(this.client);

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: client.getAgendaBlocks(
            instructor: new Instructor(1), date: new DateTime.now()),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData)
            // Shows progress indicator until the data is load.
            return new PageLoadingIndicator('Afspraken ophalen...');

          List events = snapshot.data;

          return new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.all(14.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new IconButton(icon: new Icon(Icons.arrow_left)),
                    new Text(
                      new DateFormat('d MMMM y').format(DateTime.now()),
                      style:
                          new TextStyle(color: Theme.of(context).accentColor),
                    ),
                    new IconButton(icon: new Icon(Icons.arrow_right)),
                  ],
                ),
              ),
              new Expanded(
                  child: new ListView(
                      children: _buildEventSummaries(context, events)))
            ],
          );
        });
  }

  List<Widget> _buildEventSummaries(
      BuildContext context, List<AgendaEvent> events) {
    List<Widget> widgetList = new List<Widget>();
    if (events != null) {
      var timeFormatter = new DateFormat('HH:mm');
      for (var event in events) {
        var tile;
        print("Building widget for $event");
        if (event is AgendaAppointment) {
          tile = new ListTile(
              leading: new Column(children: <Widget>[
                new Text(timeFormatter.format(event.start)),
                new Text(timeFormatter.format(event.stop)),
              ]),
              title: new Wrap(
                  spacing: 8.0,
                  children: new List.from([
                    new Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: new Text(event.itemType))
                  ])
                    ..addAll(event.students.map((student) {
                      return new Chip(label: new Text(student.name));
                    }))),
              trailing:
                  new Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new AppointmentDetailsPage(event)));
              });
        }
        if (event is AgendaBlock) {
          tile = new ListTile(
              leading: new Column(children: <Widget>[
                new Text(timeFormatter.format(event.start)),
                new Text(timeFormatter.format(event.stop)),
              ]),
              title: new Text('(vrij blok)'),
              trailing:
                  new Icon(Icons.add, color: Theme.of(context).primaryColor),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new AppointmentDetailsPage(new AgendaAppointment(
                                start: event.start, stop: event.stop))));
              });
        }

        widgetList.add(tile);
      }
    }
    return widgetList;
  }
}

class AppointmentDetailsPage extends StatelessWidget {
  final AgendaAppointment appointment;

  AppointmentDetailsPage(this.appointment);

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Building AppointmentDetailsPage for $appointment {students: ${appointment
            .students}, remark: ${appointment.remark}}");

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(appointment.itemType ?? 'Nieuwe afspraak'),
      ),
      body: new ListView(children: <Widget>[
        // Item Type
        new ListTile(
          leading: new Icon(Icons.label),
          title: new Text(appointment.itemType ?? '(onbekend)'),
        ),
        // Date
        new ListTile(
          leading: new Icon(Icons.event),
          title:
              new Text(new DateFormat('dd MMMM y').format(appointment.start)),
        ),
        // Start time
        new ListTile(
          leading: new Icon(Icons.timelapse),
          title: new Text(new DateFormat('HH:MM').format(appointment.start) +
              ' - ' +
              new DateFormat('HH:MM').format(appointment.stop)),
        ),
        // Students
        new ListTile(
          leading: new Icon(Icons.people),
          title: appointment.students == null
              ? new Text('(geen leerlingen)')
              : new Wrap(
                  spacing: 8.0,
                  children: appointment.students.map((student) {
                    return new Chip(label: new Text(student.name));
                  }).toList()),
        ),
        // Vehicles
        new ListTile(
          leading: new Icon(Icons.directions_car),
          title: appointment.students == null
              ? new Text('(geen voertuig)')
              : new Wrap(
                  spacing: 8.0,
                  children: appointment.students.map((student) {
                    return new Chip(label: new Text('Grijze Volvo'));
                  }).toList()),
        ),
        // Remarks
        new ListTile(
            leading: new Icon(Icons.comment),
            title: new Text(appointment.remark ?? '')),
      ]),
    );
  }
}
