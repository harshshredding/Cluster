import 'package:flutter/material.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Proposals extends StatefulWidget {
  ProposalsState createState() {
    return ProposalsState();
  }
}

class ProposalsState extends State<Proposals> {
  List<String> _filters = [];
  final Firestore _firestore = Firestore.instance;
  List<DocumentSnapshot> _proposals = new List();
  List<StreamSubscription<QuerySnapshot>> _subscriptions = new List();

  List<Widget> createChips() {
    List<Widget> result = List();
    for (String filter in _filters) {
      result.add(Container(
        margin: EdgeInsets.only(left: 5, right: 5),
        child: Chip(
            label: Text(filter),
            backgroundColor: Colors.blueGrey,
            elevation: 4,
          ),
      ));
    }
    return result;
  }

  void configureFilter(BuildContext context) async {
    List<String> chosenFilters = await Navigator.of(context)
        .push(MaterialPageRoute(
        builder: (context) => TagSelector(_filters)));
    _filters.clear();
    _proposals.clear();
    _subscriptions.clear();
    for (String filter in chosenFilters) {
      _filters.add(filter);
      var subscription = _firestore
          .collection("proposals")
          .where(filter, isEqualTo: true).snapshots().listen((QuerySnapshot snapshot) {
        List<DocumentSnapshot> newDocuments = snapshot.documents;
        List<DocumentSnapshot> thingsToAdd = List();
        for (DocumentSnapshot proposal in newDocuments) {
          bool proposalDoesntExist = _proposals.every((DocumentSnapshot oldProposal) {
            return (oldProposal.documentID != proposal.documentID);
          });
          if (proposalDoesntExist) {
            thingsToAdd.add(proposal);
          }
        }
        setState(() {
          _proposals.addAll(thingsToAdd);
        });
      });
      _subscriptions.add(subscription);
    }
  }

  Widget createCard(String topic, String summary, String userId) {
    return Card(
      shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20))),
      elevation: 5,
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            color: Colors.brown,
            child: Text(
              "DISCUSSION",
              style: TextStyle(
                color: Colors.brown.shade200,
                fontSize: 15,
                fontFamily: 'CarterOne',
                letterSpacing: 3,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[Container(
                        margin: EdgeInsets.only(left: 10, top: 10),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage("https://lh4.googleusercontent.com/-JEQ-bKugLRQ/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcVET0d2uhimypWUiuWhPvhvvDMXg/s96-c/photo.jpg"),
                          backgroundColor: Colors.transparent,
                        ),

                      ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Harsh Verma",
                            style: TextStyle(fontSize: 15),
                          ),
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 0, bottom: 5),
                        )],
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "TOPIC :",
                        style: TextStyle(
                            color: Colors.brown.shade100, fontSize: 13),
                      ),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(topic, style: TextStyle(fontSize: 15)),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 0, bottom: 10),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "SUMMARY :",
                        style: TextStyle(
                            color: Colors.brown.shade100, fontSize: 13),
                      ),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 5),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(summary, style: TextStyle(fontSize: 15)),
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 0, bottom: 10),
                    )
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Container(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.star,
                    size: 25,
                  ),
                  margin:
                      EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                ),
              )
            ],
          )
        ],
      ),
      margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
    );
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          color: Colors.grey.shade900,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 14),
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: ButtonTheme(
                  minWidth: 30,
                  shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  child: RaisedButton(
                    elevation: 15,
                    onPressed: () {configureFilter(context);},
                    child: Text(
                      "FILTER",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: brownTextColor2,
                  ),
                )
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: createChips(),
                ),
              )
            ],
          ),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot currEvent = _proposals[index];
              String topic = currEvent.data["title"] ?? "";
              String summary = currEvent.data["summary"] ?? "";
              return createCard(topic, summary, "");
            },
            itemCount: _proposals.length,
          ),
        )
        ,
      ],
    );
  }
}
