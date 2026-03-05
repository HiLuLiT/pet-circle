import 'package:flutter/foundation.dart';
import 'package:pet_circle/models/app_user.dart';
import 'package:pet_circle/models/user.dart';

final userStore = UserStore();

class UserStore extends ChangeNotifier {
  User? _currentUser;
  AppUserRole _role = AppUserRole.owner;

  User? get currentUser => _currentUser;
  AppUserRole get role => _role;
  bool get isVet => _role == AppUserRole.vet;
  bool get isOwner => _role == AppUserRole.owner;

  void seed(User user) {
    _currentUser = user;
    _role = user.role == UserRole.vet ? AppUserRole.vet : AppUserRole.owner;
    notifyListeners();
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void setRole(AppUserRole role) {
    _role = role;
    notifyListeners();
  }
}
