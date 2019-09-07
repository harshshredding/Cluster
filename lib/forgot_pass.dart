import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

///
/// This class represents the login page.
/// Uses Google Sign In with Firebase.
///
class ForgotPass extends StatefulWidget {
  ForgotPassState createState() {
    return ForgotPassState();
  }
}

class ForgotPassState extends State<ForgotPass> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _controllerEmail =
  TextEditingController(text: "");
  String _error;

  void _sendEmail(BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: _controllerEmail.text);
      var snackbar = new SnackBar(
          duration: new Duration(seconds: 4),
          content: Text("Reset Password Email Sent"));
      Scaffold.of(context).showSnackBar(snackbar);
    } catch (exp) {
      print(exp.code);
      switch (exp.code) {
        case "ERROR_INVALID_EMAIL": {
          _error = "address is malformed";
        }
        break;
        case "ERROR_USER_NOT_FOUND": {
          _error = "no user corresponding to the given email";
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
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Builder(builder: (BuildContext context) {
                      return RaisedButton(
                        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Text("Send Reset Email"),
                        color: Colors.brown,
                        onPressed: () {_sendEmail(context);},
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