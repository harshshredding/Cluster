import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';
import 'tag_selector.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uuid/uuid.dart';

/// scaffolding of the add event screen
class AddGroupScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Group'),
        ),
        body: Center(child: AddGroupForm()),
      ),
    );
  }
}

/// The forms user fills out to create an event.
class AddGroupForm extends StatefulWidget {
  AddGroupFormState createState() {
    return AddGroupFormState();
  }
}

class AddGroupFormState extends State<AddGroupForm> {
  final TextEditingController _controllerTitle = TextEditingController();
  // IMPORTANT !!!!!!!
  // Had to initialize the below controller with empty string for the entire
  // form to work. This is really weird but it seems to be working.
  final TextEditingController _controllerPurpose =
  TextEditingController(text: "");
  Firestore _firestore = Firestore.instance;
  List<String> categoriesSelected = new List();
  bool submitting = false;

  @override
  void initState() {
    super.initState();
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
                  hintText: "Group Title"
                ),
                controller: _controllerTitle,
              ),
            ),
            new ListTile(
              title: new TextFormField(
                decoration: new InputDecoration(
                  labelText: "Purpose",
                  hintText: "Tell us why this group is important."
                ),
                maxLines: null,
                controller: _controllerPurpose,
              ),
            ),
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
                  map["title"] = _controllerTitle.text;
                  map["purpose"] = _controllerPurpose.text;
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  map["user_id"] = user.uid;
                  await _firestore.collection("groups").add(map);
                  setState(() {
                    submitting = true;
                  });
                  var snackbar = new SnackBar(
                    duration: new Duration(seconds: 3),
                    content: Text("Group Added To Universe")
                  );
                  Scaffold.of(context).showSnackBar(snackbar);
                  setState(() {
                    submitting = false;
                  });
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
