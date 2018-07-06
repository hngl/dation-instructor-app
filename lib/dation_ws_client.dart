import 'dart:async';
import 'package:instructorapp/dation_models.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart';
import 'soap_client.dart';

class DationWsClient {
  final String host;
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

  String _dateTimeToUnix(DateTime datetime) {
    return (datetime.millisecondsSinceEpoch / 1000).floor().toString();
  }

  String _childText(xml.XmlElement element, String child) {
    return element.findElements(child).first.text;
  }

  void _checkForBadResult(xml.XmlDocument response) {
    var responseElement = response.findAllElements('Response');
    if (responseElement.length > 0) {
      if ('false' ==
          responseElement.first.findElements('StatusResult').first.text)
        throw new BadResultException(
          responseElement.first.findElements('ResultMessage').first.text,
        );
    }
  }

  void _debugHead(String msg) {
    debugPrint(' DationWsClient: $msg'.padLeft(80, '-'));
  }

  Future<List<AgendaEvent>> getAgendaOverview({
    @required Instructor instructor,
    @required DateTime date,
  }) async {
    int requestedTimeStamp = (date.millisecondsSinceEpoch / 1000).floor();

    debugPrint(
        "DationWsClient: Fetching agenda blocks with stamp $requestedTimeStamp");

    // Make request
    var doc = await agendaSoapClient.makeRequest(
      body: '''<agenda_request_get_agenda_blok>
        <request xsi:type="ns2:Get_Agenda_Blok_Request">
          <instructeur xsi:type="xsd:int">${instructor.id}</instructeur>
          <timestamp xsi:type="xsd:int">$requestedTimeStamp</timestamp>
          <UserId xsi:type="xsd:int">${user.id}</UserId>
          <UserName xsi:type="xsd:string">${user.name}</UserName>
          <Handle xsi:type="xsd:string">${tenant.handle}</Handle>
          <RijschoolId xsi:type="xsd:string">${tenant.id}</RijschoolId>
          <SessionID xsi:nil="true"/>
        </request>
		  </agenda_request_get_agenda_blok>''',
    );

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
        _debugHead("Parsing xml for 'les'");
        List<Student> students = List();
        if (eventNode.findElements('studentsList').length > 0) {
          debugPrint("Element 'studentsList' found");
          for (var studentNode in eventNode
              .findElements('studentsList')
              .first
              .findElements('item')) {
            students.add(Student(
              int.parse(studentNode.findElements('id').first.text),
              studentNode.findElements('name').first.text,
            )..courseId = int.parse(_childText(studentNode, 'courseId')));
          }
        }

        _debugHead('Populating Appointment');
        debugPrint(eventNode.toXmlString(pretty: true));
        event = Appointment(
          id: int.parse(_childText(eventNode, 'id')),
          start: _unixToDateTime(_childText(eventNode, 'start')),
          end: _unixToDateTime(_childText(eventNode, 'stop')),
          itemType: new ItemType(name: _childText(eventNode, 'itemtype')),
          students: students,
        );
      }

      events.add(event);
    }

    return events;
  }

  Future<Appointment> getAppointment(Appointment appointment) async {
    var response = await agendaSoapClient.makeRequest(
      body: '''<agenda_request_editing_agenda_item>
			<request xsi:type="ns2:Editing_Agenda_Item_Request">
				<item xsi:type="xsd:int">${appointment.id}</item>
				<instructeur xsi:type="xsd:int">${user.id}</instructeur>
				<timestamp xsi:type="xsd:int">0</timestamp>
				<RijschoolId xsi:type="xsd:string">${tenant.id}</RijschoolId>
				<UserId xsi:type="xsd:int">${user.id}</UserId>
				<UserName xsi:type="xsd:string">${user.name}</UserName>
				<Handle xsi:type="xsd:string">${tenant.handle}</Handle>
				<SessionID xsi:nil="true"/>
			</request>
		</agenda_request_editing_agenda_item>''',
    );

    _checkForBadResult(response);

    var itemNode =
        response.findAllElements('AgendaItemList').first.children.first;

    _debugHead('Parsing Appointment details');
    debugPrint(itemNode.toXmlString(pretty: true));

    appointment.itemType = new ItemType(
      id: int.parse(_childText(itemNode, 'Type')),
      name: _childText(itemNode, 'Typename'),
    );

    debugPrint(itemNode.toXmlString(pretty: true));
    return appointment;
  }

  Future<Null> saveAppointment(Appointment appointment, int typeId) async {
    var response = await agendaSoapClient.makeRequest(
      body: '''<agenda_request_agendaitem_store>
			<request xsi:type="ns2:agendaitem_store_Request">
				<id xsi:type="xsd:int">${appointment.id}</id>
				<start xsi:type="xsd:int">${_dateTimeToUnix(appointment.start)}</start>
				<instructeur xsi:type="xsd:int">${user.id}</instructeur>
				<stop xsi:type="xsd:int">${_dateTimeToUnix(appointment.end)}</stop>
				<type xsi:type="xsd:int">$typeId</type>
				<opmerkingen xsi:type="xsd:string"></opmerkingen>
				<showToStudent xsi:type="xsd:int">0</showToStudent>
				<uitslag xsi:type="xsd:int">0</uitslag>
				<overig xsi:type="xsd:int">0</overig>
				<declarabel xsi:type="xsd:int">0</declarabel>
				<leerlingen xsi:type="xsd:string">${appointment.students.first.courseId}</leerlingen>
				<voertuigen xsi:type="xsd:string"></voertuigen>
				<RijschoolId xsi:type="xsd:string">${tenant.id}</RijschoolId>
				<UserId xsi:type="xsd:int">${user.id}</UserId>
				<UserName xsi:type="xsd:string">${user.name}</UserName>
				<Handle xsi:type="xsd:string">${tenant.handle}</Handle>
				<SessionID xsi:nil="true"/>
				<ipaddress xsi:type="xsd:string">127.0.0.1</ipaddress>
			</request>
		</agenda_request_agendaitem_store>''',
    );

    _checkForBadResult(response);

    debugPrint("Response ${response.toXmlString(pretty: true)}");
  }

  Future<dynamic> deleteAppointment(Appointment appointment) {
    debugPrint("Deleting from server $appointment");
    return agendaSoapClient.makeRequest(
      body: '''<agenda_request_get_delete_agenda_item>
			<request xsi:type="ns2:Delete_Agenda_Item_Request">
				<item xsi:type="xsd:int">${appointment.id}</item>
				<type xsi:type="xsd:string">item</type>
				<RijschoolId xsi:type="xsd:string">${tenant.id}</RijschoolId>
				<UserId xsi:type="xsd:int">${user.id}</UserId>
				<UserName xsi:type="xsd:string">${user.name}</UserName>
				<Handle xsi:type="xsd:string">${tenant.handle}</Handle>
				<SessionID xsi:nil="true"/>
				<ipaddress xsi:type="xsd:string">127.0.0.1</ipaddress>
			</request>
		</agenda_request_get_delete_agenda_item>''',
    );
  }
}

/// Thrown when response message contains a Response element with a StatusResult element of value false
class BadResultException implements Exception {
  final String message;

  BadResultException(this.message);

  String toString() {
    return "BadResult: $message";
  }
}
