import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/user_model.dart';
import '../services/blood_compatibility.dart';
import '../services/donor_service.dart';

class DonorViewModel extends ChangeNotifier {
  // ---- Public state (from the contract) ----
  String? selectedBloodGroup;
  String? selectedCity;
  bool includeCompatible = false;
  bool isLoading = true;

  // ---- Private state ----
  List<UserModel> _allDonors = []; // all available donors, unfiltered
  String? _currentUserId; // used to hide the logged-in user
  StreamSubscription<List<UserModel>>? _subscription;

  /// Filtered result shown on the Find Donors screen.
  List<UserModel> get donors {
    // Groups we accept. Empty list means "any group".
    List<String> allowedGroups = [];
    if (selectedBloodGroup != null) {
      allowedGroups = includeCompatible
          ? compatibleDonors(selectedBloodGroup!)
          : [selectedBloodGroup!];
    }

    return _allDonors.where((d) {
      if (_currentUserId != null && d.uid == _currentUserId) return false;
      if (allowedGroups.isNotEmpty && !allowedGroups.contains(d.bloodGroup)) {
        return false;
      }
      if (selectedCity != null && d.city != selectedCity) return false;
      return true;
    }).toList();
  }

  /// Count of ALL available donors, ignoring filters (Home dashboard).
  int get totalAvailable => _allDonors.length;

  /// Extra helper (not in the contract, added privately): the screen tells
  /// us who is logged in so we can hide them from the list.
  void setCurrentUserId(String? uid) {
    if (_currentUserId == uid) return;
    _currentUserId = uid;
    // With Firestore: the stream started at app launch, before login, and
    // security rules reject it. Restart it now that a user is logged in.
    if (!useDummyData && uid != null) {
      startListening();
      return;
    }
    notifyListeners();
  }

  /// Start loading donors (dummy data or Firestore stream).
  void startListening() {
    if (useDummyData) {
      _allDonors = _dummyDonors();
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription = DonorService().streamAvailableDonors().listen(
      (list) {
        _allDonors = list;
        isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        notifyListeners();
      },
    );
  }

  void setBloodGroup(String? g) {
    selectedBloodGroup = g;
    notifyListeners();
  }

  void setCity(String? c) {
    selectedCity = c;
    notifyListeners();
  }

  void setIncludeCompatible(bool v) {
    includeCompatible = v;
    notifyListeners();
  }

  void clearFilters() {
    selectedBloodGroup = null;
    selectedCity = null;
    includeCompatible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ---- Dummy data: 18 available donors ----
  List<UserModel> _dummyDonors() {
    final now = DateTime.now();
    UserModel d(String id, String name, String group, String city,
            String phone, int? daysAgo) =>
        UserModel(
          uid: id,
          name: name,
          email: '$id@example.com',
          bloodGroup: group,
          city: city,
          phone: phone,
          isAvailable: true,
          lastDonated: daysAgo == null ? null : now.subtract(Duration(days: daysAgo)),
        );

    return [
      d('d1', 'Aarav Sharma', 'A+', 'Bengaluru', '9876500001', 120),
      d('d2', 'Priya Nair', 'O+', 'Kochi', '9876500002', null),
      d('d3', 'Rohan Gowda', 'B+', 'Mysuru', '9876500003', 200),
      d('d4', 'Sneha Kulkarni', 'AB+', 'Hubballi', '9876500004', 45),
      d('d5', 'Karthik Reddy', 'O-', 'Hyderabad', '9876500005', 150),
      d('d6', 'Ananya Iyer', 'A-', 'Chennai', '9876500006', null),
      d('d7', 'Vikram Patil', 'B-', 'Mangaluru', '9876500007', 95),
      d('d8', 'Meera Joshi', 'AB-', 'Pune', '9876500008', 300),
      d('d9', 'Arjun Singh', 'O+', 'Delhi', '9876500009', 60),
      d('d10', 'Divya Rao', 'A+', 'Bengaluru', '9876500010', 180),
      d('d11', 'Suresh Menon', 'O+', 'Bengaluru', '9876500011', null),
      d('d12', 'Neha Deshmukh', 'B+', 'Mumbai', '9876500012', 110),
      d('d13', 'Imran Khan', 'O-', 'Mumbai', '9876500013', 220),
      d('d14', 'Lakshmi Hegde', 'A+', 'Mangaluru', '9876500014', 30),
      d('d15', 'Farhan Ali', 'B+', 'Hyderabad', '9876500015', 140),
      d('d16', 'Pooja Bhat', 'A-', 'Bengaluru', '9876500016', null),
      d('d17', 'Nikhil Varma', 'O+', 'Chennai', '9876500017', 100),
      d('d18', 'Kavya Shetty', 'AB+', 'Mysuru', '9876500018', 75),
    ];
  }
}
