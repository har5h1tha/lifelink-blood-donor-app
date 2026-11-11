import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;
  bool get isLoggedIn => currentUser != null;

  // Completes once we know whether someone is logged in (used by the splash screen)
  final Completer<void> _ready = Completer<void>();
  Future<void> get ready => _ready.future;
  StreamSubscription? _sub;

  /// Call once at app start.
  void init() {
    if (useDummyData) {
      _markReady();
      return;
    }
    // Firebase remembers the session. This stream fires at start-up and
    // again on every login / logout.
    _sub = _service.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        currentUser = null;
      } else {
        final profile = await _service.fetchProfile(firebaseUser.uid);
        // Only overwrite when found: during register(), the profile may not be saved yet.
        if (profile != null) currentUser = profile;
      }
      _markReady();
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _start();
    try {
      if (useDummyData) {
        await Future.delayed(const Duration(milliseconds: 600));
        currentUser = _dummyUser(email: email);
      } else {
        currentUser = await _service.login(email, password);
        if (currentUser == null) {
          errorMessage = 'Profile not found. Please register again.';
          _stop();
          return false;
        }
      }
      _stop();
      return true;
    } on AuthFailure catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }
    _stop();
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String bloodGroup,
    required String city,
    required String phone,
  }) async {
    _start();
    try {
      if (useDummyData) {
        await Future.delayed(const Duration(milliseconds: 600));
        currentUser = _dummyUser(
          email: email, name: name, bloodGroup: bloodGroup, city: city, phone: phone,
        );
      } else {
        currentUser = await _service.register(
          email: email, password: password, name: name,
          bloodGroup: bloodGroup, city: city, phone: phone,
        );
      }
      _stop();
      return true;
    } on AuthFailure catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
    }
    _stop();
    return false;
  }

  Future<void> logout() async {
    if (!useDummyData) await _service.logout();
    currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile(UserModel updated) async {
    _start();
    try {
      if (!useDummyData) await _service.saveProfile(updated);
      currentUser = updated;
      _stop();
      return true;
    } catch (_) {
      errorMessage = 'Could not save changes. Please try again.';
      _stop();
      return false;
    }
  }

  Future<void> setAvailability(bool value) async {
    final old = currentUser;
    if (old == null) return;
    // Update the screen immediately, then save. Undo if saving fails.
    currentUser = old.copyWith(isAvailable: value);
    notifyListeners();
    if (useDummyData) return;
    try {
      await _service.saveProfile(currentUser!);
    } catch (_) {
      currentUser = old;
      errorMessage = 'Could not update availability.';
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // ---------- private helpers ----------
  void _start() {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void _stop() {
    isLoading = false;
    notifyListeners();
  }

  void _markReady() {
    if (!_ready.isCompleted) _ready.complete();
  }

  UserModel _dummyUser({
    String email = 'demo@lifelink.app',
    String name = 'Demo User',
    String bloodGroup = 'O+',
    String city = 'Bengaluru',
    String phone = '9876543210',
  }) {
    return UserModel(
      uid: 'dummy-uid',
      name: name,
      email: email,
      bloodGroup: bloodGroup,
      city: city,
      phone: phone,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
