import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions => const FirebaseOptions(
        apiKey: 'AIzaSyPlaceholderKeyForTH3FoodApp',
        appId: '1:000000000000:android:0000000000000000',
        messagingSenderId: '000000000000',
        projectId: 'th3-food-app-demo',
        storageBucket: 'th3-food-app-demo.appspot.com',
      );
}
