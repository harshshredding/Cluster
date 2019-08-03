import 'package:flutter/material.dart';
import 'map.dart';
import 'add_proposal.dart';
import 'login_uw.dart';
import 'home.dart';
import 'user_profile.dart';

void main() => runApp(new MyApp());

/// This is our starting point to the app.
class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cluster',
      theme: ThemeData.dark(),
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text("Welcome To Cluster"),
          ),
          body: Login()),
      initialRoute: '/',
      routes: {
        '/map': (context) => MapScreen(),
        '/addEvent': (context) => AddEventScreen(),
        '/userProfile': (context) => UserProfileHeader(true),
        '/home': (context) => Home()
      },
    );
  }
}
