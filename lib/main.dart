import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget 
{
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print("signed in " + user.displayName);
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
              onPressed: () => _signIn()
              .then((FirebaseUser user) => print(user))
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