class EndpointConfig {
  static const String domain = 'dev-medhuro.inalife.id';

  static const Map<String, String> path = {
    'auth.login': '/api/auth/login',
    'auth.logout': '/api/auth/logout',
    'auth': '/api/auth',
    'product': '/api/product',
    'customer': '/api/customers',
    'payment_terms': '/api/payment-terms',
    'sales': '/api/sales',
    'my_sales': '/api/my-sales',
  };
}
