import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TagSelector extends StatefulWidget {
  final List<String> alreadySelectedGroups;

  TagSelector(this.alreadySelectedGroups);

  TagSelectorState createState() {
    return TagSelectorState();
  }
}

class TagSelectorState extends State<TagSelector> {
  final Set<String> groupsSelected = Set();
  Future<QuerySnapshot> getGroupsFuture;
  
  initState() {
    super.initState();
    for (String group in widget.alreadySelectedGroups) {
      groupsSelected.add(group);
    }
    getGroupsFuture =  Firestore.instance.collection("groups").getDocuments();
  }

  Widget createChip(String group) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        child: groupsSelected.contains(group)
            ? Chip(
                label: Text(group),
                backgroundColor: Colors.blueAccent,
              )
            : Chip(
                label: Text(group),
                backgroundColor: Colors.blueGrey,
              ),
      ),
      onTap: () {
        setState(() {
          if (groupsSelected.contains(group)) {
            groupsSelected.remove(group);
          } else {
            groupsSelected.add(group);
          }
        });
      },
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              List<Widget> chips = new List<Widget>();
              for (DocumentSnapshot groupSnap in asyncSnapshot.data.documents) {
                chips.add(createChip(groupSnap.data["title"]));
              }
              return Scaffold(
                appBar: AppBar(
                  title: Text("Choose Relevant Tags"),
                ),
                body: Container(
                  child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Wrap(
                            children: chips,
                          ),
                        ],
                      )),
                ),
                floatingActionButton: ButtonTheme(
                  minWidth: 80.0,
                  height: 40.0,
                  child: RaisedButton(
                    color: brownBackground,
                    onPressed: () async {Navigator.pop(context, groupsSelected.toList());},
                    child: Text("Done"),
                    elevation: 6,
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ));
              break;
            case ConnectionState.active:
            case ConnectionState.waiting:
            case ConnectionState.none:
            default:
              return Container(
                  margin: EdgeInsets.only(top: 25),
                  child: Center(
                    child: SpinKitFadingCircle(
                      itemBuilder: (_, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                            index.isEven ? Colors.brown : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ));
              break;
          }
        },
        future: getGroupsFuture);
  }
}
