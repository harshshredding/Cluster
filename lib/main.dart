import 'package:flutter/material.dart';
import 'map.dart';
import 'add_proposal.dart';
import 'login_uw.dart';
import 'home.dart';
import 'user_profile.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'my_proposals.dart';

void main() => runApp(new MyApp());

/// This is our starting point to the app.
class MyApp extends StatelessWidget {
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cluster',
      theme: ThemeData.dark(),
      home:  Login(false),
      //home: Center(child: Text("Text")),
      initialRoute: '/',
      routes: {
        '/login': (context) => Login(true),
        '/map': (context) => MapScreen(),
        '/addProposal': (context) => AddProposalScreen(),
        '/userProfile': (context) => UserProfile(true),
        '/home': (context) => Home(),
        '/my_proposals': (context) => MyProposals(),
      },
    );
  }
}
