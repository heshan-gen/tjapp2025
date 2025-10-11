import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact_numbers.dart';

class ContactNumbersService {
  static const String _baseUrl =
      'https://topjobs.lk/general/contactus/contact_numbers.json';

  static Future<ContactNumbers?> fetchContactNumbers() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ContactNumbers.fromJson(jsonData);
      } else {
        print('Failed to fetch contact numbers: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching contact numbers: $e');
      return null;
    }
  }
}
