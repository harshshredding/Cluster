import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

///
/// This class represents the login page.
/// Uses Google Sign In with Firebase.
///
class Login extends StatefulWidget {
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _controllerEmail =
  TextEditingController(text: "");
  TextEditingController _controllerPassword =
  TextEditingController(text: "");
  String _error;

  _login(BuildContext context) async {
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text);
      if (user.isEmailVerified) {
        DocumentReference document =
        Firestore.instance.collection("users").document(user.uid);
        DocumentSnapshot documentSnap = await document.get();
        if (!documentSnap.exists) {
          await document.setData({
            "id": user.uid,
            "name": user.displayName ?? "Default Name",
            "photo_url": "https://firebasestorage.googleapis.com/v0/b/cluster-c7373.appspot.com/o/coffee-shop.jpg?alt=media&token=da9722c7-3b81-492d-be60-5dc8b5c7111e",
            "summary": ""
          });
        }
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _error = "email is not verified";
        });
      }
    } catch (exp) {
      print(exp.code);
      switch (exp.code) {
        case "ERROR_INVALID_EMAIL": {
          _error = "address is malformed";
        }
        break;
        case "ERROR_WRONG_PASSWORD": {
          _error = "the password is wrong";
        }
        break;
        case "ERROR_USER_NOT_FOUND": {
          _error = "no user corresponding to the given email";
        }
        break;
        case "ERROR_USER_DISABLED": {
          _error = "user has been disabled";
        }
        break;
        case "ERROR_TOO_MANY_REQUESTS": {
          _error = "there was too many attempts to sign in as this user";
        }
        break;
        default: {
          _error = "some error occured";
        }
      }
      setState(() {});
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _error != null ? Center(child: Text(_error),) : Container(height: 0, width: 0,)
                ,
                TextFormField(
                  decoration: new InputDecoration(labelText: "UW email", hintText: "UW email"),
                  controller: _controllerEmail,
                ),
                TextFormField(
                  decoration: new InputDecoration(labelText: "password", hintText: "password"),
                  controller: _controllerPassword,
                  obscureText: true,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: RaisedButton(
                      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Text("Login"),
                      color: Colors.brown,
                      onPressed: () {_login(context);},
                      elevation: 10,
                    ),
                  ),
                )
              ],
            ))
    );
  }
}