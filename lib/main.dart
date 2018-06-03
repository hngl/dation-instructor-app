import 'package:dation_app/dation_rest_api_client.dart';
import 'package:dation_app/dation_ws_client.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final String wsHost = 'https://dashboard.dation.nl';

void main() {
  runApp(new MyApp());
}

void _doExperiment() {
  var client = new DationWsClient('$wsHost');
  client.setTenant(new Tenant(873, 'dation'));
  client.setUser(new User(1, 'beheerder'));
  client
      .getAgendaBlocks(instructor: new Instructor(1), date: new DateTime.now())
      .then((List blocks) => blocks.forEach((block) => print(block.toString())))
      .catchError((e) => print(e.toString()));
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Dation',
        theme: new ThemeData(
          primaryColor: Colors.purple,
        ),
        home: new HomePage()
    );
  }
}

// Main layout and navigation
class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new CourseInstancesPage();
  }
}

class CourseInstancesPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Cursussen'),
      ),
      body: new FutureBuilder(
          future: getCourseInstances(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData)
              // Shows progress indicator until the data is load.
              return new MaterialApp(
                  home: new Scaffold(
                    body: new Center(
                      child: new CircularProgressIndicator(),
                    ),
                  ));
            // Shows the real data with the data retrieved.
            List courseInstances = snapshot.data;
            return new ListView(
              children: createCourseInstanceSummaryWidgets(
                  courseInstances, context),
            );
          }),
      floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.play_arrow),
          backgroundColor: Colors.redAccent,
          onPressed: _doExperiment),
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
                color: Colors.purple),
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
