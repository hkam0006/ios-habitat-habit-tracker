# Habitat iOS Habit Tracker
The journey of self improvement starts here...

## Overview
The Habit Tracker iOS App is a powerful tool designed to help users build and maintain positive habits. With its user-friendly interface and comprehensive features, this app aims to assist individuals in tracking their daily routines, establishing consistency, and achieving their personal goals. Whether you want to develop healthier habits, improve productivity, or enhance self-discipline, this app provides the necessary tools and insights to make positive changes in your life.

## Screenshot
<img src="https://github.com/hkam0006/ios-habitat-habit-tracker/blob/dee237a4bd22c97b640215839ad391d979bb0d48/images/dark_mode.png"  width="30%"> <img src="https://github.com/hkam0006/ios-habitat-habit-tracker/blob/dee237a4bd22c97b640215839ad391d979bb0d48/images/light_mode.png"  width="30%"> <img src="https://github.com/hkam0006/ios-habitat-habit-tracker/blob/dee237a4bd22c97b640215839ad391d979bb0d48/images/create_habit.png"  width="30%">

<img src="https://github.com/hkam0006/ios-habitat-habit-tracker/blob/dee237a4bd22c97b640215839ad391d979bb0d48/images/edit_habit.png"  width="30%"> <img src="https://github.com/hkam0006/ios-habitat-habit-tracker/blob/dee237a4bd22c97b640215839ad391d979bb0d48/images/quote_page.png"  width="30%"> <img src="https://github.com/hkam0006/ios-habitat-habit-tracker/blob/dee237a4bd22c97b640215839ad391d979bb0d48/images/habit_tracking.png"  width="30%">

## Key Features
- **Habit Creation:** Easily create and customise your own habits.
- **Habit Tracking:** Track habits on a daily, weekly, or monthly basis, allowing you to mark habits as completed or in progress. 
- **Reminders and Notifications:** Set personalised reminders and receive local notifications to ensure you stay on track with your habits.
- **Streak Tracking:** Stay motivated with streak tracking, visually displaying your consecutive days, weeks or months of completing a habit. 
- **Statistics and Analytics:** Gain valuable insights into your habit completion rates, streaks, and overall progress through detailed statistics and visual representations like charts and graphs.
- **Inspirational Quotes:** Get daily doses of motivation and inspiration with a collection of uplifting quotes to keep you motivated on your habit-building journey.
- **Habit Categories and Tags:** Organise your habits by assigning categories or tags for easy navigation and filtering, allowing you to focus on specific areas of improvement.
- **Habit Sharing and Social Features:** Share your habits, progress, and achievements with friends and on social media platforms, fostering a sense of community and accountability.
- **Data Synchronisation and Backup:** Safeguard your habit data with cloud synchronisation, ensuring your progress is securely backed up and accessible across multiple devices.

## Getting Started
Currently, the iOS app is not available on the App Store. The project is still a prototype. To try using the Habitat Tracker App, a macOS device with Xcode is required. This application also utilises Firebase services.
#### Get GoogleService-Info.plist
1. Navigate to the [Firebase website](https://firebase.google.com/) and create a new Firebase project.
2. Follow the Firebase documentation to set up iOS app integration for your project and obtain the necessary GoogleService-Info.plist file.
3. Once you have the GoogleService-Info.plist file, drag and drop it into the root directory of your Xcode project. Make sure to add it to the appropriate target.
After downloading GoogleService-Info.plist, 
1. Clone or download the project repository from [GitHub](https://github.com/your-username/habit-tracker-ios-app).
2.  In Xcode, select "Open" from the "File" menu and navigate to the directory where you cloned or downloaded the project.
3. The project should be able to run after performing these steps.

We apologize for any inconvenience caused by the macOS exclusivity of Xcode and Firebase integration. Unfortunately, there are no official alternatives for running Xcode on non-macOS systems.

## Acknowledgments
#### Firebase
We would like to express our gratitude to the open-source community and the creators of Firebase for their invaluable contributions. The Habit Tracker iOS App utilises Firebase, a comprehensive mobile and web development platform provided by Google. Firebase enables essential features such as real-time database, user authentication, cloud storage, and more, which enhance the functionality and performance of our app.

For more information about Firebase and its offerings, please visit the [Firebase website](https://firebase.google.com/).

Thank you to the Firebase team for providing developers with a powerful and user-friendly platform to build feature-rich applications.

#### MulticastDelegate
This application also uses **MulticastDelegate** by Michael Wybrow: We utilise the `MulticastDelegate` class, which allows for managing multiple delegates efficiently. This class facilitates the implementation of delegate patterns and event handling within our app. The code for `MulticastDelegate` is licensed under the Apache License, Version 2.0. You can find the original code [here]([https://github.com/hkam0006/ios-habitat-habit-tracker/edit/main/README.md#:~:text=FirebaseController.swift-,MulticastDelegate,-.swift](https://github.com/hkam0006/ios-habitat-habit-tracker/blob/f7c16bc10267ad26425435d7753c0ab6ab77e47a/ios-habit-app/Database/MulticastDelegate.swift)).

Thank you to Michael Wybrow for providing this helpful utility class that enhances the functionality of our app.

#### Inspirational Quotes
We would like to acknowledge the contribution of **API Ninjas** to the development of the Habit Tracker iOS App. This application utilises the **Inspirational Quotes API** provided by API Ninjas to retrieve a curated collection of inspirational quotes.

The API endpoint utilises for retrieving the inspirational quotes is:

- **Endpoint:** [https://api.api-ninjas.com/v1/quotes?category=inspirational](https://api.api-ninjas.com/v1/quotes?category=inspirational)

We express our gratitude to API Ninjas for providing this valuable API, which enriches the user experience of our app by delivering motivational and uplifting quotes. The availability of the Inspirational Quotes API enhances the inspiration and motivation levels for users on their habit-building journey.

Thank you to API Ninjas for their efforts in providing a reliable and comprehensive API service for inspirational quotes.
