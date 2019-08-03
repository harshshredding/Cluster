import 'package:flutter/material.dart';
import 'colors.dart';

class TagSelector extends StatefulWidget {
  final List<String> alreadySelectedCategories;

  TagSelector(this.alreadySelectedCategories);

  TagSelectorState createState() {
    return TagSelectorState();
  }
}

class TagSelectorState extends State<TagSelector> {
  final Set<String> categoriesSelected = Set();
  final List<String> categories = [
    "Agriculture",
    "Architecture",
    "Biological and Biomedical Sciences",
    "Business",
    "Communications and Journalism",
    "Computer Science",
    "Geography",
    "Culinary Arts and Personal Services",
    "Education",
    "Engineering",
    "Politics",
    "Liberal Arts And Humanities",
    "Drama",
    "Music",
    "Art",
    "Dance",
    "Law",
    "Medical and Health Professions",
    "Chemistry",
    "Psychology",
    "Physics",
    "Mathematics",
    "Applied Mathematics",
    "Philosophy",
    "Startups"
  ];

  initState() {
    super.initState();
    for (String category in widget.alreadySelectedCategories) {
      categoriesSelected.add(category);
    }
  }

  Widget createChip(String category) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.all(5),
        child: categoriesSelected.contains(category)
            ? Chip(
                label: Text(category),
                backgroundColor: Colors.blueAccent,
              )
            : Chip(
                label: Text(category),
                backgroundColor: Colors.blueGrey,
              ),
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

  Widget build(BuildContext context) {
    List<Widget> chips = new List<Widget>();
    for (String category in categories) {
      chips.add(createChip(category));
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
            Container(
                margin: EdgeInsets.only(top: 30),
                alignment: Alignment.center,
                child: ButtonTheme(
                  minWidth: 80.0,
                  height: 40.0,
                  child: RaisedButton(
                    color: brownBackgroud,
                    onPressed: () async {Navigator.pop(context, categoriesSelected.toList());},
                    child: Text("Done"),
                    elevation: 6,
                    shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )),
          ],
        )),
      ),
    );
  }
}
