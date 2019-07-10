import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

/// This screen displays a form that the user
/// fills to make an event.
/// If the event has been successfully made, the user can find it in MyEvents
/// list.
class AddEventScreen extends StatefulWidget {
  AddEventState createState() {
    return AddEventState();
  }

}

class AddEventState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  Geoflutterfire geo = Geoflutterfire();
  Firestore _firestore = Firestore.instance;

  Widget build(BuildContext context) {
    final _controllerPlace = new TextEditingController(text: "");
    final _controllerTitle = new TextEditingController(text: "");
    final _controllerSummary = new TextEditingController(text: "");

    String validatorFunc(value) {
      if (value.isEmpty) {
        return 'Enter some text';
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Make Event'),
      ),
      body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              PlacesAutocompleteField(
                apiKey: "AIzaSyDYtG5xhm17OtZbEi1PJMLuRctVn43xvgs",
                controller: _controllerPlace,
                hint: "Place",
              ),
              new ListTile(
                title: new TextFormField(
                  validator: validatorFunc,
                  decoration: new InputDecoration(
                      hintText: "Title"
                  ),
                  controller: _controllerTitle,
                ),
              ),
              new ListTile(
                title: new TextFormField(
                  //controller: _controller,
                  validator: validatorFunc,
                  decoration: new InputDecoration(
                      hintText: "Summary"
                  ),
                  maxLines: null,
                  controller: _controllerSummary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () async {
                    final geocoding = new GoogleMapsGeocoding(
                        apiKey: "AIzaSyDYtG5xhm17OtZbEi1PJMLuRctVn43xvgs"
                    );
                    GeocodingResponse response = await geocoding
                      .searchByAddress(_controllerPlace.text);
                    Location location = response.results[0].geometry.location;
                    GeoFirePoint geoPoint =
                      geo.point(latitude: location.lat, longitude: location.lng);
                    String title = _controllerTitle.text;
                    String summary = _controllerSummary.text;
                    _firestore.collection('events').add({
                      'summary': summary,
                      'position': geoPoint.data,
                      'title': title
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          )
      ),
    );
  }
}