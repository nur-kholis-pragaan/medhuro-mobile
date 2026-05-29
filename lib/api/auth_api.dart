import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import '/config/endpoint_config.dart';
import '/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  Future<LoginResponse?> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['auth.login']!,
      );

      final response = await http.post(
        uri,
        body: {
          'email': email,
          'password': password,
        },
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('Login Response: ${response.body}');

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.body);
      } else {
        return LoginResponse.fromJson(response.body);
      }
    } on Exception catch (e) {
      debugPrint('Login Error: $e');
      return null;
    }
  }

  Future<Response?> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['auth.logout']!,
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
          'Accept': 'application/json',
        },
      );

      return response;
    } on Exception catch (e) {
      debugPrint('Logout Error: $e');
      return null;
    }
  }

  Future<LoginResponse?> updateProfile({
    String? name,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['auth.profile']!,
      );

      final body = <String, dynamic>{
        if (name != null) 'name': name,
        if (password != null) 'password': password,
        if (password != null) 'password_confirmation': passwordConfirmation,
      };

      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer ${prefs.getString('token')}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('Update Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.body);
      } else {
        return LoginResponse.fromJson(response.body);
      }
    } on Exception catch (e) {
      debugPrint('Update Profile Error: $e');
      return null;
    }
  }
}

class LoginResponse {
  final bool success;
  final int code;
  final String message;
  final UserModel? data;
  final String? token;

  LoginResponse({
    required this.success,
    required this.code,
    required this.message,
    this.data,
    this.token,
  });

  factory LoginResponse.fromJson(String jsonString) {
    final json = _parseJson(jsonString);
    print("haiaiai");
    print(json);
    return LoginResponse(
      success: json['success'] as bool? ?? false,
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown error',
      data: json['data'] != null
          ? UserModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
    );
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
