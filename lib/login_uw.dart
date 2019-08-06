import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Login extends StatefulWidget {
  final bool shouldLogout;

  Login(this.shouldLogout);

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
  bool _isLoggingIn = false;

  initState() {
    if (widget.shouldLogout) {
      googleSignIn.signOut();
    }
  }

  Future<void> createUserIfDoesntExist(FirebaseUser user) async {
    DocumentReference document =
        firestore.collection("users").document(user.uid);
    Firestore.instance.runTransaction((Transaction t) async {
      t.update(document, {
        "id": user.uid,
        "name": user.displayName,
        "photo_url": user.photoUrl,
      });
    });
    DocumentSnapshot documentSnap = await document.get();
    if (!documentSnap.exists) {
      document.setData({
        "id": user.uid,
        "name": user.displayName,
        "photo_url": user.photoUrl,
        "summary": ""
      });
    }
  }

  Future<FirebaseUser> _signIn(BuildContext context) async {
    setState(() {
      _isLoggingIn = true;
    });
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gSA.accessToken,
      idToken: gSA.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);


    DocumentReference document =
    firestore.collection("users").document(user.uid);
    DocumentSnapshot documentSnap = await document.get();
    if (!documentSnap.exists) {
      await document.setData({
        "id": user.uid,
        "name": user.displayName,
        "photo_url": user.photoUrl,
        "summary": ""
      });
    }
    Navigator.pushReplacementNamed(context, '/home',
        arguments: UserId(user.uid));


//    if (user.email.length > 7) {
//      if (user.email.substring(user.email.length - 7) == "@uw.edu") {
//        DocumentReference document =
//            firestore.collection("users").document(user.uid);
//        DocumentSnapshot documentSnap = await document.get();
//        if (!documentSnap.exists) {
//          await document.setData({
//            "id": user.uid,
//            "name": user.displayName,
//            "photo_url": user.photoUrl,
//            "summary": ""
//          });
//        }
//        Navigator.pushReplacementNamed(context, '/home',
//            arguments: UserId(user.uid));
//      }
//    } else {
//      var snackbar = new SnackBar(
//        duration: new Duration(seconds: 60),
//        content: new Row(
//          children: <Widget>[new Text("Login Unsuccessful")],
//        ),
//      );
//      Scaffold.of(context).showSnackBar(snackbar);
//      await googleSignIn.signOut();
//      await FirebaseAuth.instance.signOut();
//    }
    setState(() {
      _isLoggingIn = false;
    });
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
    if (!widget.shouldLogout) {
      _signIn(context);
    }
    return Scaffold(
        appBar: new AppBar(
          title: new Text("Welcome To Cluster"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _isLoggingIn
                    ? Center(
                        child: SpinKitFadingCircle(
                          itemBuilder: (_, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    index.isEven ? Colors.brown : Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Login with ",
                        style: TextStyle(
                            color: Colors.grey.shade300, fontSize: 20),
                      ),
                      Text(
                        "UW ",
                        style: TextStyle(
                            color: Color.fromRGBO(245, 200, 54, 300),
                            fontSize: 20),
                      ),
                      Text(
                        "Gmail",
                        style: TextStyle(
                            color: Colors.deepPurpleAccent.shade100,
                            fontSize: 20),
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
            )));
  }
}
