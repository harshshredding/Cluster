import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'event_details.dart';

class MapScreen extends StatefulWidget {
  MapScreenState createState() {
    return MapScreenState();
  }
}

class MapScreenState extends State<MapScreen> {
  static final CameraPosition myHome = CameraPosition(
    target: LatLng(47.663645, -122.286446),
    zoom: 14.4746,
  );

  GoogleMapController mapController;
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  Stream<List<DocumentSnapshot>> stream;
  List<GeoPoint> markerList = new List<GeoPoint>();

  void initState() {
    GeoFirePoint center =
        geo.point(latitude: 47.663645, longitude: -122.286446);
    var collectionRef = firestore.collection('events');
    double radius = 50;
    String field = 'position';
    stream = geo
        .collection(collectionRef: collectionRef)
        .within(center: center, radius: radius, field: field);
    stream.listen(_updateMarkers);
  }

  Widget build(BuildContext context) {
    final tabBar = new TabBar(
      tabs: <Tab>[
        new Tab(icon: new Icon(Icons.map)),
        new Tab(icon: new Icon(Icons.chat)),
        new Tab(icon: new Icon(Icons.person_pin_circle)),
      ],
    );

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: tabBar,
            title: Text('Cluster'),
          ),
          body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
            Stack(
              children: <Widget>[
                GoogleMap(
                    initialCameraPosition: myHome,
                    onMapCreated: _onMapCreated,
                    markers: markerList.map((GeoPoint p) {
                      print('hey');
                      print(p.latitude);
                      print(markerList.length);
                      return new Marker(
                          markerId: MarkerId(p.latitude.toString() +
                              "," +
                              p.longitude.toString()),
                          position: LatLng(p.latitude, p.longitude),
                          icon: BitmapDescriptor.defaultMarkerWithHue(20.0),
                          flat: true,
                          onTap: () {
                            Navigator.of(context).push<void>(CupertinoPageRoute(
                                builder: (context) => DetailsScreen(2),
                                fullscreenDialog: true));
                          });
                    }).toSet(),
                    gestureRecognizers: Set()
                      ..add(Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer()))),
                Positioned(
                  bottom: 50,
                  right: 10,
                  child: FlatButton(
                      onPressed: _goToAddEventPage(context),
                      child: Icon(Icons.add)),
                )
              ],
            ),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ]),
        ));
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Function _goToAddEventPage(BuildContext context) {
    return () {
      Navigator.pushNamed(context, '/addEvent');
    };
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    bool needToRebuild = false;
    if (documentList.length != markerList.length) {
      needToRebuild = true;
    }
    if (!needToRebuild) {
      for (int i = 0; i < documentList.length; i++) {
        GeoPoint pos1 = documentList[i].data['position']['geopoint'];
        GeoPoint pos2 = markerList[i];
        if ((pos1.latitude != pos2.latitude) ||
            (pos1.longitude != pos2.longitude)) {
          needToRebuild = true;
          break;
        }
      }
    }
    if (needToRebuild) {
      setState(() {
        markerList.clear();
        documentList.forEach((doc) {
          double latitude = doc.data['position']['geopoint'].latitude;
          double longitude = doc.data['position']['geopoint'].longitude;
          markerList.add(GeoPoint(latitude, longitude));
        });
      });
    }
  }
}
