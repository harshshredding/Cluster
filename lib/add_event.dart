import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

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

//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Make Event'),
//      ),
//      body: Form(
//          key: _formKey,
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              TextFormField(
//                validator: (value) {
//                  if (value.isEmpty) {
//                    return 'Enter some text';
//                  }
//                  return null;
//                },
//              ),
//              Padding(
//                padding: const EdgeInsets.symmetric(vertical: 16.0),
//                child: RaisedButton(
//                  onPressed: () {
//                    // Validate returns true if the form is valid, or false
//                    // otherwise.
//                    if (_formKey.currentState.validate()) {
//                      // If the form is valid, display a Snackbar.
//                      Scaffold.of(context)
//                          .showSnackBar(SnackBar(content: Text('Processing Data')));
//                    }
//                  },
//                  child: Text('Submit'),
//                ),
//              ),
//            ],
//          )
//      ),
//    );
//  }


  Widget build(BuildContext context) {

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
              new ListTile(
                title: new TextFormField(
                  validator: validatorFunc,
                  decoration: new InputDecoration(
                    hintText: "Title"
                  ),
                ),
              ),
              new ListTile(
                title: new TextFormField(
                  validator: validatorFunc,
                  decoration: new InputDecoration(
                      hintText: "Summary"
                  ),
                  maxLines: null,
                ),
              ),
              new ListTile(
                leading: const Icon(Icons.add_location),
                title: new PlacesAutocompleteFormField(apiKey: "AIzaSyDYtG5xhm17OtZbEi1PJMLuRctVn43xvgs")
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, display a Snackbar.
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Processing Data')));
                    }
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