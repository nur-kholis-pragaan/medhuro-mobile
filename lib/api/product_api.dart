import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medhuro_mobile/model/product_model.dart';
import '/config/endpoint_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductApi {
  Future<ProductModel?> getProducts({
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
        EndpointConfig.path['product']!,
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<ProductDataModel?> getProductDetail(int id) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        '${EndpointConfig.path['product']}/$id',
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        print('ProductApi.getProductDetail response: ${response.body}');
        final jsonResponse = json.decode(response.body);
        return ProductDataModel.fromJson(jsonResponse['data']);
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
