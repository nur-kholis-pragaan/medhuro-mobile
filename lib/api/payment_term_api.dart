import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medhuro_mobile/model/payment_term_model.dart';
import '/config/endpoint_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentTermApi {
  Future<PaymentTermModel?> getPaymentTerms() async {
    try {
      final uri = Uri.https(
        EndpointConfig.domain,
        EndpointConfig.path['payment_terms']!,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer ${prefs.getString("token")}',
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        return PaymentTermModel.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
