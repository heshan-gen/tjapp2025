import 'package:flutter/material.dart';
import '../models/banner.dart' as banner_model;
import '../services/banner_service.dart';

class BannerProvider with ChangeNotifier {
  List<banner_model.Banner> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<banner_model.Banner> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBanners() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _banners = await BannerService.fetchPLPBanners();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _banners = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
