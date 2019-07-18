import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _controllerPlace = TextEditingController();
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerSummary = TextEditingController(text: "");
  final TextEditingController _controllerDate = TextEditingController();
  final TextEditingController _controllerTime = TextEditingController();

  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;
  DateTime dateTime = DateTime(2020);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            new ListTile(
                title: BasicDateField(_controllerDate)
            ),
            new ListTile(
                title: BasicTimeField(_controllerTime)
            ),
            new ListTile(
              title: PlacesAutocompleteField(
                apiKey: "AIzaSyDYtG5xhm17OtZbEi1PJMLuRctVn43xvgs",
                controller: _controllerPlace,
                hint: "Place",
              ),
            ),
            Container (
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
                  _firestore.collection('events').add({
                    'summary': summary,
                    'position': geoPoint.data,
                    'title': title,
                    'date': date,
                    'time': time,
                    'address': place,
                  });
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ),
          ],
        )
    );
  }
}