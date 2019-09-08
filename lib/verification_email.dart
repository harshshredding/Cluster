import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///
/// This class represents the login page.
/// Uses Google Sign In with Firebase.
///
class VerificationEmail extends StatefulWidget {
  VerificationEmailState createState() {
    return VerificationEmailState();
  }
}

class VerificationEmailState extends State<VerificationEmail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _controllerEmail =
  TextEditingController(text: "");
  TextEditingController _controllerPassword =
  TextEditingController(text: "");
  String _error;
  bool _passVisible = false;

  void _login(BuildContext context) async {
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text);
      if (user.isEmailVerified) {
        setState(() {
          _error = "email is already verified";
        });
      } else {
        try {
          await user.sendEmailVerification();
          var snackbar = new SnackBar(
              duration: new Duration(seconds: 4),
              content: Text("Verfication Email Sent"),
              backgroundColor: Colors.green,
          );
          Scaffold.of(context).showSnackBar(snackbar);
        } catch (err) {
          print("failed to send verification email");
          print(err);
        }
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child:TextFormField(
                        decoration: new InputDecoration(
                            labelText: "password", hintText: "password"),
                        controller: _controllerPassword,
                        obscureText: !_passVisible,
                      ) ,
                    )
                    ,
                    _passVisible ?
                    IconButton(
                        icon: Icon(Icons.remove_red_eye), onPressed: () {
                      setState(() {
                        _passVisible = !_passVisible;
                      });
                    }) :
                    IconButton(
                        icon: Icon(Icons.remove_red_eye, color: Colors.grey,), onPressed: () {
                      setState(() {
                        _passVisible = !_passVisible;
                      });
                    })
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Builder(builder: (BuildContext context) {
                      return RaisedButton(
                        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Text("Send Verification Email"),
                        color: Colors.brown,
                        onPressed: () {_login(context);},
                        elevation: 10,
                      );
                    }),
                  ),
                )
              ],
            ))
    );
  }
}