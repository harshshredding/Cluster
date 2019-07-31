import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'event_details.dart';
import 'favorite_events.dart';

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
  // Stores all the current markers to show on the map.
  Map<String, GeoPoint> idToGeoPoint = Map();
  var collectionRef;
  bool eventTapped = false;
  String selectedEventId;

  void initState() {
    super.initState();
    GeoFirePoint center =
        geo.point(latitude: 47.663645, longitude: -122.286446);
    double radius = 50;
    String field = 'position';
    collectionRef = firestore.collection('events');
    stream = geo
        .collection(collectionRef: collectionRef)
        .within(center: center, radius: radius, field: field);
    stream.listen(_updateMarkers);
  }

  Widget build(BuildContext context) {
    final tabBar = new TabBar(
      tabs: <Tab>[
        new Tab(icon: new Icon(Icons.map)),
        new Tab(
            icon: new Icon(
          Icons.star,
          color: Colors.white,
        )),
      ],
    );

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: tabBar,
            title: Text('Cluster'),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: IconButton(
                  icon: Icon(Icons.supervised_user_circle),
                  onPressed: () {
                    Navigator.pushNamed(context, '/userProfile',
                        arguments: ModalRoute.of(context).settings.arguments);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: IconButton(
                  icon: Icon(Icons.add_location),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addEvent',
                        arguments: ModalRoute.of(context).settings.arguments);
                  },
                ),
              )
            ],
          ),
          body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
            Stack(
              children: <Widget>[
                GoogleMap(
                    initialCameraPosition: myHome,
                    onMapCreated: _onMapCreated,
                    markers: _getMarkers(),
                    gestureRecognizers: Set()
                      ..add(Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer()))),
                selectedEventId != null
                    ? Positioned.fill(
                        child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: AnimatedContainer(
                          height: eventTapped
                              ? MediaQuery.of(context).size.height * 9 / 10
                              : MediaQuery.of(context).size.height / 6,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.all(20),
                          child: Container(
                              child: GestureDetector(
                                child: DetailsScreen(selectedEventId, firestore),
                            onTap: () {
                              setState(() {
                                eventTapped = !eventTapped;
                              });
                            },
                          )),
                          duration: Duration(milliseconds: 200),
                        ),
                      ))
                    : Container(
                        height: 0,
                        width: 0,
                      )
              ],
            ),
            FavoritesList(),
          ]),
        ));
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    setState(() {
      for (int i = 0; i < documentList.length; i++) {
        String id = documentList[i].documentID;
        GeoPoint pos = documentList[i].data['position']['geopoint'];
        idToGeoPoint[id] = pos;
      }
    });
  }

  Set<Marker> _getMarkers() {
    Set<Marker> result = Set();
    idToGeoPoint.forEach((k, v) {
      //print(k);
      result.add(Marker(
          markerId: MarkerId(k),
          position: LatLng(v.latitude, v.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(20.0),
          onTap: () async {
            setState(() {
              selectedEventId = k;
            });
          })
      );
    });
    return result;
  }
}
