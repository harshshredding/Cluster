import 'package:flutter/material.dart';
import 'map.dart';
import 'add_proposal.dart';
import 'login_home.dart';
import 'register.dart';
import 'home.dart';
import 'user_profile.dart';
import 'my_proposals.dart';
import 'create_group.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'verification_email.dart';
import 'package:CoffeeShop/ForgotPass.dart';

Future<String> _loginUser() async {
  try {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      return user.uid;
    }
  } catch (err) {
    print(err);
  }
  return null;
}

String _authenticatedUser;

void main() async  {
  _authenticatedUser = await _loginUser();
  print(_authenticatedUser);
  print('app loaded');
  runApp(new MyApp());
}

/// This is our starting point to the app.
class MyApp extends StatelessWidget {

  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Cluster',
      theme: ThemeData.dark(),
      initialRoute: '/',
      home: (_authenticatedUser != null) ? Home() : LoginHome(true),
      routes: {
        '/login': (context) => Login(),
        '/map': (context) => MapScreen(),
        '/addProposal': (context) => AddProposalScreen(),
        '/userProfile': (context) => UserProfile(true),
        '/home': (context) => Home(),
        '/my_proposals': (context) => MyProposals(),
        '/add_group': (context) => AddGroupScreen(),
        '/register': (context) => Register(),
        '/login_home_logout': (context) => LoginHome(true),
        '/verification_email': (context) => VerificationEmail(),
        '/forgot_pass': (context) => ForgotPass(),
      },
    );
  }
}
