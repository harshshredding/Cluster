import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'proposals_for_group.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;

  GroupDetails(this.groupId);

  GroupDetailsState createState() {
    return GroupDetailsState();
  }
}

class GroupDetailsState extends State<GroupDetails> {
  bool shouldShowFullText = false;
  String groupDescriptionText;
  Future<DocumentSnapshot> future;

  void initState() {
    super.initState();
    this.future =
        Firestore.instance.collection("groups").document(widget.groupId).get();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
          switch (asyncSnapshot.connectionState) {
            case ConnectionState.done:
              this.groupDescriptionText =
                  "aslkfjalskdjf jalksjdf akjsd fkajsd fkajs dfkja sdkfj aksdjf akjsd fkjasd kfj aksdjf kasjdf kajsd fkaj skdfj aksjd fkajs dkfj aksdjf kajs dfkja skdjf akjsd fkja sdkjf kajsdfkja skdjf aksdjf kajsd fkj asdkjf aksjd fkjs dkfja ksdj fkajsd fkja sdkfj aksdjf kajs dkfaj skdjf kasdjfkjasdkfjaks dfj aksjdf kasjd fkjas dkfj ";
              int trimEnd = (this.groupDescriptionText.length < 100)
                  ? this.groupDescriptionText.length
                  : 100;
              return Scaffold(
                appBar: AppBar(
                  title: Text(asyncSnapshot.data.data["title"]),
                ),
                body: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 2),
                      child: shouldShowFullText
                          ? Text(this.groupDescriptionText)
                          : Text(this.groupDescriptionText.substring(0, trimEnd) +
                          " ... "),
                    )
                    ,
                    Container(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              shouldShowFullText = !shouldShowFullText;
                            });
                          },
                          icon: shouldShowFullText
                              ? Icon(Icons.keyboard_arrow_up)
                              : Icon(Icons.keyboard_arrow_down),
                        )),
                    Divider(
                      color: Colors.grey,
                    ),
                    Flexible(child: ProposalsForOneGroup([asyncSnapshot.data.data["title"]]))
                  ],
                ),
              );
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
                            color: index.isEven ? Colors.brown : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ));
              break;
          }
        },
        future: this.future);
  }
}
