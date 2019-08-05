import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'my_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';


class UserProfile extends StatefulWidget {
  final String userDocumentId;
  final bool editable;
  UserProfile(this.editable, {this.userDocumentId});
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


  Widget getUserProfile(BuildContext context) {
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

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
            title: Text("Profile"),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: widget.editable ?
              _editMode ? IconButton(
                icon: Icon(Icons.edit, color: Colors.red,),
                onPressed: switchEditMode,
              ): IconButton(
                icon: Icon(Icons.edit, color: Colors.white,),
                onPressed: switchEditMode,
              )
              :
              Container(width: 0, height: 0,),
            )
          ],),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: getUserProfile(context),
        )
    );
  }
}

class UserDetails extends StatefulWidget {
  final String name;
  final String photoUrl;
  final String summary;
  final TextEditingController _controllerSummary;
  final TextEditingController _controllerLinkedn;
  final bool _editMode;
  final bool editable;

  UserDetails(this.editable, this.name, this.photoUrl, this.summary,
      this._controllerSummary, this._controllerLinkedn, this._editMode);
  
  UserDetailsState createState() {
    return UserDetailsState();
  }
}

class UserDetailsState extends State<UserDetails> {
  
  File _selectedImage;
  
  /// choose an image and display it on the screen by changing state
  void chooseImage() async {
    if (widget._editMode) {
      File unCroppedImage = await ImagePicker.pickImage(source: ImageSource.gallery);
      File croppedImage = await ImageCropper.cropImage(sourcePath: unCroppedImage.path,
          ratioX: 1.0,
          ratioY: 1.0,
          maxWidth: 512,
          maxHeight: 512);
      setState(() {
        _selectedImage = croppedImage;
      });
    }
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey.shade600,
          child: Column(
            children: <Widget>[
              _selectedImage == null ?
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.photoUrl),
                    radius: 80,
                  ),
                  onTap: chooseImage,
                ),
                margin: EdgeInsets.only(top: 20),
              )
                  :
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  child: CircleAvatar(
                    backgroundImage: FileImage(_selectedImage),
                    radius: 80,
                  ),
                  onTap: chooseImage,
                ),
                margin: EdgeInsets.only(top: 20),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(widget.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Trajan Pro',
                    )),
                margin: EdgeInsets.all(20),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 35, left: 22),
          alignment: Alignment.centerLeft,
          child: Text('ABOUT ME',
              style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'Trajan Pro',
                  color: Colors.grey.shade200)),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: TextFormField(
            enabled: widget._editMode,
            maxLines: 10,
            controller: widget._controllerSummary,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          margin: EdgeInsets.all(20),
        ),
        Container(
          margin: EdgeInsets.only(top: 20, left: 22),
          alignment: Alignment.centerLeft,
          child: Text('LINKEDN',
              style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'Heebo-Black',
                  color: Colors.grey.shade200)),
        ),
        (widget._editMode)
            ? Container(
                alignment: Alignment.centerLeft,
                child: TextField(
                  enabled: widget._editMode,
                  controller: widget._controllerLinkedn,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Paste URL"),
                ),
                margin: EdgeInsets.all(20),
              )
            : Container(
                width: 0,
                height: 0,
              ),
        (widget._controllerLinkedn.text != "" && widget._controllerLinkedn.text != null)
            ? !widget._editMode
                ? Container(
                    margin: EdgeInsets.only(top: 20, left: 22),
                    alignment: Alignment.centerLeft,
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    LinkednPage(widget._controllerLinkedn.text)));
                      },
                      child: Text(
                        "My Linkedn",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                : Container(
                    height: 0,
                    width: 0,
                  )
            : !widget._editMode
                ? Container(
                    margin: EdgeInsets.only(top: 20, left: 22),
                    alignment: Alignment.centerLeft,
                    child: RaisedButton(
                      onPressed: null,
                      color: Colors.grey,
                      child: Text(
                        "Linkedn N/A",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                : Container(
                    height: 0,
                    width: 0,
                  ),
      ],
    );
  }
}
