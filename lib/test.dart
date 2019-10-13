import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/material.dart';

/// This is a class you can use to test things like new widgets, mysterious widgets etc.
class Test extends StatelessWidget {
  Widget build(BuildContext context) {
    return Center(
      child: PlacesAutocompleteField(
          apiKey: "AIzaSyAZsIhyCaXN79lR54Yo5e313DKmJORiXyM"),
    );
  }

  void willPrint() {
    print('hello');
  }
}
