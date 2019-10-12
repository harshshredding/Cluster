import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'helper.dart';

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
  TextEditingController _controllerEmail = TextEditingController(text: "");
  TextEditingController _controllerPassword = TextEditingController(text: "");
  String _error;
  bool _passVisible = false;
  String _chosenOrganization = "UW";
  Map<String, String> _orgToSuffix = {
    "UW": "@uw.edu",
    "Agilysys": "@agilysys.com"
  };

  String getSuffixFromEmail(String email) {
    String userEmail = email;
    int positionOfAt = userEmail.indexOf("@");
    if (positionOfAt != -1) {
      String organization = userEmail.substring(positionOfAt);
      return organization;
    }
    return null;
  }

  _login(BuildContext context) async {
    String givenSuffix = getSuffixFromEmail(_controllerEmail.text);
    if (_orgToSuffix[_chosenOrganization] != givenSuffix) {
      setState(() {
        _error = "Please enter email belonging to " + _chosenOrganization;
      });
      return;
    }
    try {
      FirebaseUser currentUser = (await _auth.signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text)).user;
      if (currentUser.isEmailVerified) {
        DocumentReference document =
            Firestore.instance
                .collection("kingdoms")
                .document(getUserOrganization(currentUser) ?? "")
                .collection("users")
                .document(currentUser.uid);
        DocumentSnapshot documentSnap = await document.get();
        if (!documentSnap.exists) {
          await document.setData({
            "id": currentUser.uid,
            "name": currentUser.displayName ?? "Default Name",
            "photo_url":
                "https://firebasestorage.googleapis.com/v0/b/cluster-c7373.appspot.com/o/coffee-shop.jpg?alt=media&token=da9722c7-3b81-492d-be60-5dc8b5c7111e",
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
        case "ERROR_INVALID_EMAIL":
          {
            _error = "address is malformed";
          }
          break;
        case "ERROR_WRONG_PASSWORD":
          {
            _error = "the password is wrong";
          }
          break;
        case "ERROR_USER_NOT_FOUND":
          {
            _error = "no user corresponding to the given email";
          }
          break;
        case "ERROR_USER_DISABLED":
          {
            _error = "user has been disabled";
          }
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          {
            _error = "there was too many attempts to sign in as this user";
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
          title: Text("Login"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
//              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _error != null
                    ? Center(
                        child: Text(_error),
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child:
                  Row(
                    children: <Widget>[
                      Text("Choose Organization: ", style: TextStyle(color: Colors.grey, fontSize: 17),)
                      ,
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: FormField(
                          builder: (FormFieldState state) {
                            return DropdownButton<String>(
                              value: _chosenOrganization,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 18,
                              elevation: 16,
                              style: TextStyle(
                                  color: Colors.grey
                              ),
                              underline: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                              onChanged: (String newKingdomValue) {
                                setState(() {
                                  _chosenOrganization = newKingdomValue;
                                });
                              },
                              items: <String>['UW', 'Agilysys']
                                  .map<DropdownMenuItem<String>>((String value) {
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
                  )
                  ,
                ),
                TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Organization email", hintText: "Organization email"),
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
                    child: RaisedButton(
                      shape: BeveledRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Text("Login"),
                      color: Colors.brown,
                      onPressed: () {
                        _login(context);
                      },
                      elevation: 10,
                    ),
                  ),
                )
              ],
            )));
  }
}
