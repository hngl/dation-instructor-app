import 'package:dation_app/dation_rest_api_client.dart';
import 'package:dation_app/dation_ws_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final String _wsHost = 'https://dashboard.dation.nl';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Dation',
        theme: new ThemeData(
            primaryColor: Colors.purple, accentColor: Colors.blueAccent),
        home: new HomePage());
  }
}

class MenuItem {
  String title;
  IconData icon;

  MenuItem(this.title, this.icon);
}

// Main layout and navigation
class HomePage extends StatefulWidget {
  final drawerItems = [
    new MenuItem('Agenda', Icons.calendar_today),
    new MenuItem('Leerlingen', Icons.people),
    new MenuItem('Cursussen', Icons.bubble_chart)
  ];

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new AgendaPage();
      case 1:
        return new StudentsListPage();
      case 2:
        return new CourseInstancesPage();

      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  Widget build(BuildContext context) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () => _onSelectItem(i),
      ));
    }

    return new Scaffold(
      appBar: new AppBar(
        // here we display the title corresponding to the fragment
        // you can instead choose to have a static title
        title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
      ),
      drawer: new Drawer(
        child: new Column(
          children: <Widget>[
            new UserAccountsDrawerHeader(
                accountName: new Text("Beheerder"), accountEmail: null),
            new Column(children: drawerOptions)
          ],
        ),
      ),
      body: _getDrawerItemWidget(_selectedDrawerIndex),
    );
  }
}

class AgendaPage extends StatelessWidget {
  final client = new DationWsClient(_wsHost);

  AgendaPage() {
    client.setTenant(new Tenant(873, 'dation'));
    client.setUser(new User(1, 'beheerder'));
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: client.getAgendaBlocks(
            instructor: new Instructor(1), date: new DateTime.now()),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData)
            // Shows progress indicator until the data is load.
            return new Center(
              child: new ThemedCircularProgressIndicator(),
            );
          List events = snapshot.data;
          return new ListView(
            children: _buildEventSummaries(context, events),
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
        print("Building widget for ${event}");
        if (event is AgendaAppointment) {
          tile = new ListTile(
              leading: new Column(children: <Widget>[
                new Text(timeFormatter.format(event.start)),
                new Text(timeFormatter.format(event.stop)),
              ]),
              trailing:
                  new Icon(Icons.edit, color: Theme.of(context).primaryColor),
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
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new AppointmentDetailPage(event)));
              });
        }
        if (event is AgendaBlock) {
          tile = new ListTile(
            leading: new Column(children: <Widget>[
              new Text(timeFormatter.format(event.start)),
              new Text(timeFormatter.format(event.stop)),
            ]),
            title: new Text('(vrij blok)'),
            //trailing: new Icon(Icons.add),
          );
        }

        widgetList.add(tile);
      }
    }
    return widgetList;
  }
}

class AppointmentDetailPage extends StatelessWidget {
  final AgendaAppointment appointment;

  AppointmentDetailPage(this.appointment);

  @override
  Widget build(BuildContext context) {
    var dateFormatter = new DateFormat('dd MMMM y H:mm');

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(appointment.itemType),
      ),
      body: new ListView(children: <Widget>[
        new ListTile(
          leading: new Icon(Icons.event),
          title: new Text(dateFormatter.format(appointment.start)),
        ),
      ]),
    );
  }
}

class StudentsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(child: new Text('Leerlingen'));
  }
}

class CourseInstancesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new FutureBuilder(
          future: getCourseInstances(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData)
              // Shows progress indicator until the data is load.
              return new Center(
                child: new ThemedCircularProgressIndicator(),
              );
            // Shows the real data with the data retrieved.
            List courseInstances = snapshot.data;
            return new ListView(
              children:
                  createCourseInstanceSummaryWidgets(courseInstances, context),
            );
          }),
    );
  }

  List<Widget> createCourseInstanceSummaryWidgets(
      List<CourseInstance> courseInstances, BuildContext context) {
    List<Widget> widgetList = new List<Widget>();
    if (courseInstances != null) {
      var lengthOfList = courseInstances.length;
      var dateFormatter = new DateFormat('dd MMM y H:mm');
      for (int i = 0; i < lengthOfList; i++) {
        CourseInstance courseInstance = courseInstances[i];
        var listItem = new ListTile(
            leading: new Icon(
                courseInstance.remainingAttendeeCapacity > 0
                    ? Icons.event_available
                    : Icons.event_busy,
                color: Theme.of(context).primaryColor),
            title: new Text(courseInstance.name),
            subtitle: new Text(dateFormatter.format(courseInstance.startDate)),
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) =>
                          new CourseInstanceDetailPage(courseInstance)));
            });
        widgetList.add(listItem);
      }
    }
    return widgetList;
  }
}

class ThemedCircularProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation(Theme.of(context).primaryColor));
  }
}

class CourseInstanceDetailPage extends StatelessWidget {
  final CourseInstance courseInstance;

  CourseInstanceDetailPage(this.courseInstance);

  @override
  Widget build(BuildContext context) {
    var dateFormatter = new DateFormat('dd MMMM y H:mm');

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(courseInstance.name),
      ),
      body: new ListView(children: <Widget>[
        new ListTile(
          leading: new Icon(Icons.event),
          title: new Text(dateFormatter.format(courseInstance.startDate)),
        ),
        new ListTile(
            leading: new Icon(Icons.verified_user),
            title: new Text("${courseInstance
                .code95TheoryHours} uur theorie en ${courseInstance
                .code95TheoryHours} uur praktijk"),
            subtitle: new Text('Code 95')),
        new ListTile(
            leading: new Icon(Icons.event_seat),
            title: new Text(courseInstance.remainingAttendeeCapacity > 0
                ? "${courseInstance.remainingAttendeeCapacity} plekken vrij"
                : "volgeboekt")),
      ]),
    );
  }
}
