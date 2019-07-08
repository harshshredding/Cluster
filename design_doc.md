# Design Doc
## Business Requirements :
1) (+) button(on the map) to add an event
2) Search page to do complex search
3) Click on event to view information and chat with group members. 
   (Gotta figure out database for this).
4) Profile 

# What does my data look like ?
Event :
    - Location
    - Title
    - Summary
    - Participants
    
    
    - Events : 
        - when people scroll on the map, we get new stuff to display.
        - we want the stuff that is about to happen (use timestamps for that).
    - Chat :
        - Proper messaging system with emoji's and everything.
        - Wonder if there is a Slack plugin
    - Profile :
        - Things you are interested in (event <-> user)
        - Friends (feature creep)
        - Profile info
        - Rating (feature creep)
    
# Order of action
    (D) - Authentication
    (D) - Display Map
    (I) - Add button to make events (just store them on the database)
    (I) - List all the events in a simple list
            - get image, description, time etc
    (I) - Show events on map
            - Userclicks will reveal details of event
    (I) - Integrate chat with events
            - Have a chat icon in the right corner
            - Seemless chatting with people in the group
    (I) - Add user information / profiles
            - clicking on any photo will show you the profile.
    (I) - Direct messaging to users
            - Just click on the profile and start typing