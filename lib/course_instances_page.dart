import 'package:dation_app/dation_rest_api_client.dart';
import 'package:dation_app/page_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CourseInstancesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new FutureBuilder(
          future: getCourseInstances(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData)
              // Shows progress indicator until the data is load.
              return new PageLoadingIndicator('Cursussen ophalen...');

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
