import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medhuro_mobile/model/customer_model.dart';
import '/config/endpoint_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerApi {
  Future<CustomerModel?> getCustomers({
    String? search,
    String? page,
    String? limit,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': limit ?? '50',
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
      print(e.toString());
      return null;
    }
  }
}
