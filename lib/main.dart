import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'helper.dart';
import 'map.dart';
import 'add_event.dart';
import 'test.dart';

void main() => runApp(new MyApp());

/// This is our starting point to the app.
class MyApp extends StatelessWidget 
{
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      initialRoute: '/',
      routes: {
        '/map': (context) => MapScreen(),
        '/addEvent': (context) => AddEventScreen()
      },
    );
  }
}

///
/// This class represents the login page.
/// We currently use Google Sign In with Firebase.
/// FireBase is super convenient !
///
class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn(BuildContext context) async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);

    print("signed in " + user.displayName + " " + user.uid);
    Navigator.pushNamed(
        context,
        '/map',
        arguments: UserId(user.uid)
    );
    return user;
  }

  void _signOut() {
    googleSignIn.signOut();
    print("User Signed out");
  }



  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Firebase demo"),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(
              onPressed: () => _signIn(context)
              .then((FirebaseUser user){
                print(user);
              })
              .catchError((e) => print(e)),
              child: new Text("Sign In"),
              color: Colors.green,
            ),
            new Padding(padding: const EdgeInsets.all(10.0),),
            new RaisedButton(
              onPressed: () => _signOut(),
              child: new Text("Sign Out"),
              color: Colors.red,
            ),
          ],
        )
      ),
    );
  }
}
