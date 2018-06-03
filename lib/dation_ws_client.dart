import 'dart:async';
import 'package:xml/xml.dart' as xml;

import 'soap_client.dart';

class DationWsClient {
  String host;
  SoapClient agendaSoapClient;
  User user;
  Tenant tenant;

  DationWsClient(this.host) {
    agendaSoapClient = new SoapClient("$host//webservice/mobile/agenda.php");
  }

  Future<List<AgendaEvent>> getAgendaBlocks(
      {Instructor instructor, DateTime date}) async {
    int requestedTimeStamp = (date.millisecondsSinceEpoch / 1000).floor();

    print("DationWsClient: Fetching agenda blocks with stamp $requestedTimeStamp");

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
		  </agenda_request_get_agenda_blok>'''
    );

    // Parse response
    var items = doc.findAllElements('AgendaBlokList').first.findElements('item');
    List<AgendaEvent> events = new List();
    for (xml.XmlElement eventNode in items) {
      AgendaEvent event;
      switch (eventNode.findElements('type').first.text) {
        case 'blok':
          {
            event = new AgendaBlock(
                start: new DateTime.fromMillisecondsSinceEpoch(
                    int.parse(eventNode.findElements('start').first.text)),
                stop: new DateTime.fromMillisecondsSinceEpoch(
                    int.parse(eventNode.findElements('start').first.text))
            );
          }
          break;

        case 'les':
          {
            event = new AgendaAppointment(
                start: new DateTime.fromMillisecondsSinceEpoch(
                    int.parse(eventNode.findElements('start').first.text)),
                stop: new DateTime.fromMillisecondsSinceEpoch(
                    int.parse(eventNode.findElements('start').first.text)),
                itemType: eventNode.findElements('itemtype').first.text
            );
          }
          break;

        default:
          {
            throw new Exception("Undefined agenda block type ${eventNode.findElements('type').first.text}");
          }
          break;
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

class AgendaEvent {}

class AgendaBlock extends AgendaEvent {
  DateTime start;
  DateTime stop;

  AgendaBlock({this.start, this.stop});

  @override
  String toString() {
    return "${super.toString()} ($start - $stop)";
  }
}

class AgendaAppointment extends AgendaEvent {
  DateTime start;
  DateTime stop;
  String itemType;

  AgendaAppointment({this.start, this.stop, this.itemType});

  @override
  String toString() {
    return "${super.toString()} ($itemType, $start - $stop)";
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