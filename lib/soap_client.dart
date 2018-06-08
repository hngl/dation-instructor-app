import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart';

class SoapClient {
  String endpoint;

  SoapClient(this.endpoint);

  Future<xml.XmlDocument> makeRequest(
      {String action = '', String body = ''}) async {
    var requestBody = makeEnvelope(body).trim();
    debugPrint("SoapClient: starting request with body $requestBody");

    http.Response response = await http.post(endpoint,
        headers: {
          'Content-Type': 'text/xml; charset=UTF-8',
          'SOAPAction': action,
        },
        body: requestBody);

    // Check for HTTP error
    if (response.statusCode >= 400) {
      throw Exception("Server returned ${response.reasonPhrase} (${response
              .statusCode}): ${response.body}");
    }

    // Parse response to XML
    xml.XmlDocument doc = xml.parse(response.body);

    // Check for SoaPFault
    var faults = doc.findAllElements('SOAP-ENV:Fault');
    if (faults.length > 0) {
      throw SoapFaultException(
          faults.first.findElements('faultstring').single.text);
    }

    return doc;
  }

  String makeEnvelope(String contents) {
    return """
      <?xml version="1.0"?>
      <soap:Envelope 
      xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
      soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">
        <soap:Body>
          $contents
        </soap:Body>
      </soap:Envelope>  
    """;
  }
}

class SoapFaultException implements Exception {
  String faultString;

  SoapFaultException(this.faultString);

  String toString() {
    return "SoapFault: $faultString";
  }
}

/// Thrown when response message contains a Response element with a StatusResult element of value false
class FalseStatusResultException implements Exception {
  String message;

  FalseStatusResultException(this.message);

  String toString() {
    return "StatusResult is false: $message";
  }
}
