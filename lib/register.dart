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
  TextEditingController _controllerEmail = TextEditingController(text: "");
  TextEditingController _controllerPassword = TextEditingController(text: "");
  String _error;
  FirebaseUser _userToVerify;
  bool _passVisible = false;
  String _chosenOrganization = "UW";
  Map<String, String> _orgToSuffix = {
    "UW": "@uw.edu",
    "Agilysys": "@agilysys.com"
  };

  void _resendVerificationEmail(BuildContext context) async {
    try {
      await _userToVerify.sendEmailVerification();
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

  String getSuffixFromEmail(String email) {
    String userEmail = email;
    int positionOfAt = userEmail.indexOf("@");
    if (positionOfAt != -1) {
      String organization = userEmail.substring(positionOfAt);
      return organization;
    }
    return null;
  }
  
  
  void _register(BuildContext context) async {
    String givenSuffix = getSuffixFromEmail(_controllerEmail.text);
    if (_orgToSuffix[_chosenOrganization] != givenSuffix) {
      setState(() {
        _error = "Please enter email belonging to " + _chosenOrganization;
      });
      return;
    }
    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      await user.sendEmailVerification();
      var snackbar = new SnackBar(
        duration: new Duration(seconds: 4),
        content: Text("Verfication Email Sent"),
        backgroundColor: Colors.green,
      );
      Scaffold.of(context).showSnackBar(snackbar);
      setState(() {
        _userToVerify = user;
      });
    } catch (exp) {
      print(exp);
      switch (exp.code) {
        case "ERROR_WEAK_PASSWORD":
          {
            _error = "password is not strong enough";
          }
          break;
        case "ERROR_INVALID_EMAIL":
          {
            _error = "address is malformed";
          }
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE":
          {
            _error = "email is already in use";
          }
          break;
        default:
          {
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
                _userToVerify != null
                    ? Center(
                        child: Builder(builder: (BuildContext context) {
                          return RaisedButton(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Icon(Icons.send),
                                  margin: EdgeInsets.only(right: 10),
                                ),
                                Text("Resend Verification Email")
                              ],
                            ),
                            onPressed: () {
                              _resendVerificationEmail(context);
                            },
                          );
                        }),
                      )
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                _error != null
                    ? Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(_error),
                        ),
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Choose Organization: ",
                        style: TextStyle(color: Colors.grey, fontSize: 17),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: FormField(
                          builder: (FormFieldState state) {
                            return DropdownButton<String>(
                              value: _chosenOrganization,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 18,
                              elevation: 16,
                              style: TextStyle(color: Colors.grey),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String newKingdomValue) {
                                setState(() {
                                  _chosenOrganization = newKingdomValue;
                                });
                              },
                              items: <String>[
                                'UW',
                                'Agilysys'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                TextFormField(
                  decoration: new InputDecoration(
                      labelText: "UW email", hintText: "UW email"),
                  controller: _controllerEmail,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: new InputDecoration(
                            labelText: "password", hintText: "password"),
                        controller: _controllerPassword,
                        obscureText: !_passVisible,
                      ),
                    ),
                    _passVisible
                        ? IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            onPressed: () {
                              setState(() {
                                _passVisible = !_passVisible;
                              });
                            })
                        : IconButton(
                            icon: Icon(
                              Icons.remove_red_eye,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _passVisible = !_passVisible;
                              });
                            })
                  ],
                ),
                Builder(builder: (BuildContext context) {
                  return Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Center(
                      child: RaisedButton(
                        shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("Register"),
                        color: Colors.brown,
                        onPressed: () {
                          _register(context);
                        },
                        elevation: 10,
                      ),
                    ),
                  );
                }),
              ],
            )));
  }
}
