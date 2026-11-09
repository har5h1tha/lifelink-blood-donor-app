import 'dart:async';
 
import 'package:flutter/foundation.dart';
 
import '../core/constants.dart';
import '../models/request_model.dart';
import '../services/request_service.dart';
 
class RequestViewModel extends ChangeNotifier {
  /// In dummy mode, requests marked as "mine" use this uid.
  /// Ask Member 1 to use the same uid for the dummy UserModel in AuthViewModel.
  static const String dummyUserUid = 'dummy_user_1';
 
  final RequestService _service = RequestService();
  StreamSubscription<List<RequestModel>>? _sub;
 
  List<RequestModel> _all = []; // every request, unsorted, unfiltered
  String? _currentUid; // logged-in user's uid (set by attachUser)
 
  String? filterBloodGroup; // null means "All"
  bool isLoading = true;
  String? errorMessage;
 
  // ---------- Data the screens read ----------
 
  /// Filtered by blood group, then sorted:
  /// open before fulfilled, Critical > High > Normal, newest first.
  List<RequestModel> get requests {
    final Iterable<RequestModel> filtered = filterBloodGroup == null
        ? _all
        : _all.where((r) => r.bloodGroup == filterBloodGroup);
    return _sorted(filtered);
  }
 
  /// Only the requests posted by the logged-in user (same filter and sort).
  List<RequestModel> get myRequests {
    final uid = _currentUid;
    if (uid == null) return [];
    return requests.where((r) => r.createdBy == uid).toList();
  }
 
  /// All open requests, ignoring the filter (used by the Home dashboard).
  int get openCount => _all.where((r) => r.status == statusOpen).length;
 
  /// Latest version of one request (the details screen uses this so it
  /// updates after "Mark as fulfilled").
  RequestModel? findById(String id) {
    for (final r in _all) {
      if (r.id == id) return r;
    }
    return null;
  }
 
  /// Helper (not in the contract): the list screen tells us who is logged in,
  /// so myRequests knows which uid to match. No notify: it is called in build.
  void attachUser(String? uid) {
    _currentUid = uid;
  }
 
  // ---------- Sorting ----------
 
  // Critical = 0, High = 1, Normal = 2 (position in urgencyLevels)
  int _urgencyRank(String urgency) {
    final i = urgencyLevels.indexOf(urgency);
    return i == -1 ? urgencyLevels.length : i;
  }
 
  List<RequestModel> _sorted(Iterable<RequestModel> items) {
    final list = items.toList();
    list.sort((a, b) {
      // 1. fulfilled go to the bottom
      final aDone = a.status == statusFulfilled;
      final bDone = b.status == statusFulfilled;
      if (aDone != bDone) return aDone ? 1 : -1;
      // 2. more urgent first
      final byUrgency = _urgencyRank(a.urgency).compareTo(_urgencyRank(b.urgency));
      if (byUrgency != 0) return byUrgency;
      // 3. newest first
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }
 
  // ---------- Actions ----------
 
  void startListening() {
    if (useDummyData) {
      _all = _buildDummyRequests();
      isLoading = false;
      notifyListeners();
      return;
    }
    _sub?.cancel();
    isLoading = true;
    _sub = _service.streamRequests().listen(
      (list) {
        _all = list;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'Could not load requests. Check your internet.';
        notifyListeners();
      },
    );
  }
 
  void setFilter(String? bloodGroup) {
    filterBloodGroup = bloodGroup;
    notifyListeners();
  }
 
  /// Returns true when the request was saved.
  Future<bool> addRequest(RequestModel r) async {
    errorMessage = null;
    try {
      if (useDummyData) {
        // Dummy mode: make a local id and add to the list
        _all = [
          ..._all,
          RequestModel(
            id: 'dummy_${DateTime.now().millisecondsSinceEpoch}',
            patientName: r.patientName,
            bloodGroup: r.bloodGroup,
            hospital: r.hospital,
            city: r.city,
            urgency: r.urgency,
            contactPhone: r.contactPhone,
            status: r.status,
            createdBy: r.createdBy,
            createdAt: r.createdAt,
          ),
        ];
        notifyListeners();
      } else {
        await _service.addRequest(r); // the stream updates the list for us
      }
      return true;
    } catch (_) {
      errorMessage = 'Could not post the request. Please try again.';
      notifyListeners();
      return false;
    }
  }
 
  Future<void> markFulfilled(String id) async {
    errorMessage = null;
    try {
      if (useDummyData) {
        _all = _all
            .map((r) => r.id == id ? r.copyWith(status: statusFulfilled) : r)
            .toList();
        notifyListeners();
      } else {
        await _service.updateStatus(id, statusFulfilled);
      }
    } catch (_) {
      errorMessage = 'Could not update the request.';
      notifyListeners();
    }
  }
 
  Future<void> deleteRequest(String id) async {
    errorMessage = null;
    try {
      if (useDummyData) {
        _all = _all.where((r) => r.id != id).toList();
        notifyListeners();
      } else {
        await _service.deleteRequest(id);
      }
    } catch (_) {
      errorMessage = 'Could not delete the request.';
      notifyListeners();
    }
  }
 
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
 
  // ---------- Dummy data (used when useDummyData = true) ----------
 
  List<RequestModel> _buildDummyRequests() {
    final now = DateTime.now();
    return [
      RequestModel(
          id: 'd1', patientName: 'Ravi Kumar', bloodGroup: 'O-',
          hospital: 'Victoria Hospital', city: 'Bengaluru', urgency: 'Critical',
          contactPhone: '9876500001', createdBy: dummyUserUid,
          createdAt: now.subtract(const Duration(minutes: 40))),
      RequestModel(
          id: 'd2', patientName: 'Anita Rao', bloodGroup: 'A+',
          hospital: 'Manipal Hospital', city: 'Bengaluru', urgency: 'High',
          contactPhone: '9876500002', createdBy: 'other_user_1',
          createdAt: now.subtract(const Duration(hours: 2))),
      RequestModel(
          id: 'd3', patientName: 'Suresh Gowda', bloodGroup: 'B+',
          hospital: 'KR Hospital', city: 'Mysuru', urgency: 'Normal',
          contactPhone: '9876500003', createdBy: 'other_user_2',
          createdAt: now.subtract(const Duration(hours: 5))),
      RequestModel(
          id: 'd4', patientName: 'Meena Shetty', bloodGroup: 'AB+',
          hospital: 'Wenlock Hospital', city: 'Mangaluru', urgency: 'Critical',
          contactPhone: '9876500004', createdBy: 'other_user_3',
          createdAt: now.subtract(const Duration(hours: 1))),
      RequestModel(
          id: 'd5', patientName: 'Imran Khan', bloodGroup: 'O+',
          hospital: 'Apollo Hospital', city: 'Hyderabad', urgency: 'High',
          contactPhone: '9876500005', createdBy: dummyUserUid,
          createdAt: now.subtract(const Duration(hours: 8))),
      RequestModel(
          id: 'd6', patientName: 'Lakshmi Iyer', bloodGroup: 'A-',
          hospital: 'MIOT Hospital', city: 'Chennai', urgency: 'Normal',
          contactPhone: '9876500006', createdBy: 'other_user_4',
          createdAt: now.subtract(const Duration(days: 1))),
      RequestModel(
          id: 'd7', patientName: 'Prakash Joshi', bloodGroup: 'B-',
          hospital: 'KIMS Hospital', city: 'Hubballi', urgency: 'Critical',
          contactPhone: '9876500007', createdBy: 'other_user_5',
          createdAt: now.subtract(const Duration(hours: 3))),
      RequestModel(
          id: 'd8', patientName: 'Divya Nair', bloodGroup: 'O+',
          hospital: 'Aster Medcity', city: 'Kochi', urgency: 'High',
          contactPhone: '9876500008', createdBy: 'other_user_6',
          createdAt: now.subtract(const Duration(days: 2))),
      RequestModel(
          id: 'd9', patientName: 'Rohit Patil', bloodGroup: 'A+',
          hospital: 'Ruby Hall Clinic', city: 'Pune', urgency: 'Normal',
          contactPhone: '9876500009', status: statusFulfilled,
          createdBy: dummyUserUid,
          createdAt: now.subtract(const Duration(days: 3))),
    ];
  }
}