import 'dart:async';
 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
 
import '../core/constants.dart';
import '../models/request_model.dart';
 
/// Talks to Firestore only. No UI, no state.
class RequestService {
  // A getter (not a field) so Firebase is touched only when a method is
  // really called. In dummy mode this class is never used, so nothing crashes.
  CollectionReference<Map<String, dynamic>> get _requests =>
      FirebaseFirestore.instance.collection(requestsCollection);
 
  /// Live list of all requests. Every change in Firestore (new request,
  /// status change, delete) is pushed here instantly.
  ///
  /// The stream waits for login first: the security rules only allow
  /// logged-in users to read, and the ViewModel starts listening when the
  /// app starts (before login). When the user logs out it sends an empty list.
  Stream<List<RequestModel>> streamRequests() {
    StreamSubscription<User?>? authSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? dataSub;
    late StreamController<List<RequestModel>> controller;
 
    controller = StreamController<List<RequestModel>>(
      onListen: () {
        authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
          // Login state changed: stop the old Firestore listener first
          dataSub?.cancel();
          dataSub = null;
          if (user == null) {
            controller.add(<RequestModel>[]);
            return;
          }
          dataSub = _requests.snapshots().listen(
            (snap) {
              controller.add(snap.docs
                  .map((d) => RequestModel.fromMap(d.data(), d.id))
                  .toList());
            },
            onError: controller.addError,
          );
        });
      },
      onCancel: () async {
        await dataSub?.cancel();
        await authSub?.cancel();
      },
    );
    return controller.stream;
  }
 
  /// Firestore creates the document id automatically.
  Future<void> addRequest(RequestModel r) async {
    await _requests.add(r.toMap());
  }
 
  Future<void> updateStatus(String id, String status) async {
    await _requests.doc(id).update({'status': status});
  }
 
  Future<void> deleteRequest(String id) async {
    await _requests.doc(id).delete();
  }
}