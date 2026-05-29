import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medhuro_mobile/model/sales_model.dart';
import '/config/endpoint_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesApi {
  Future<SalesDataModel?> createSales({
    required String customerId,
    required int paymentTermId,
    required String salesDate,
    required int discountAmount,
    required int cashAmount,
    required List<Map<String, dynamic>> items,
    List<Map<String, dynamic>>? returnItems,
  }) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['sales']!,
      );

      final body = {
        'customer_id': int.parse(customerId),
        'payment_term_id': paymentTermId,
        'sales_date': salesDate,
        'discount_amount': discountAmount,
        'cash_amount': cashAmount,
        'items': items,
        if (returnItems != null && returnItems.isNotEmpty)
          'return_items': returnItems,
      };

      debugPrint('Creating sales with body: $body');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${prefs.getString("token")}',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return SalesDataModel.fromJson(jsonResponse['data']);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<SalesModel?> getMySales({
    String? search,
    String? customerId,
    String? dateFrom,
    String? dateTo,
    String? page,
    String? limit,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': limit ?? '15',
        'page': page ?? '1',
        if (search != null) 'search': search,
        if (customerId != null) 'customer_id': customerId,
        if (dateFrom != null) 'date_from': dateFrom,
        if (dateTo != null) 'date_to': dateTo,
      };

      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['my_sales']!,
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });
      // print(uri.toString());
      // print('getMySales response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return SalesModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<SalesDataModel?> getSalesDetail(int id) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        '${EndpointConfig.path['sales']}/$id',
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return SalesDataModel.fromJson(jsonResponse['data']);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
