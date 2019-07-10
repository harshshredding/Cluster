# Design Doc
## Business Requirements :
1) (+) button(on the map) to add an event
2) Search page to do complex search for events
3) Click on event to view information and chat with group members. 
   (Gotta figure out database for this. Update Firestore should be sufficient.).
4) View and edit your profile 
5) Automatically send invitation for another duplicate meeting with same people.
6) Feature Creep : Pay to improve visibility (maybe not a good idea)
7) Feature Creep : Allow attendee to show distance from event.


# What does my data look like ?
Event :
    - Location
        GeoLocation
        GeoHash (used to only display events in the current field of view)
    - Title
    - Summary
    - Participants
    
    - Events : 
        - when people scroll on the map, we get new stuff to display.
        - we want the stuff that is about to happen (use timestamps for that).
    - Chat :
        - Proper messaging system with emoji's, Gifs, and everything.
        - Wonder if there is a Slack plugin
    - Profile :
        - Things you are interested in (event <-> user)
        - Friends (feature creep)
        - Profile info
        - Rating (feature creep)
    
# Order of action
D = Done
I = Incomplete

    (D) - Authentication
    (D) - Display Map
    (I) - Add button to make events (just store them on the database)
    (I) - List all the events in a simple list
            - get image, description, time etc
    (I) - Show events on map
            - (D) Simply show stuff on map
            - (I) Userclicks will reveal details of event
    (I) - Integrate chat with events
            - Have a chat icon in the right corner
            - Seemless chatting with people in the group
    (I) - Notification System
    (I) - Invitation System
            - Will be able to invite all people that attended the event
              you attended
            - Will be able to invite friends and people you encountered
    (I) - Add user information / profiles
            - clicking on any photo will show you the profile.
    (I) - Direct messaging to users
            - Just click on the profile and start typing
    
    FEATURE CREEP SECTION :- 
    (I) - Rating system based on how many events you attended
    (I) - Make a cool animation advertising your application