import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medhuro_mobile/model/receivable_model.dart';
import 'package:medhuro_mobile/model/receivable_detail_model.dart';
import '/config/endpoint_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceivableApi {
  /// Get receivables summary with pagination and search
  Future<ReceivableModel?> getReceivableSummary({
    String? search,
    String? page,
    String? limit,
    String? sortBy = 'total_debt',
    String? sort = 'desc',
  }) async {
    try {
      final Map<String, dynamic> params = {
        'sort_by': sortBy ?? 'total_debt',
        'sort': sort ?? 'desc',
        'limit': limit ?? '15',
        'page': page ?? '1',
      };

      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      final uri = Uri.https(
        EndpointConfig.domain,
        '/api/receivables/summary',
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        return ReceivableModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('ReceivableApi.getReceivableSummary error: ${e.toString()}');
      return null;
    }
  }

  /// Get receivable detail by customer ID
  Future<ReceivableDetailModel?> getReceivableDetail(
    String customerId, {
    String? page,
    String? limit,
    String? sortBy = 'due_date',
    String? sort = 'asc',
  }) async {
    try {
      final Map<String, dynamic> params = {
        'sort_by': sortBy ?? 'due_date',
        'sort': sort ?? 'asc',
        'limit': limit ?? '20',
        'page': page ?? '1',
      };

      final uri = Uri.https(
        EndpointConfig.domain,
        '/api/receivables/$customerId',
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        return ReceivableDetailModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('ReceivableApi.getReceivableDetail error: ${e.toString()}');
      return null;
    }
  }
}
