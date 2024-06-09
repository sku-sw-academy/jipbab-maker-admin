import 'package:http/http.dart' as http;
import 'package:flutter_admin/constant.dart';
import 'dart:convert';
import 'package:flutter_admin/dto/AuthLoginRequest.dart';
import 'package:flutter_admin/dto/AuthLoginResponse.dart';
import 'package:flutter_admin/dto/AdminDTO.dart';

class AdminService{
  Future<AuthLoginResponse> login(String email, String password) async {
    final url = Uri.parse('${Constants.baseUrl}/api/admin/login');
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(responseBody);
        return AuthLoginResponse.fromJson(responseData);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 오류: $e');
      throw e;
    }
  }

  Future<AdminDTO> getAdminInfo(String refreshToken) async {
    final url = Uri.parse('${Constants.baseUrl}/api/admin/AdminInfo/$refreshToken');
    final headers = <String, String>{
      'Authorization': 'Bearer $refreshToken',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var responseBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(responseBody);
        return AdminDTO.fromJson(responseData);
      } else {
        throw Exception('Failed to get admin info: ${response.statusCode}');
      }
    } catch (e) {
      print('네트워크 오류: $e');
      throw e;
    }
  }
}