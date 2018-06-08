import 'dart:async';
import 'package:xml/xml.dart' as xml;

import 'soap_client.dart';

class DationWsClient {
  String host;
  SoapClient agendaSoapClient;
  User user;
  Tenant tenant;

  DationWsClient(this.host) {
    agendaSoapClient = SoapClient("$host//webservice/mobile/agenda.php");
  }

  /// Parse string containing seconds since Unix Epoch into DateTime
  DateTime _unixToDateTime(String unix) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(unix) * 1000);
  }

  String _childText(xml.XmlElement element, String child) {
    return element.findElements(child).first.text;
  }

  Future<List<AgendaEvent>> getAgendaBlocks(
      {Instructor instructor, DateTime date}) async {
    int requestedTimeStamp = (date.millisecondsSinceEpoch / 1000).floor();

    print(
        "DationWsClient: Fetching agenda blocks with stamp $requestedTimeStamp");

    // Make request
    var doc = await agendaSoapClient
        .makeRequest(body: '''<agenda_request_get_agenda_blok>
        <request xsi:type="ns2:Get_Agenda_Blok_Request">
          <instructeur xsi:type="xsd:int">${instructor.id}</instructeur>
          <timestamp xsi:type="xsd:int">$requestedTimeStamp</timestamp>
          <UserId xsi:type="xsd:int">${user.id}</UserId>
          <UserName xsi:type="xsd:string">${user.name}</UserName>
          <Handle xsi:type="xsd:string">${tenant.handle}</Handle>
          <RijschoolId xsi:type="xsd:string">${tenant.id}</RijschoolId>
          <SessionID xsi:nil="true"/>
        </request>
		  </agenda_request_get_agenda_blok>''');

    // Parse response
    var items =
        doc.findAllElements('AgendaBlokList').first.findElements('item');
    List<AgendaEvent> events = List();
    for (xml.XmlElement eventNode in items) {
      AgendaEvent event;
      if (eventNode.findElements('type').first.text == 'blok') {
        event = AgendaBlock(
          start: _unixToDateTime(_childText(eventNode, 'start')),
          end: _unixToDateTime(_childText(eventNode, 'stop')),
        );
      } else {
        print("DationWsClient: Parsing xml for 'les'");
        List<Student> students = List();
        if (eventNode.findElements('studentsList').length > 0) {
          print("Element 'studentsList' found");
          for (var studentNode in eventNode
              .findElements('studentsList')
              .first
              .findElements('item')) {
            students.add(Student(
              int.parse(studentNode.findElements('id').first.text),
              studentNode.findElements('name').first.text,
            ));
          }
        }

        print('DationWsClient: Populating Appointment');
        event = Appointment(
            start: _unixToDateTime(_childText(eventNode, 'start')),
            end: _unixToDateTime(_childText(eventNode, 'stop')),
            itemType: _childText(eventNode, 'itemtype'),
            remark: _childText(eventNode, 'opmerkingen'),
            students: students);
        print('DationWsClient: Appointment populated');
      }

      events.add(event);
    }

    return events;
  }

  void setUser(User user) {
    this.user = user;
  }

  void setTenant(Tenant tenant) {
    this.tenant = tenant;
  }
}

class Student {
  int id;
  String name;

  Student(this.id, this.name);
}

class AgendaEvent {}

class AgendaBlock extends AgendaEvent {
  DateTime start;
  DateTime end;

  AgendaBlock({this.start, this.end});

  @override
  String toString() {
    return "${super.toString()} ($start - $end)";
  }
}

class Appointment extends AgendaEvent {
  DateTime start;
  DateTime end;
  String itemType = '';
  List<Student> students = List();
  String remark = '';

  Appointment(
      {this.start, this.end, this.itemType, this.students, this.remark});

  @override
  String toString() {
    return "${super.toString()} ($itemType, $start - $end)";
  }
}

class Instructor {
  int id;

  Instructor(this.id);
}

class User {
  String name;
  int id;

  User(this.id, this.name);
}

class Tenant {
  int id;
  String handle;

  Tenant(this.id, this.handle);
}
