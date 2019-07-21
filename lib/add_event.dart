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


class MyGlobals {
  GlobalKey _scaffoldKey;
  MyGlobals() {
    _scaffoldKey = GlobalKey();
  }
  GlobalKey get scaffoldKey => _scaffoldKey;
}


class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile({Key key, this.task, this.onDownload})
      : super(key: key);

  final StorageUploadTask task;
  final Function onDownload;

  String get status {
    String result;
    if (task.isComplete) {
      if (task.isSuccessful) {
        result = 'Complete';
      } else if (task.isCanceled) {
        result = 'Canceled';
      } else {
        result = 'Failed ERROR: ${task.lastSnapshot.error}';
      }
    } else if (task.isInProgress) {
      result = 'Uploading';
    } else if (task.isPaused) {
      result = 'Paused';
    }
    return result;
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }

  void uploadToFireStore(StorageTaskSnapshot snapshot, context) async {
    String downloadUrl = await snapshot.ref.getDownloadURL();
    await onDownload(downloadUrl, context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,
          AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {
        Widget subtitle;
        if (asyncSnapshot.hasData) {
          final StorageTaskEvent event = asyncSnapshot.data;
          final StorageTaskSnapshot snapshot = event.snapshot;
          subtitle = Text('$status: ${_bytesTransferred(snapshot)} bytes sent');
          if (task.isComplete && task.isSuccessful) {
            uploadToFireStore(snapshot, context);
          }
        } else {
          subtitle = const Text('Starting...');
        }
        return Dismissible(
          key: Key(task.hashCode.toString()),
          child: ListTile(
            title: Text('Upload Task #${task.hashCode}'),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Offstage(
                  offstage: !task.isInProgress,
                  child: IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => task.pause(),
                  ),
                ),
                Offstage(
                  offstage: !task.isPaused,
                  child: IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => task.resume(),
                  ),
                ),
                Offstage(
                  offstage: task.isComplete,
                  child: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => task.cancel(),
                  ),
                ),
                Offstage(
                  offstage: !(task.isComplete && task.isSuccessful),
                  child: IconButton(
                    icon: const Icon(
                      Icons.cloud_done,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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

class AddEventScreen extends StatefulWidget {
  AddEventState createState() {
    return AddEventState();
  }
}

class AddEventState extends State<AddEventScreen> {

  MyGlobals myGlobals = MyGlobals();
  final TextEditingController _controllerPlace = TextEditingController();
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerSummary =
      TextEditingController(text: "");
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerTime = TextEditingController();

  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  File _image;
  StorageUploadTask _uploadTask;
  Function _uploadToFirestore;

  void chooseImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  void _pushEventToFirestoreWithoutImage(summary, geoPoint,
      title, date, time, place, context) async {
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
    return Scaffold(
        key: myGlobals.scaffoldKey,
        appBar: AppBar(
          title: Text('Datetime Picker'),
        ),
        body: ListView(
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
            _uploadTask == null
                ? Container()
                : UploadTaskListTile(
                    task: _uploadTask, onDownload: _uploadToFirestore),
            Container(
              padding: const EdgeInsets.all(20),
              child: RaisedButton(
                onPressed: () async {
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
                    var uploadFunction = (String downloadUrl, contextChild) async {
                      final snackbar = new SnackBar(
                        duration: new Duration(seconds: 20),
                        content: new Row(
                          children: <Widget>[
                            new CircularProgressIndicator(),
                            new Text("Creating Event")
                          ],
                        ),
                      );
                      Scaffold.of(contextChild).showSnackBar(snackbar);
                      await _firestore.collection('events').add({
                        'summary': summary,
                        'position': geoPoint.data,
                        'title': title,
                        'date': date,
                        'time': time,
                        'address': place,
                        'download_url': downloadUrl,
                      });
                      Navigator.of(contextChild).pop();
                    };
                    setState(() {
                      _uploadTask = uploadTask;
                      _uploadToFirestore = uploadFunction;
                    });
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
        ));
  }
}
