import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions => const FirebaseOptions(
        apiKey: 'AIzaSyPlaceholderKeyForTH3FoodApp',
        appId: '1:000000000000:android:0000000000000000',
        messagingSenderId: '000000000000',
        projectId: 'appmenu-4de2f',
        storageBucket: 'appmenu-4de2f.appspot.com',
        databaseURL: 'https://appmenu-4de2f-default-rtdb.asia-southeast1.firebasedatabase.app',
      );
}
