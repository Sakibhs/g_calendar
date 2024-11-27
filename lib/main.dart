import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

import 'calendar_service.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Calendar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff000000)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Google Calendar Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar', // Full calendar access
    ],
  );
  Events events = Events();
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    //_handleSignOut();
    loadData();
    _googleSignIn.signInSilently(); // Automatically signs in the user if already authenticated
  }

  void loadData() async{
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      _currentUser = account;
      CalendarService service = CalendarService(_currentUser!);
      var eventss = await service.fetchEvents();
      setState(() {

        events = eventss;
      });
    });
  }

  Future<void> _handleSignIn() async {
    try {
     final user = await _googleSignIn.signIn();
      CalendarService service = CalendarService(user!);
      service.fetchEvents();
    } catch (error) {
      print("Sign-in failed: $error");
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _currentUser == null
            ? ElevatedButton(
          onPressed: _handleSignIn,
          child: Text('Sign in with Google'),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as: ${_currentUser!.displayName}'),
            ElevatedButton(
              onPressed: _handleSignOut,
              child: Text('Sign out'),
            ),
            Expanded(child: ListView.builder(
              itemCount: events.items?.length,
                itemBuilder: (context, index){
                return ListTile(title: Text(
                    events.items?[index].summary ?? "No Summary"
                ),
                subtitle: Text(events.items?[index].start?.date.toString() ?? "No Date"),);
                })),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
