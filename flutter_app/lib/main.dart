import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'AppState.dart';
import 'BuyTicketPage.dart';
import 'CheckInPage.dart';
import 'LoginPage.dart';
import 'util/APIManager.dart';
import 'util/DrawerStateInfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application. It shows the "home" page for
  // users that may or may not be logged in.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Airline',
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'My Airline'),
      ),
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<DrawerStateInfo>(
            create: (_) => DrawerStateInfo()),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'My Airline',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextButton(
                    onPressed: () async {
                      if (appState.isLoggedIn()) {
                        // Logout
                        setState(() {
                          appState.userID = null;
                        });
                      } else {
                        // Login
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                        setState(() {
                          appState.userID = result;
                          appState.userFirstName = "Demo";
                        });
                      }
                    },
                    child:
                        appState.isLoggedIn() ? Text('Logout') : Text('Login')),
                TextButton(
                    onPressed: appState.isLoggedIn()
                        ? () async {
                            final ticket = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BuyTicketPage()));
                            setState(() {
                              appState.ticket = ticket;
                            });
                          }
                        : null,
                    child: Text('Buy Ticket')),
                TextButton(
                    onPressed: appState.ticket != null
                        ? () async {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CheckInPage()));
                            setState(() {
                              appState = AppState();
                            });
                          }
                        : null,
                    child: Text('Checkin')),
              ],
            ),
          ),
        ));
  }
}
