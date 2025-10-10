import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/banner.dart';

class BannerService {
  static const String _baseUrl =
      'https://topjobs.lk/banner/mobile_app_banners/banner_paths_rn.json';

  static Future<BannerResponse> fetchBanners() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return BannerResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching banners: $e');
    }
  }

  static Future<List<Banner>> fetchPLPBanners() async {
    try {
      final bannerResponse = await fetchBanners();
      return bannerResponse.getPLPBanners();
    } catch (e) {
      print('Error fetching PLP banners: $e');
      return [];
    }
  }
}
