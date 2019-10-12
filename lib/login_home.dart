import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// This page represents the first screen that users when they first
/// open the app. It will show them an option to register.
class LoginHome extends StatefulWidget {
  final bool shouldLogout;

  LoginHome(this.shouldLogout);

  LoginHomeState createState() {
    return LoginHomeState();
  }
}

///
/// This class represents the login page.
/// Uses Google Sign In with Firebase.
class LoginHomeState extends State<LoginHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore firestore = Firestore.instance;
  bool _isLoggingIn = false;

  initState() {
    super.initState();
    if (widget.shouldLogout) {
      print("signing out");
      _auth.signOut();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          title: new Text("Welcome To CofeeShop"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _isLoggingIn
                    ? Container(
                        margin: EdgeInsets.only(bottom: 25),
                        child: Center(
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
                        ))
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                new RaisedButton(
                    elevation: 20,
                    onPressed: () => Navigator.pushNamed(context, "/login"),
                    child: new Text("Login"),
                    color: Colors.grey.shade200,
                    textColor: Colors.grey.shade800,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0))),
                new Padding(
                  padding: const EdgeInsets.all(10.0),
                ),
                new RaisedButton(
                    elevation: 20,
                    onPressed: () => Navigator.pushNamed(context, "/register"),
                    child: new Text("Register"),
                    color: Colors.grey.shade200,
                    textColor: Colors.grey.shade800,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0))),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new RaisedButton(
                          elevation: 0,
                          onPressed: () => Navigator.pushNamed(context, "/forgot_pass"),
                          child: new Text("Forgot Pass"),
                          color: Colors.brown,
                          textColor: Colors.white,
                          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      new RaisedButton(
                          elevation: 0,
                          onPressed: () => Navigator.pushNamed(context, "/verification_email"),
                          child: new Text("Resend Verification"),
                          color: Colors.brown,
                          textColor: Colors.white,
                          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)))
                    ],
                  ),
                )
                ,
              ],
            )));
  }
}
