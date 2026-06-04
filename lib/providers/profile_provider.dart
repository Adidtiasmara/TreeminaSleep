import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../services/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  int? _age;
  bool _isLoading = false;

  int? get age => _age;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    loadAge();
  }

  Future<void> loadAge() async {
    _isLoading = true;
    notifyListeners();

    _age = SupabaseService.isConfigured && SupabaseService.isLoggedIn
        ? await SupabaseService.getAge()
        : StorageService.getAge();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAge(int age) async {
    _age = age;
    notifyListeners();

    if (SupabaseService.isConfigured && SupabaseService.isLoggedIn) {
      await SupabaseService.updateAge(age);
    } else {
      await StorageService.setAge(age);
    }
  }

  void clear() {
    _age = null;
    notifyListeners();
  }
}
