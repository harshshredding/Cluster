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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'tag_selector.dart';

/// scaffolding of the add event screen
class AddEventScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Proposal'),
      ),
      body: Center(child: AddEventForm()),
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
  final TextEditingController _controllerTitle = TextEditingController();
  // IMPORTANT !!!!!!!
  // Had to initialize the below controller with empty string for the entire
  // form to work. This is really weird but it seems to be working.
  final TextEditingController _controllerSummary =
      TextEditingController(text: "");
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Firestore _firestore = Firestore.instance;
  List<String> categoriesSelected = new List();

  @override
  void initState() {
    super.initState();
    _googleSignIn.signInSilently();
  }

  Widget makeChips() {
    List<Widget> allChips = new List();
    for (String category in categoriesSelected) {
      allChips.add(createChip(category));
    }
    return Wrap(
      children: allChips,
    );
  }

  Widget createChip(String category) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        child:  Chip(
          label: Text(category),
          backgroundColor: Colors.blueGrey,
        )
      ),
      onTap: () {
        setState(() {
          if (categoriesSelected.contains(category)) {
            categoriesSelected.remove(category);
          } else {
            categoriesSelected.add(category);
          }
        });
      },
    );
  }

  /// choose an image and display it on the screen by changing state
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
      SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: new TextFormField(
                decoration: new InputDecoration(
                  labelText: "Title",
                ),
                controller: _controllerTitle,
              ),
            ),
            new ListTile(
              title: new TextFormField(
                decoration: new InputDecoration(labelText: "Summary"),
                maxLines: null,
                controller: _controllerSummary,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 15, left: 12),
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    List<String> result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TagSelector(categoriesSelected)));
                    setState(() {
                      categoriesSelected = result;
                    });
                  },
                ),
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text("Add at least 2 tags",
                        style: TextStyle(color: Colors.grey))),
              ]),
            ),
            makeChips(),
            Container(
              padding: const EdgeInsets.all(20),
              child: RaisedButton(
                color: brownBackgroud,
                onPressed: () async {},
                child: Icon(
                  Icons.chevron_right,
                  size: 30,
                ),
                elevation: 6,
                shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
