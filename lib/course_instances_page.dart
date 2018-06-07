import 'package:dation_app/dation_rest_api_client.dart';
import 'package:dation_app/page_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CourseInstancesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getCourseInstances(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (!snapshot.hasData)
              // Shows progress indicator until the data is load.
              return PageLoadingIndicator('Cursussen ophalen...');

            // Shows the real data with the data retrieved.
            List courseInstances = snapshot.data;
            return ListView(
              children:
                  createCourseInstanceSummaryWidgets(courseInstances, context),
            );
          }),
    );
  }

  List<Widget> createCourseInstanceSummaryWidgets(
      List<CourseInstance> courseInstances, BuildContext context) {
    List<Widget> widgetList = List<Widget>();
    if (courseInstances != null) {
      var lengthOfList = courseInstances.length;
      var dateFormatter = DateFormat('dd MMM y H:mm');
      for (int i = 0; i < lengthOfList; i++) {
        CourseInstance courseInstance = courseInstances[i];
        var listItem = ListTile(
            leading: Icon(
                courseInstance.remainingAttendeeCapacity > 0
                    ? Icons.event_available
                    : Icons.event_busy,
                color: Theme.of(context).primaryColor),
            title: Text(courseInstance.name),
            subtitle: Text(dateFormatter.format(courseInstance.startDate)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          CourseInstanceDetailPage(courseInstance)));
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
    var dateFormatter = DateFormat('dd MMMM y H:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(courseInstance.name),
      ),
      body: ListView(children: <Widget>[
        ListTile(
          leading: Icon(Icons.event),
          title: Text(dateFormatter.format(courseInstance.startDate)),
        ),
        ListTile(
            leading: Icon(Icons.verified_user), title: Text("${courseInstance
                .code95TheoryHours} uur theorie en ${courseInstance
                .code95TheoryHours} uur praktijk"), subtitle: Text('Code 95')),
        ListTile(
            leading: Icon(Icons.event_seat),
            title: Text(courseInstance.remainingAttendeeCapacity > 0
                ? "${courseInstance.remainingAttendeeCapacity} plekken vrij"
                : "volgeboekt")),
      ]),
    );
  }
}
