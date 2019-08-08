import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

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
  bool submitting = false;

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
          elevation: 4,
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
                      if (result != null) {
                        setState(() {
                          categoriesSelected = result;
                        });
                      }
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
              child: submitting ? SpinKitFadingCircle(
                itemBuilder: (_, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.brown : Colors.grey,
                    ),
                  );
                },
              ): RaisedButton(
                color: brownBackgroud,
                onPressed: () async {
                  setState(() {
                    submitting = true;
                  });
                  Map<String, dynamic> map = Map();
                  for (String category in categoriesSelected) {
                    map[category] = true;
                  }
                  map["title"] = _controllerTitle.text;
                  map["summary"] = _controllerSummary.text;
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  map["user_id"] = user.uid;
                  String proposalId = Uuid().v1() + user.uid;
                  DocumentReference userProposal = _firestore.collection("users")
                      .document(user.uid)
                      .collection("proposals").document(proposalId);
                  DocumentReference proposalEntry = _firestore.collection("proposals")
                  .document(proposalId);
                  await _firestore.runTransaction((Transaction t) async {
                    await t.set(proposalEntry, map);
                    await t.set(userProposal, {"id": proposalId});
                    return null;
                  });
                  //await _firestore.collection("proposals").add(map);
                  Navigator.pop(context);
                },
                child: Text("CREATE"),
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
