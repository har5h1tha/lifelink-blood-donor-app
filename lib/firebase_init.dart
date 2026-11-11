import 'core/constants.dart';

// Called from main(). Does nothing while useDummyData is true.
// TODO (Member 1): after running `flutterfire configure`, replace the body with:
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// and add these imports:
//   import 'package:firebase_core/firebase_core.dart';
//   import 'firebase_options.dart';
Future<void> initFirebase() async {
  if (useDummyData) return;
}
