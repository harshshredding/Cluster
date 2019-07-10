import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

class AddEventScreen extends StatefulWidget {
  AddEventState createState() {
    return AddEventState();
  }
}

class AddEventState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    final _controller = new TextEditingController(text: "");

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
                controller: _controller,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () async {
                    print(_controller.text);
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