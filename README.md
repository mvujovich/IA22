# Arts Explorer
## CS IA 2022

Author: Mirjana Vujovich
Created for IB CS 2020-22

### TODOs (ordered):
- Add some sort of cancel button while editing profile
- Allow users to log out from the side menu
- Sort posts chronologically for all table views of posts
- Update posts/post list in real time (table view)
- Add checkboxes for categories in the upload view
- Convert "categories" to an array data type accordingly
- Add navigation bar at the top of the whole app
- Add the ability to comment within the table views
    - Add these comments to Firebase in an array
    - Display comments in table view cells (may change this)
- Add moderation screen with basic approval/rejection
- Add ability to save posts from table views
- Add view for saved posts (from self profile view)
- Display all errors in popups or text views to the user
- Show progress bars/success messages (database calls)

### Completed TODOs (not really ordered):
- Integrate Firebase storage (image support; for uploading posts)
- Fix and update upload interface (relatively okay for now)
- Replicate home feed for profile view (still basic at the moment)
- Fix bug where photos keep refreshing in the home view
- Add ability to update/edit profile information (with Firebase)
- Add "clear" button to the upload view (for image chosen)
- Add profile photo functionality and fix profile views accordingly
- Add sidebar to main home page that opens smoothly

### Dependencies:
- Firebase Auth
- Firebase Firestore
- Firebase Storage
- FirebaseUI
- SideMenuSwift

### How to run:
- Project created in XCode 12.4 using Storyboards and the AppDelegate lifecycle
