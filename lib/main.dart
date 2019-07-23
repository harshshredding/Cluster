import 'package:flutter/material.dart';
import 'map.dart';
import 'add_event.dart';
import 'login.dart';
import 'test.dart';

void main() => runApp(new MyApp());

/// This is our starting point to the app.
class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cluster',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text("Welcome To Cluster"),
          ),
          body: Login()),
      initialRoute: '/',
      routes: {
        '/map': (context) => MapScreen(),
        '/addEvent': (context) => AddEventScreen(),
      },
    );
  }
}
