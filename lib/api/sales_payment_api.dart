import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medhuro_mobile/model/sales_payment_term_model.dart';
import 'package:medhuro_mobile/model/payment_method_model.dart';
import '/config/endpoint_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesPaymentApi {
  /// Get receivables list with pagination, search, and filtering
  /// GET /api/sales-payments
  Future<SalesPaymentTermModel?> getReceivables({
    String? customerId,
    String? status,
    String? dueFrom,
    String? dueTo,
    String? page,
    String? limit,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': limit ?? '15',
        'page': page ?? '1',
      };

      if (customerId != null && customerId.isNotEmpty) {
        params['customer_id'] = customerId;
      }
      if (status != null && status.isNotEmpty) {
        params['status'] = status;
      }
      if (dueFrom != null && dueFrom.isNotEmpty) {
        params['due_from'] = dueFrom;
      }
      if (dueTo != null && dueTo.isNotEmpty) {
        params['due_to'] = dueTo;
      }

      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['sales_payments']!,
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });
      if (response.statusCode == 200) {
        return SalesPaymentTermModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('SalesPaymentApi.getReceivables error: ${e.toString()}');
      return null;
    }
  }

  /// Get receivables for specific customer
  /// GET /api/sales-payments/by-customer?customer_id=X
  Future<List<SalesPaymentTermDataModel>?> getReceivablesByCustomer(
    String customerId,
  ) async {
    try {
      final Map<String, dynamic> params = {
        'customer_id': customerId,
      };

      final uri = Uri.https(
        EndpointConfig.domain,
        '${EndpointConfig.path['sales_payments']}/by-customer',
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> dataList = jsonResponse['data'] is List
              ? jsonResponse['data']
              : [jsonResponse['data']];

          return List<SalesPaymentTermDataModel>.from(
            dataList.map((x) => SalesPaymentTermDataModel.fromJson(x)),
          );
        }
      }
      return null;
    } catch (e) {
      print('SalesPaymentApi.getReceivablesByCustomer error: ${e.toString()}');
      return null;
    }
  }

  /// Get payment methods
  /// GET /api/payment-methods
  Future<PaymentMethodModel?> getPaymentMethods({
    String? page,
    String? limit,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': limit ?? '50',
        'page': page ?? '1',
      };

      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['payment_methods']!,
        params,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        return PaymentMethodModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('SalesPaymentApi.getPaymentMethods error: ${e.toString()}');
      return null;
    }
  }

  /// Create sales payment
  /// POST /api/sales-payments
  Future<Map<String, dynamic>?> createPayment({
    required String customerId,
    required String paymentMethodId,
    required String paymentDate,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    String? note,
    String? referenceNumber,
  }) async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['sales_payments']!,
      );

      final body = {
        'customer_id': customerId,
        'payment_method_id': paymentMethodId,
        'payment_date': paymentDate,
        'total_amount': totalAmount,
        'items': items,
        if (note != null && note.isNotEmpty) 'note': note,
        if (referenceNumber != null && referenceNumber.isNotEmpty)
          'reference_number': referenceNumber,
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': jsonResponse['message'] ?? 'Payment berhasil dibuat',
          'data': jsonResponse['data'],
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Validasi gagal',
          'errors': jsonResponse['errors'],
        };
      } else {
        return {
          'success': false,
          'message': jsonResponse['message'] ?? 'Gagal membuat pembayaran',
        };
      }
    } catch (e) {
      print('SalesPaymentApi.createPayment error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
