import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class CalendarService {
  final GoogleSignInAccount _currentUser;

  CalendarService(this._currentUser);

  Future<calendar.Events> fetchEvents() async {
    // addEvent(summary: "This is summary",
    //     description: "This is description",
    //     startTime: DateTime.now().add(Duration(hours: 1)),
    //     endTime: DateTime.now().add(Duration(hours: 5)), account: _currentUser);
    final headers = await _currentUser.authHeaders;
    final client = _AuthenticatedClient(http.Client(), headers);

    final calendarApi = calendar.CalendarApi(client);
    final events = await calendarApi.events.list("primary"); // Access primary calendar
   // List<String> eventList = events.items!.map((event) => event.summary ?? "No Title").toList();
   // print(eventList.length);
   // eventList.forEach(print);
    return events;
  }
}

Future<void> addEvent({
  required String summary,
  required String description,
  required DateTime startTime,
  required DateTime endTime,
  required GoogleSignInAccount? account,
}) async {
  if (account == null) {
    print("User not signed in");
    return;
  }

  final authHeaders = await account.authHeaders;
  final client = _AuthenticatedClient(http.Client(), authHeaders);

  final calendarApi = calendar.CalendarApi(client);

  // Define the event
  final event = calendar.Event(
    summary: summary, // Event title
    description: description, // Event description
    start: calendar.EventDateTime(
      dateTime: startTime.toUtc(),
      timeZone: "UTC", // Specify time zone
    ),
    end: calendar.EventDateTime(
      dateTime: endTime.toUtc(),
      timeZone: "UTC",
    ),
  );

  // Insert the event into the user's primary calendar
  try {
    final createdEvent = await calendarApi.events.insert(event, "primary");
    print("Event created: ${createdEvent.htmlLink}");
  } catch (error) {
    print("Error creating event: $error");
  }
}



class _AuthenticatedClient extends http.BaseClient {
  final http.Client _client;
  final Map<String, String> _headers;

  _AuthenticatedClient(this._client, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
