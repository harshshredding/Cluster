import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// scaffolding of the add event screen
class EditProposalScreen extends StatelessWidget {
  final String proposalId;
  
  EditProposalScreen(this.proposalId);
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Proposal'),
      ),
      body: Center(child: EditProposalForm(this.proposalId)),
    );
  }
}

/// The forms user fills out to create an event.
class EditProposalForm extends StatefulWidget {
  final String proposalId;
  
  EditProposalForm(this.proposalId);
  
  EditProposalFormState createState() {
    return EditProposalFormState();
  }
}

class EditProposalFormState extends State<EditProposalForm> {
  final TextEditingController _controllerTitle = TextEditingController();
  // IMPORTANT !!!!!!!
  // Had to initialize the below controller with empty string for the entire
  // form to work. This is really weird but it seems to be working.
  final TextEditingController _controllerSummary =
  TextEditingController(text: "");
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Firestore _firestore = Firestore.instance;
  List<String> _categoriesSelected = new List();
  bool submitting = false;
  Future<DocumentSnapshot> proposalFuture;

  @override
  void initState() {
    super.initState();
    _googleSignIn.signInSilently();
    getProposalInformation();
  }

  void getProposalInformation() async {
    DocumentSnapshot proposal = await Firestore.instance.collection("proposals").document(widget.proposalId).get();
    _controllerTitle.text = proposal.data['title'] ?? "";
    _controllerSummary.text = proposal.data['summary'] ?? "";
    QuerySnapshot groupsQuery = await Firestore
        .instance.collection("groups").getDocuments();
    for (DocumentSnapshot groupSnap in groupsQuery.documents) {
      String groupTitle = groupSnap.data['title'];
      if (proposal.data[groupTitle] != null) {
        _categoriesSelected.add(groupTitle);
      }
    }
    setState(() {
    });
  }

  Widget makeChips() {
    List<Widget> allChips = new List();
    for (String category in _categoriesSelected) {
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
      onTap: null,
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
                          MaterialPageRoute(builder: (context) => TagSelector(_categoriesSelected)));
                      if (result != null) {
                        setState(() {
                          _categoriesSelected = result;
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
                  color: brownBackground,
                  onPressed: () async {
                    setState(() {
                      submitting = true;
                    });
                    Map<String, dynamic> map = Map();
                    for (String category in _categoriesSelected) {
                      map[category] = true;
                    }
                    map["title"] = _controllerTitle.text;
                    map["summary"] = _controllerSummary.text;
                    FirebaseUser user = await FirebaseAuth.instance.currentUser();
                    map["user_id"] = user.uid;
                    String proposalId = widget.proposalId;
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
                    var snackbar = new SnackBar(
                      duration: new Duration(seconds: 2),
                      content: Text("Proposal Updated"),
                    );
                    Scaffold.of(context).showSnackBar(snackbar);
                    setState(() {
                      submitting = false;
                    });
                  },
                  child: Text("Update"),
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
