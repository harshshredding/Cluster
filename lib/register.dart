import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

///
/// This class represents the login page.
///
class Register extends StatefulWidget {
  RegisterState createState() {
    return RegisterState();
  }
}

class RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _controllerEmail =
  TextEditingController(text: "");
  TextEditingController _controllerPassword =
  TextEditingController(text: "");
  String _error;

  void _register(BuildContext context) async {
    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      await user.sendEmailVerification();
      var snackbar = new SnackBar(
          duration: new Duration(seconds: 10),
          content: Text("Verfication Email Sent")
      );
      Scaffold.of(context).showSnackBar(snackbar);
    } catch (exp) {
      print(exp);
      switch (exp.code) {
        case "ERROR_WEAK_PASSWORD" :  {
          _error = "password is not strong enough";
        }
        break;
        case "ERROR_INVALID_EMAIL": {
          _error = "address is malformed";
        }
        break;
        case "ERROR_EMAIL_ALREADY_IN_USE": {
          _error = "email is already in use";
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
        title: Text("Register"),
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
                decoration: new InputDecoration(labelText: "new password", hintText: "new password"),
                controller: _controllerPassword,
                obscureText: true,
              ),
              Builder(builder: (BuildContext context) {
                return Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: RaisedButton(
                      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Text("Register"),
                      color: Colors.brown,
                      onPressed: () {_register(context);},
                      elevation: 10,
                    ),
                  ),
                );
              }),
            ],
          ))
    );
  }
}
