import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'helper.dart';

class Login extends StatefulWidget {
  LoginState createState() {
    return LoginState();
  }
}

///
/// This class represents the login page.
/// Uses Google Sign In with Firebase.
class LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  final Firestore firestore = Firestore.instance;

  Future<FirebaseUser> _signIn(BuildContext context) async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);

    if (user.email.length > 7) {
      if (user.email.substring(user.email.length - 7) == "@uw.edu") {
        Navigator.pushNamed(context, '/home', arguments: UserId(user.uid));
      }
    } else {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    }
    return user;
  }

  void _signOut(context) async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    final snackbar = new SnackBar(
        duration: new Duration(seconds: 1),
        content: Text("Successfully logged out"));
    Scaffold.of(context).showSnackBar(snackbar);
  }

  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Text(
                    "Login with ",
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 20),
                  ),
                  Text(
                    "UW ",
                    style: TextStyle(color: Color.fromRGBO(245, 200, 54, 300), fontSize: 20),
                  ),
                  Text(
                    "Gmail",
                    style: TextStyle(color: Colors.deepPurpleAccent.shade100, fontSize: 20),
                  )
              ],
            ),
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 20),
            ),
            GoogleSignInButton(
              onPressed: () => _signIn(context),
              text: "Sign In",
              borderRadius: 10,
            ),
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),
            new RaisedButton(
                elevation: 20,
                onPressed: () => _signOut(context),
                child: new Text("Sign Out"),
                color: Colors.grey.shade200,
                textColor: Colors.grey.shade800,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(10.0))),
          ],
        ));
  }
}
