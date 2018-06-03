import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<List<CourseInstance>> getCourseInstances() async {
  final String endpoint = 'http://192.168.133.236:1001/api/v1/course-instances';
  final String basicKey = 'lydjV2Y6DrLGiBg/BlYPpQxZqS8cL8My3rd8GJw7hvY=';

  try {
    var response = await http.get(
      endpoint,
      headers: {HttpHeaders.AUTHORIZATION: "Basic $basicKey"},
    );
    if (response.statusCode != HttpStatus.OK) {
      throw new Exception(
          "Failed http call: ${response.body} (${response.statusCode})");
    }
    // Decode the json response
    List data = json.decode(response.body);
    // Get the model list
    List<CourseInstance> instanceList = createCourseInstanceList(data);
    // Print the results.
    return instanceList;
  } catch (exception) {
    print("Exception thrown when getting course instances: $exception");
  }

  return null;
}

/// Method to parse information from the retrieved data
List<CourseInstance> createCourseInstanceList(List data) {
  List<CourseInstance> list = new List();
  for (int i = 0; i < data.length; i++) {
    CourseInstance courseInstance = new CourseInstance(
      data[i]["name"],
      DateTime.parse(data[i]["startDate"]),
      ccvCode: data[i]["ccvCode"],
      code95PracticeHours: data[i]["code95PracticeHours"],
      code95TheoryHours: data[i]["code95TheoryHours"],
      remainingAttendeeCapacity: data[i]["remainingAttendeeCapacity"],
    );
    list.add(courseInstance);
  }
  return list;
}

class CourseInstance {
  String name;
  DateTime startDate;
  String ccvCode;
  int code95PracticeHours;
  int code95TheoryHours;
  int remainingAttendeeCapacity;

  CourseInstance(
    this.name,
    this.startDate, {
    this.ccvCode,
    this.code95PracticeHours,
    this.code95TheoryHours,
    this.remainingAttendeeCapacity,
  });

  @override
  String toString() {
    return super.toString() +
        '(' +
        this.name +
        ', ' +
        this.startDate.toString() +
        ')';
  }
}
