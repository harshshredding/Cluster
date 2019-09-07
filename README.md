# QuickCoffee

First things first :

Download the app at [this link](https://apps.apple.com/bm/app/quickcoffee/id1473773572?fbclid=IwAR2wVjpWUgG6cYsAxXocVAO4wsDIAsG5YNLS-r-gFsCdU23vtfLWBKNg-qc)

[landing page](https://harshv5.wixsite.com/kluzter)

Available for UW students only (right now). 
Easily have in-person, in-depth conversations on topics you care about. Find people based on discussion topics. Create new groups easily.

Create a discussion proposal so that people can find you(and you can find them). People interested in your discussion proposal will contact you. Set up an in-person meeting, or set up video chat sessions very easily using our chat-bot. Post your discussion proposal in specific groups to find better people. Explore groups to meet interesting people.

# HELP ME
Every crumble of code is appreciated.
The code might be overwhelming to some of you. I want you to PLEASE complain if it is using curse-words : we value code readability a lot here. It is usually never the reader's fault if something is super complex.
I (Harsh) am always there for you, always. Disturb me if you are stuck for more than an hour on some stupid thing.

# Setup

- [Install Flutter](https://flutter.dev/docs/get-started/install)
    - Follow all steps :
        - Yes this means installing both Xcode and Android Studio
- [Setup Android Studio As Editor](https://flutter.dev/docs/get-started/editor)
- Run `flutter Doctor` and fix all bugs
- Time to import stuff from Github.
    - File -> New -> Project from Version Control -> Git
    - Then enter the cloning url from Github
    - When the project has been imported, there will be a suggestion on the top
    saying `get dependencies`. Say yes to that. 
    - Now open up IOS emulator(Don't try Android yet) and run project on that.
    - If the project does not build, and you don't understand the error. Contact me asap.
    - Look at the get up to speed section now. Build a simple app.
    

    
Remember, we should NEVER check the below files into github primarily because 
they are auto generated and some are just libraries. : 
```
.gradle/
.idea/
Cluster-test.iml
build.gradle
build/
gradle/
gradlew
gradlew.bat
ios/Pods/
local.properties
```

# Get up to speed
A few resources to get you started if this is your first Flutter project:

I recommend using Android Studio. 
- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
Also watch this below video to understand how easy it is to work with UI in flutter.
- [Lab: Flutter Widget position](https://fireship.io/lessons/flutter-widget-positioning-guide/)
Also watch the following series to understand Firestore. The Distributed NoSQL database
we will be using:
- [Firestore !!!](https://www.youtube.com/watch?v=v_hR4K4auoQ&t=22s)
Watch the entire series :), the guys is awesome.
Read design_doc.md in root
I think you are now ready to dive in. Simply ask me questions if you don't understand some
concept.
- [Flutter State management](https://www.youtube.com/watch?v=3tm-R7ymwhc)
Watch this video to understand what `State` in flutter is and how to manage it to create complicated applications.
- [How to Layout Stuff in Flutter](https://www.youtube.com/watch?v=u0e2L5yoxFI)
Watch this video to understand how to lay out widgets in a flutter application.


# Best Practices
I know we are developing quickly, but it always helps to respect and follow some practices
so that we don't get too excited and make major mistakes. Practices are : 
- Lint code before pushing.
- Write at least one test before pushing.
- Think a lot before naming a variable.