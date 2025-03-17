# Flutter Boilerplate with p5.js  

Welcome to the **Flutter Boilerplate with p5.js**! This boilerplate provides a streamlined starting point for developing Flutter applications that integrate **p5.js** for creative coding and generative art.  

## 🚀 Features  
✅ Flutter setup with best practices  
✅ Integration with **p5.js** via a WebView  
✅ Clean project structure for scalability  
✅ Hot reload support for fast development  
✅ Cross-platform support (iOS, Android, Web)  

---

## 📂 Project Structure  
├── lib/
│   ├── main.dart              # Entry point of the Flutter app
│   ├── app.dart               # Main app widget
│   ├── screens/               # UI screens
│   │   └── home_screen.dart   # Example home screen with p5.js
│   ├── widgets/               # Reusable widgets
│   └── utils/                 # Helper functions and utilities
├── assets/                    # Static assets like images, icons, etc.
├── web/
│   └── p5/                    # p5.js files
│       ├── index.html         # Web entry point for p5.js
│       ├── sketch.js          # p5.js sketch file
├── android/                   # Android-specific configurations
├── ios/                       # iOS-specific configurations
├── pubspec.yaml               # Dependencies and assets configuration
├── README.md                  # Project documentation
├── .gitignore                 # Git ignore file
└── LICENSE                    # License information
🛠️ Setup & Installation
1. Clone the Repository

git clone https://github.com/your-username/flutter-p5-boilerplate.git
cd flutter-p5-boilerplate
2. Install Dependencies

flutter pub get
3. Configure WebView for p5.js
Ensure you have the correct permissions and dependencies set up for WebView:

Android:
Open android/app/src/main/AndroidManifest.xml and add:

<uses-permission android:name="android.permission.INTERNET"/>
iOS:
Open ios/Runner/Info.plist and add:
xml
Copy
Edit
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
4. Run the App
To run on an emulator or connected device:


flutter run
🎨 Usage
1. Modify the p5.js Sketch
Open web/p5/sketch.js and customize the p5.js sketch:
javascript
Copy
Edit
function setup() {
  createCanvas(400, 400);
}

function draw() {
  background(220);
  ellipse(mouseX, mouseY, 50, 50);
}
2. Embed the p5.js Sketch in Flutter
In home_screen.dart, embed the WebView:


import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter + p5.js')),
      body: WebView(
        initialUrl: 'assets/p5/index.html',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
✅ Best Practices
Keep sketch.js modular and reusable.
Avoid complex state management inside the p5.js sketch—let Flutter handle app state.
Use Flutter for UI interactions and p5.js for graphical rendering.
🚧 Troubleshooting
WebView not displaying on iOS?

Ensure WebKit is imported and initialized in AppDelegate.swift:

import WebKit
WebView blocked on Android?

Enable mixed content in WebView settings:

WebView(
  initialUrl: 'assets/p5/index.html',
  javascriptMode: JavascriptMode.unrestricted,
);
👥 Contributing
Contributions are welcome! Please follow these steps:

Fork the repository
Create a feature branch (git checkout -b feature/your-feature)
Commit your changes (git commit -m "Add new feature")
Push to the branch (git push origin feature/your-feature)
Create a Pull Request

📄 License
This project is licensed under the MIT License – see the LICENSE file for details.

⭐ Show Your Support
If you find this project helpful, give it a ⭐ on GitHub!

