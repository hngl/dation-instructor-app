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
            title: new Text('Beroepsopleidingen'),
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
                  children:
                      createCourseInstanceCardItems(courseInstances, context),
                );
              }),
        ));
  }

  List<Widget> createCourseInstanceCardItems(
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
        );
        widgetList.add(listItem);
      }
    }
    return widgetList;
  }
}
