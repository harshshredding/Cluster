import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_events.dart';
import 'package:flutter/cupertino.dart';

class UserProfileHeader extends StatelessWidget {
  final String userDocumentId;
  final bool editable;

  UserProfileHeader(this.editable, {this.userDocumentId});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: UserProfile(userDocumentId, editable));
  }
}

class UserProfile extends StatefulWidget {
  final String userDocumentId;
  final bool editable;
  UserProfile(this.userDocumentId, this.editable);
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  Future<FirebaseUser> user = FirebaseAuth.instance.currentUser();
  Future<DocumentSnapshot> userDocument;
  final TextEditingController _controllerSummary =
      TextEditingController(text: "");
  final TextEditingController _controllerLinkedn =
      TextEditingController(text: "");
  bool _editMode = false;
  bool _hasEdited = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.userDocumentId == null) {
      getUserDetails();
    } else {
      getUserDetailsWithId(widget.userDocumentId);
    }
  }

  void switchEditMode() {
    setState(() {
      _editMode = !_editMode;
      _hasEdited = true;
    });
  }

  void getUserDetails() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      userDocument =
          Firestore.instance.collection("users").document(user.uid).get();
    });
  }

  void getUserDetailsWithId(String userId) async {
    setState(() {
      userDocument =
          Firestore.instance.collection("users").document(userId).get();
    });
  }

  void submitUserDetails(BuildContext context) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot document =
        await Firestore.instance.collection("users").document(user.uid).get();
    if (document.exists) {
      document.data["summary"] = _controllerSummary.text;
      document.data["linkedn"] = _controllerLinkedn.text;
      await Firestore.instance
          .collection("users")
          .document(user.uid)
          .setData(document.data);
      final snackBar = SnackBar(content: Text('Profile Updated'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Widget build(BuildContext context) {
    if (userDocument != null) {
      return FutureBuilder<DocumentSnapshot>(
          future: userDocument,
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (!_hasEdited) {
                    _controllerSummary.text = (snapshot.data.data["summary"] ??
                        _controllerSummary.text);
                    _controllerLinkedn.text = (snapshot.data.data["linkedn"] ??
                        _controllerLinkedn.text);
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error occured"));
                  } else {
                    return SingleChildScrollView(
                        child: Column(children: [
                      widget.editable
                          ? Container(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: _editMode
                                    ? Icon(
                                        Icons.edit,
                                        color: Colors.red,
                                      )
                                    : Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                onPressed: switchEditMode,
                              ))
                          : Container(),
                      UserDetails(
                          widget.editable,
                          snapshot.data.data['name'] ?? "",
                          snapshot.data.data['photo_url'] ?? "",
                          snapshot.data.data['summary'] ?? "",
                          _controllerSummary,
                          _controllerLinkedn,
                          _editMode),
                      _editMode
                          ? RaisedButton(
                              onPressed: () {
                                submitUserDetails(context);
                              },
                              child: Text("Save Changes"),
                            )
                          : Container()
                    ]));
                  }
                }
                break;
              case ConnectionState.active:
              case ConnectionState.waiting:
              case ConnectionState.none:
                break;
            }
            return Container();
          });
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}

class UserDetails extends StatelessWidget {
  final String name;
  final String photoUrl;
  final String summary;
  final TextEditingController _controllerSummary;
  final TextEditingController _controllerLinkedn;
  final bool _editMode;
  final bool editable;

  UserDetails(this.editable, this.name, this.photoUrl, this.summary,
      this._controllerSummary, this._controllerLinkedn, this._editMode);

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Color.fromRGBO(232, 233, 233, 100),
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(photoUrl),
                  radius: 50,
                ),
                margin: EdgeInsets.only(top: 20),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(name,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Heebo-Black',
                    )),
                margin: EdgeInsets.all(20),
              ),
            ],
          ),
        ),
        editable
            ? Container(
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push<void>(CupertinoPageRoute(
                        builder: (context) => MyEvents(),
                        fullscreenDialog: true));
                  },
                  child: Text("My Events"),
                ),
              )
            : Container(),
        Container(
          margin: EdgeInsets.only(top: 35, left: 20),
          alignment: Alignment.centerLeft,
          child: Text('ABOUT ME',
              style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'Heebo-Black',
                  color: Colors.grey.shade900)),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            enabled: _editMode,
            maxLines: null,
            controller: _controllerSummary,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          margin: EdgeInsets.all(20),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, left: 20),
          alignment: Alignment.centerLeft,
          child: Text('LINKEDN',
              style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'Heebo-Black',
                  color: Colors.grey.shade900)),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextField(
            enabled: _editMode,
            controller: _controllerLinkedn,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          margin: EdgeInsets.all(20),
        ),
      ],
    );
  }
}
