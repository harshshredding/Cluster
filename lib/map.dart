import 'package:flutter/material.dart';
import 'helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// This represents the main screen of the app which
/// shows a Map full of events. We can use this screen to:
/// 1) make events
/// 2) join events
/// 3) join chats of events
/// 4) call the same people again
class MapScreen extends StatelessWidget {

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    final UserName arg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(arg.name),
      ),
      body: GoogleMap(initialCameraPosition: _kGooglePlex),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/addEvent'),
          icon: Icon(Icons.add),
          label: Text('Add event'),
      ),
    );
  }
}