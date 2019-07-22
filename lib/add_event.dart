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
import 'helper.dart';


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



class AddEventForm extends StatefulWidget {
  AddEventState createState() {
    return AddEventState();
  }
}

class AddEventState extends State<AddEventForm> {
  final TextEditingController _controllerPlace = TextEditingController();
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerSummary =
      TextEditingController(text: "");
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerTime = TextEditingController();

  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  File _image;
  //bool _uploadingImageInProgress = false;

  void chooseImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _pushEventToFirestoreWithoutImage(summary, geoPoint,
      title, date, time, place, context) async {
    print("yaman");
    await _firestore.collection('events').add({
      'summary': summary,
      'position': geoPoint.data,
      'title': title,
      'date': date,
      'time': time,
      'address': place,
    });
    Navigator.pop(context);
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
                apiKey: "AIzaSyDYtG5xhm17OtZbEi1PJMLuRctVn43xvgs",
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
                      apiKey: "AIzaSyDYtG5xhm17OtZbEi1PJMLuRctVn43xvgs");
                  GeocodingResponse response =
                      await geocoding.searchByAddress(_controllerPlace.text);
                  Location location = response.results[0].geometry.location;
                  GeoFirePoint geoPoint = geo.point(
                      latitude: location.lat, longitude: location.lng);
                  String title = _controllerTitle.text;
                  String summary = _controllerSummary.text;
                  String date = _controllerDate.text;
                  String time = _controllerTime.text;
                  String place = _controllerPlace.text;
                  final String uuid = Uuid().v1();
                  StorageUploadTask uploadTask;
                  // If image is not null, upload it through UploadTaskListTile
                  // which shows upload progress
                  if (_image != null) {
                    final UserId args =
                        ModalRoute.of(context).settings.arguments;
                    StorageReference storageRef =
                        FirebaseStorage.instance.ref().child(args.userId + uuid);
                    uploadTask = storageRef.putFile(_image);

                    var snackbar = new SnackBar(
                      duration: new Duration(seconds: 60),
                      content: new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("Uploading Image")
                        ],
                      ),
                    );
                    Scaffold.of(context).showSnackBar(snackbar);


                    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
                    String downloadUrl = await storageSnapshot.ref.getDownloadURL();

                    Scaffold.of(context).hideCurrentSnackBar();
                    snackbar = new SnackBar(
                      duration: new Duration(seconds: 60),
                      content: new Row(
                        children: <Widget>[
                          new CircularProgressIndicator(),
                          new Text("Publishing event")
                        ],
                      ),
                    );


                    await _firestore.collection('events').add({
                      'summary': summary,
                      'position': geoPoint.data,
                      'title': title,
                      'date': date,
                      'time': time,
                      'address': place,
                      'download_url': downloadUrl,
                    });
                    Navigator.of(context).pop();
                  } else {
                    // If image is null, do a straightforward upload
                    _pushEventToFirestoreWithoutImage(summary, geoPoint,
                        title, date, time, place, context);
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
    );
  }
}
