import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'helper.dart';

///
/// This class represents the login page.
/// Uses Google Sign In with Firebase.
///
class Login extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  Firestore firestore = Firestore.instance;

  Future<FirebaseUser> _signIn(BuildContext context) async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);

    Navigator.pushNamed(
        context,
        '/map',
        arguments: UserId(user.uid)
    );

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
            GoogleSignInButton(
              onPressed: () => _signIn(context).then((FirebaseUser user) async {
                    DocumentReference document = firestore.collection("users").document(user.uid);
                    Firestore.instance.runTransaction((Transaction t) async {
                      t.update(document, {
                        "id" : user.uid,
                        "name": user.displayName,
                        "photo_url": user.photoUrl,
                      });
                    });
                    DocumentSnapshot documentSnap = await document.get();
                    if (!documentSnap.exists) {
                      document.setData({
                        "id" : user.uid,
                        "name": user.displayName,
                        "photo_url": user.photoUrl,
                        "summary": ""
                      });
                    }
                  }).catchError((e) => print(e)),
              text: "Sign In",
              borderRadius: 10,
            ),
            new Padding(
              padding: const EdgeInsets.all(10.0),
            ),
            new RaisedButton(
                onPressed: () => _signOut(context),
                child: new Text("Sign Out"),
                color: Color.fromRGBO(255, 153, 51, 20),
                textColor: Colors.white,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0))),
          ],
        ));
  }
}
