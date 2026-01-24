import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.example.com';

  static const String token =
      r"$2a$10$r6C.F2CjAeZivbPhIipFNOK9PNNlxk.sHyAXijqCLSOUIx7pG79m.";

  static Future<String> createQrCode(String value) async {
    final response = await http.post(
      Uri.parse('https://api.jsonbin.io/v3/b/'),
      headers: {"X-Master-Key": token, "Content-Type": "application/json"},
      body: value,
    );
    print('response ${response.body}');
    var data = jsonDecode(response.body);
    return data['metadata']['id'];
  }

  static Future<String> getQrCode(code) async {
    final response = await http.get(
      Uri.parse('https://api.jsonbin.io/v3/b/$code'),
      headers: {"X-Master-Key": token, "Content-Type": "application/json"},
    );
    print('response ${response.body}');
    var data = jsonDecode(response.body);
    return jsonEncode(data['record']);
  }
}
