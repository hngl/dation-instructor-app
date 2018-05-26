import 'package:dation_app/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          primaryColor: Colors.purple,
        ),
        home: new Scaffold(
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
        ));
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
              Navigator.push(context, new MaterialPageRoute(builder:
                  (BuildContext context) => new CourseInstanceDetailWidget(courseInstance)));
            }
        );
        widgetList.add(listItem);
      }
    }
    return widgetList;
  }
}

class CourseInstanceDetailWidget extends StatelessWidget {
  final CourseInstance courseInstance;

  CourseInstanceDetailWidget(this.courseInstance);

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
          title: new Text("${courseInstance.code95TheoryHours} uur theorie en ${courseInstance.code95TheoryHours} uur praktijk"),
          subtitle: new Text('Code 95')
        ),
        new ListTile(
          leading: new Icon(Icons.event_seat),
          title: new Text(
              courseInstance.remainingAttendeeCapacity > 0 ?
              "${courseInstance.remainingAttendeeCapacity} plekken vrij" :
                  "volgeboekt"
          )
        ),
      ]),
    );
  }
}
