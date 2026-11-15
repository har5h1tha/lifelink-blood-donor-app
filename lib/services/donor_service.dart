import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/user_model.dart';

/// Firestore access for donors only. No UI, no state.
class DonorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Live list of users where isAvailable == true.
  /// Blood group / city filters are NOT done here (they are done in the
  /// ViewModel), so no composite index is needed.
  Stream<List<UserModel>> streamAvailableDonors() {
    return _db
        .collection(usersCollection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
