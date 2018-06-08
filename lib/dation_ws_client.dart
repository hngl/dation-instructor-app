import 'dart:async';
import 'package:dation_app/dation_models.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart';
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

  String _dateTimeToUnix(DateTime datetime) {
    return (datetime.millisecondsSinceEpoch / 1000).floor().toString();
  }

  String _childText(xml.XmlElement element, String child) {
    return element.findElements(child).first.text;
  }

  Future<List<AgendaEvent>> getAgendaBlocks(
      {Instructor instructor, DateTime date}) async {
    int requestedTimeStamp = (date.millisecondsSinceEpoch / 1000).floor();

    debugPrint(
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
        debugPrint("DationWsClient: Parsing xml for 'les'");
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
            ));
          }
        }

        debugPrint('DationWsClient: Populating Appointment');
        debugPrint(eventNode.toXmlString(pretty: true));
        event = Appointment(
          id: int.parse(_childText(eventNode, 'id')),
          start: _unixToDateTime(_childText(eventNode, 'start')),
          end: _unixToDateTime(_childText(eventNode, 'stop')),
          itemType: _childText(eventNode, 'itemtype'),
          students: students,
        );

        debugPrint('DationWsClient: Appointment populated');
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

  Future<Null> saveAppointment(Appointment appointment) async {
    var response = await agendaSoapClient
        .makeRequest(body: '''<agenda_request_agendaitem_store>
			<request xsi:type="ns2:agendaitem_store_Request">
				<id xsi:type="xsd:int">${appointment.id}</id>
				<start xsi:type="xsd:int">${_dateTimeToUnix(appointment.start)}</start>
				<instructeur xsi:type="xsd:int">1</instructeur>
				<stop xsi:type="xsd:int">${_dateTimeToUnix(appointment.end)}</stop>
				<type xsi:type="xsd:int">1</type>
				<opmerkingen xsi:type="xsd:string"></opmerkingen>
				<showToStudent xsi:type="xsd:int">0</showToStudent>
				<uitslag xsi:type="xsd:int">0</uitslag>
				<overig xsi:type="xsd:int">0</overig>
				<declarabel xsi:type="xsd:int">0</declarabel>
				<leerlingen xsi:type="xsd:string">${appointment.students.first.id}</leerlingen>
				<voertuigen xsi:type="xsd:string"></voertuigen>
				<RijschoolId xsi:type="xsd:string">${tenant.id}</RijschoolId>
				<UserId xsi:type="xsd:int">${user.id}</UserId>
				<UserName xsi:type="xsd:string">${user.name}</UserName>
				<Handle xsi:type="xsd:string">${tenant.handle}</Handle>
				<SessionID xsi:nil="true"/>
				<ipaddress xsi:type="xsd:string">127.0.0.1</ipaddress>
			</request>
		</agenda_request_agendaitem_store>''');

    _checkForBadResult(response);

    debugPrint("Response ${response.toXmlString(pretty: true)}");
  }

  void _checkForBadResult(xml.XmlDocument response) {
    debugPrint("Check fror Bad Result: ${response.toXmlString(pretty: true)}");
    var responseElement = response.findAllElements('Response');
    if (responseElement.length > 0) {
      if ('false' ==
          responseElement.first.findElements('StatusResult').first.text)
        throw new FalseStatusResultException(
          responseElement.first.findElements('ResultMessage').first.text,
        );
    }
  }
}