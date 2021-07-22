// APIManager
//
// This class manages the interactions with the Stargate APIs. It uses REST.
// Document, and GraphQL APIs as appropriate.
//
// Author: Jeff Davies (jeff.davies@datastax.com)

import 'dart:convert';
import 'dart:core';
import 'package:airline_demo/entities/Flight.dart';
import 'package:airline_demo/entities/Ticket.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '../AppState.dart';
import '../entities/LoginResponse.dart';
import '../entities/Preferences.dart';
import 'package:uuid/uuid.dart';

class APIManager {
  static const String ASTRA_DB_ID = '6f46c335-f1c1-4ee4-9d28-dd909821e7cf';
  static const String ASTRA_DB_REGION = 'us-west1';
  static const String ASTRA_DB_KEYSPACE = 'airline';
  // static String _client_id = 'knHgIhhFsSRFmHPoJJNjEkqg';
  // static String _client_secret =
  //     'MIbt9xGN+Rq0Jqbqeh1Ip_9UxcmWsjFdZ5hiHC6dqRZ+2kFbB9T4PWjM6ZTY.-j6S7ZMyyBsaZIEqfGfc+UOT87j26pdPPM37tAQZZ8HuB1FNnCX5Qvaohr7WiOFbmA9';
  static const String APP_TOKEN =
      'AstraCS:knHgIhhFsSRFmHPoJJNjEkqg:39eee08ca3222e80937479e74f994ff464b6794e2373071e85f8b6bf737a7010';

  static String _baseURL = 'https://' +
      ASTRA_DB_ID +
      '-' +
      ASTRA_DB_REGION +
      '.apps.astra.datastax.com';

  /*************
   * REST APIs *
   *************/

  static Future<LoginResponse> doLogin(String username, String password) async {
    final LoginResponse loginResponse = LoginResponse();

    // Encrypt the password
    var bytes1 = utf8.encode(password); // data being hashed
    var digest1 = sha256.convert(bytes1); // Hashing Process
    String encodedPW = digest1.toString();
    // print("Digest as bytes: ${digest1.bytes}");   // Print Bytes
    // print("Digest as hex string: $digest1");      // Print After Hashing
    // Example URL
    // curl -X GET "https://dad43061-23d9-43ec-9c1f-6de1f7349a61-us-west-2.apps.astra.datastax.com/api/rest/v2/keyspaces/kcorp/login/jeff.davies%40datastax.com/05ccb21ac9e1f27aa25dddbccc5251cb010ea99a949768212665e7a6151fdf64?fields=id" -H  "accept: application/json"
    // -H  "X-Cassandra-Token: AstraCS:fdACgLXNBgQEBCmLdMeyyQDo:b7edd52813237bac347b1aa66369a9bfbf7199a03ff6b03fa90d1b31d01b4d57"
    String url = _baseURL +
        '/api/rest/v2/keyspaces/' +
        ASTRA_DB_KEYSPACE +
        '/login/' +
        Uri.encodeComponent(username) +
        '/' +
        encodedPW +
        '?fields=id';

    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
      'X-Cassandra-Token': APP_TOKEN
    });

    if (response.statusCode == 200) {
      // print(response.body);
      final jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        int count = jsonResponse['count'] as int;
        if (count != 1) {
          // Login failed
          loginResponse.success = false;
          loginResponse.loginErrorMessage =
              'User name or password is incorrect';
        } else {
          // The login succeeded
          // Iterate over the returned list
          final List<dynamic> returnedArray = jsonResponse['data'] as List;
          Map<String, dynamic> data = returnedArray.first;
          loginResponse.success = true;
          loginResponse.userID = data['id'];
        }
      } else {
        // Error on the GET request
        // print(response.body);
      } // jsonResponse == null
    }
    return Future.value(loginResponse);
  }

  /// Get a list of cities that our airline flies to/from
  static Future<List<String>> getCityList() async {
    // This loads the default preferences.
    final List<String> cityList = List<String>.empty(growable: true);

    // Now lets make a call to the Document API and get the uer preferences
    // for this specific user
    String url =
        _baseURL + '/api/rest/v2/keyspaces/' + ASTRA_DB_KEYSPACE + '/city/rows';

    final response = await http.get(Uri.parse(url), headers: {
      'accept': 'application/json',
      'X-Cassandra-Token': APP_TOKEN
    });

    if (response.statusCode == 200) {
      // A successful response looks like the following:
      // {
      //   "count": 65,
      //   "data": [
      //     {
      //       "name": "Chicago IL"
      //     },
      //     {
      //       "name": "Mobile AL"
      //     },
      //     ...
      //   ]
      // }
      final jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        // int count = jsonResponse['count'] as int;
        final List<dynamic> returnedArray = jsonResponse['data'] as List;

        for (final city in returnedArray) {
          cityList.add(city["name"]);
        }
      } else if (response.statusCode == 404) {
        // Document not found. Likely a new user. Create a default preferences
        // settings object, store it in the DB and return it to the caller
        // Do nothing
      } else {
        // Error on the GET request
        // print(response.body);
      } // jsonResponse == null
    }
    cityList.sort();
    return Future.value(cityList);
  }

  /// Get a list of cities that our airline flies to/from
  static Future<List<Flight>> getFlights(
      String origin_city, String destination_city) async {
    // This loads the default preferences.
    final List<Flight> flightList = List<Flight>.empty(growable: true);

    // Now lets make a call to the REST API and get the list of flights for these cities
    String url = _baseURL +
        '/api/rest/v2/keyspaces/' +
        ASTRA_DB_KEYSPACE +
        '/flight_by_city?where=';

    String whereClause =
        '{"origin_city": {"\$eq": "$origin_city"}, "destination_city": {"\$eq": "$destination_city"}}';

    // URL encode the where clause
    whereClause = Uri.encodeComponent(whereClause);

    final response = await http.get(Uri.parse(url + whereClause), headers: {
      'accept': 'application/json',
      'X-Cassandra-Token': APP_TOKEN
    });

    if (response.statusCode == 200) {
      // A successful response looks like the following:
      // {
      //   "count": 10,
      //   "data": [
      //     {
      //       "origin_city": "Akron OH",
      //       "departure_gate": "A 01",
      //       "id": "ABC0260",
      //       "destination_city": "Dallas TX",
      //       "departure_time": "6:00 AM"
      //     },
      //     {
      //       "origin_city": "Akron OH",
      //       "departure_gate": "A 02",
      //       "id": "ABC0261",
      //       "destination_city": "Dallas TX",
      //       "departure_time": "7:00 AM"
      //     },
      //     ...
      //   ]
      // }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        // int count = jsonResponse['count'] as int;
        final List<dynamic> returnedArray = jsonResponse['data'] as List;

        for (final flight in returnedArray) {
          flightList.add(Flight.fromJson(flight));
        }
      } else if (response.statusCode == 404) {
        // Document not found. Likely a new user. Create a default preferences
        // settings object, store it in the DB and return it to the caller
        // Do nothing
      } else {
        // Error on the GET request
        // print(response.body);
      } // jsonResponse == null
    }
    // flightList.sort();
    return Future.value(flightList);
  }

  /// Buy a ticket for a specific flight
  static Future<Ticket> buyTicket(Flight flight, String userID) async {
    // Create a ticket
    AppState appState = AppState();
    var uuid = Uuid();
    Ticket ticket = Ticket();
    ticket.id = uuid.v4();
    ticket.flight_id = flight.id;
    ticket.origin_city = flight.origin_city;
    ticket.destination_city = flight.destination_city;
    ticket.departure_gate = flight.departure_gate;
    ticket.departure_time = flight.departure_time;
    ticket.checkin_time = "";
    ticket.carousel = flight.carousel;
    ticket.passenger_id = appState.userID!;
    ticket.passenger_name = appState.userFirstName!;

    // Now lets make a call to the REST API to write out this ticket
    String url =
        _baseURL + '/api/rest/v2/keyspaces/' + ASTRA_DB_KEYSPACE + '/ticket';

    final response = await http.post(Uri.parse(url),
        headers: {'accept': 'application/json', 'X-Cassandra-Token': APP_TOKEN},
        body: ticket.toJson());

    if (response.statusCode == 200) {
      // A successful response looks like the following:
      // {
      //   "id": "33330000-1111-1111-1111-000011110000"
      // }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        // int count = jsonResponse['count'] as int;
        ticket.id = jsonResponse['id'] as String;
      } else {
        // Error on the GET request
        // print(response.body);
      } // jsonResponse == null
    }
    // flightList.sort();
    return ticket;
  }

  /// Buy a ticket for a specific flight
  static Future<bool> checkIn(Ticket ticket, int numBags) async {
    // check in for this flight
    // Get the current time as a string

    AppState appState = AppState();
    var now = DateTime.now();
    int hour = now.hour % 12;
    String AMPM = now.hour > 12 ? "PM" : "AM";
    String timeString =
        hour.toString() + ":" + now.minute.toString() + " " + AMPM;
    Map<String, dynamic> checkIn = <String, dynamic>{};
    checkIn["checkin_time"] = timeString;

    // Now lets make a call to the REST API to write out this ticket
    String url = _baseURL +
        '/api/rest/v2/keyspaces/' +
        ASTRA_DB_KEYSPACE +
        '/ticket/' +
        ticket.id;

    final response = await http.put(Uri.parse(url),
        headers: {'accept': 'application/json', 'X-Cassandra-Token': APP_TOKEN},
        body: jsonEncode(checkIn));

    if (response.statusCode == 201) {
      // A successful response looks like the following:
      // {
      //   "data": {
      //     "checkin_time": "07:15 AM"
      //   }
      // }

      final jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        // Ok, lets create the baggage records
        url = _baseURL +
            '/api/rest/v2/keyspaces/' +
            ASTRA_DB_KEYSPACE +
            '/baggage';
        for (int x = 0; x < numBags; x++) {}
        // int count = jsonResponse['count'] as int;
        ticket.id = jsonResponse['id'] as String;
      } else {
        // Error on the GET request
        // print(response.body);
      } // jsonResponse == null
    }
    return true;
  }
}
