import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:CoffeeShop/helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This widget helps select date interactively.
class BasicDateField extends StatelessWidget {
  final format = DateFormat("yyyy-MM-dd");

  final TextEditingController _controllerDate;

  BasicDateField(this._controllerDate);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) {
          return showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? DateTime.now(),
              lastDate: DateTime(2100));
        },
        decoration: new InputDecoration(hintText: "date"),
        controller: _controllerDate,
      ),
    ]);
  }
}

/// This widget helps select date interactively.
class BasicTimeField extends StatelessWidget {
  final format = DateFormat("HH:mm");

  final TextEditingController _controllerTime;

  BasicTimeField(this._controllerTime);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      DateTimeField(
        format: format,
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
        },
        decoration: new InputDecoration(hintText: "time"),
        controller: _controllerTime,
      ),
    ]);
  }
}

/// scaffolding of the add event screen
class AddEventScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: AddEventForm(),
    );
  }
}

/// The forms user fills out to create an event.
class AddEventForm extends StatefulWidget {
  AddEventState createState() {
    return AddEventState();
  }
}


class AddEventState extends State<AddEventForm> {
  final TextEditingController _controllerPlace = TextEditingController();
  final TextEditingController _controllerTitle = TextEditingController();
  // IMPORTANT !!!!!!!
  // Had to initialize the below controller with empty string for the entire
  // form to work. This is really weird but it seems to be working.
  final TextEditingController _controllerSummary =
      TextEditingController(text: "");
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerTime = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  // Current selected image
  File _image;

  @override
  void initState() {
    super.initState();
    _googleSignIn.signInSilently();
  }

  /// choose an image and display it on the screen by changing state
  void chooseImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<DocumentReference> _pushEventToFirestoreWithoutImage(
      dynamic summary, dynamic geoPoint, dynamic title, dynamic date,
      dynamic time, dynamic place, dynamic userId, dynamic userPhotoUrl,
      dynamic userDisplayName) async {
    return _firestore.collection('events').add(<String, dynamic>{
      'summary': summary,
      'position': geoPoint.data,
      'title': title,
      'date': date,
      'time': time,
      'address': place,
      'user_id': userId,
      'user_photo_url': userPhotoUrl,
      'user_display_name': userDisplayName
    });
  }

  Future<DocumentReference> _pushEventToFirestoreWithImage(
      dynamic summary, dynamic geoPoint, dynamic title, dynamic date, dynamic time,
      dynamic place, dynamic downloadUrl,
      dynamic userId, dynamic userPhotoUrl,
      dynamic userDisplayName) async {
    return _firestore.collection('events').add(<String, dynamic>{
      'summary': summary,
      'position': geoPoint.data,
      'title': title,
      'date': date,
      'time': time,
      'address': place,
      'download_url': downloadUrl,
      'user_id': userId,
      'user_photo_url': userPhotoUrl,
      'user_display_name': userDisplayName
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        new ListTile(
          title: new TextField(
            decoration: new InputDecoration(hintText: "Title"),
            controller: _controllerTitle,
          ),
        ),
        new ListTile(
          title: new TextFormField(
            decoration: new InputDecoration(hintText: "Summary"),
            maxLines: null,
            controller: _controllerSummary,
          ),
        ),
        new ListTile(title: BasicDateField(_controllerDate)),
        new ListTile(title: BasicTimeField(_controllerTime)),
        new ListTile(
          title: PlacesAutocompleteField(
            apiKey: "AIzaSyA4rqnzacOOLnpj9pM5WMMl-DO3Zr5IYqw",
            controller: _controllerPlace,
            hint: "Place",
          ),
        ),
        new ListTile(
          title: RaisedButton(
            onPressed: chooseImage,
            child: Text('Upload Image'),
          ),
        ),
        _image == null ? Text("no image selected") : Image.file(_image),
        Container(
          padding: const EdgeInsets.all(20),
          child: RaisedButton(
            onPressed: () async {
              print("I got pressed nooooo");
              final geocoding = new GoogleMapsGeocoding(
                  apiKey: "AIzaSyA4rqnzacOOLnpj9pM5WMMl-DO3Zr5IYqw");
              GeocodingResponse response =
                  await geocoding.searchByAddress(_controllerPlace.text);
              Location location = response.results[0].geometry.location;
              GeoFirePoint geoPoint =
                  geo.point(latitude: location.lat, longitude: location.lng);
              String title = _controllerTitle.text;
              String summary = _controllerSummary.text;
              String date = _controllerDate.text;
              String time = _controllerTime.text;
              String place = _controllerPlace.text;
              GoogleSignInAccount user = await _googleSignIn.signIn();
              FirebaseUser fireUser = await FirebaseAuth.instance.currentUser();
              String userId = fireUser.uid;
              String userPhotoUrl = user.photoUrl;
              String userDisplayName = user.displayName;

              // If image is not null, upload it through UploadTaskListTile
              // which shows upload progress
              if (_image != null) {
                final String uuid = Uuid().v1();
                final UserId args = ModalRoute.of(context).settings.arguments;
                StorageReference storageRef =
                    FirebaseStorage.instance.ref().child(args.userId + uuid);
                StorageUploadTask uploadTask = storageRef.putFile(_image);

                // Show a snackbar
                var snackbar = SnackBar(
                  duration: Duration(seconds: 60),
                  content: Row(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text("Uploading Image")
                    ],
                  ),
                );
                Scaffold.of(context).showSnackBar(snackbar);

                StorageTaskSnapshot storageSnapshot =
                    await uploadTask.onComplete;
                String downloadUrl = await storageSnapshot.ref.getDownloadURL();

                Scaffold.of(context).hideCurrentSnackBar();
                snackbar = new SnackBar(
                  duration: new Duration(seconds: 60),
                  content: new Row(
                    children: <Widget>[
                       CircularProgressIndicator(),
                       Text("Publishing event")
                    ],
                  ),
                );

                Scaffold.of(context).showSnackBar(snackbar);
                await _pushEventToFirestoreWithImage(summary, geoPoint, title,
                    date, time, place, downloadUrl, userId, userPhotoUrl, userDisplayName);

              } else {
                // If image is null, do a straightforward upload
                await _pushEventToFirestoreWithoutImage(
                    summary, geoPoint, title, date, time, place, userId, userPhotoUrl, userDisplayName);
              }

              Navigator.of(context).pop();
            },
            child: Text('Submit'),
          ),
        ),
      ],
    );
  }
}
