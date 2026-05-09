import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medhuro_mobile/model/customer_model.dart';
import '/config/endpoint_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerApi {
  /// Get all customers with pagination and search
  Future<CustomerModel?> getCustomers({
    String? search,
    String? page,
    String? limit,
    String? sortBy = 'name',
    String? sort = 'asc',
  }) async {
    try {
      final Map<String, dynamic> params = {
        'sort_by': sortBy ?? 'name',
        'sort': sort ?? 'asc',
        'limit': limit ?? '20',
        'page': page ?? '1',
      };

      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['customer']!,
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        return CustomerModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('CustomerApi.getCustomers error: ${e.toString()}');
      return null;
    }
  }

  /// Get customer detail
  Future<CustomerDataModel?> getCustomerDetail(String customerId) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        '${EndpointConfig.path['customer']}/$customerId',
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return CustomerDataModel.fromJson(jsonResponse['data']);
      } else {
        return null;
      }
    } catch (e) {
      print('CustomerApi.getCustomerDetail error: ${e.toString()}');
      return null;
    }
  }

  /// Create new customer
  Future<CustomerDataModel?> createCustomer({
    required String code,
    required String name,
    required String phoneNumber,
    required String address,
    String? cityName,
    double? latitude,
    double? longitude,
    bool isActive = true,
  }) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['customer']!,
      );

      final body = {
        'code': code,
        'name': name,
        'phone_number': phoneNumber,
        'address': address,
        if (cityName != null) 'city_name': cityName,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'is_active': isActive,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${prefs.getString("token")}',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (response.statusCode == 201) {
        return CustomerDataModel.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 422) {
        // Handle validation errors
        final errors = jsonResponse['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages =
              errors.values.expand((e) => (e as List).cast<String>()).toList();
          throw Exception(errorMessages.join('\n'));
        }
        throw Exception(jsonResponse['message'] ?? 'Validation error');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception(jsonResponse['message'] ?? 'Gagal tambah customer');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      print('CustomerApi.createCustomer error: ${e.toString()}');
      rethrow;
    }
  }

  /// Update customer
  Future<CustomerDataModel?> updateCustomer({
    required String customerId,
    required String code,
    required String name,
    required String phoneNumber,
    required String address,
    String? cityName,
    double? latitude,
    double? longitude,
    bool isActive = true,
  }) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        '${EndpointConfig.path['customer']}/$customerId',
      );

      final body = {
        'code': code,
        'name': name,
        'phone_number': phoneNumber,
        'address': address,
        if (cityName != null) 'city_name': cityName,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'is_active': isActive,
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer ${prefs.getString("token")}',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      final jsonResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        return CustomerDataModel.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 422) {
        // Handle validation errors
        final errors = jsonResponse['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final errorMessages =
              errors.values.expand((e) => (e as List).cast<String>()).toList();
          throw Exception(errorMessages.join('\n'));
        }
        throw Exception(jsonResponse['message'] ?? 'Validation error');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception(jsonResponse['message'] ?? 'Gagal update customer');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      print('CustomerApi.updateCustomer error: ${e.toString()}');
      rethrow;
    }
  }
}
