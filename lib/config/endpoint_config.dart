class EndpointConfig {
  // static const String domain = 'dev-medhuro.inalife.id';
  static const String domain = 'unfumbled-otiosely-brigida.ngrok-free.dev';

  static const Map<String, String> path = {
    'auth.login': '/api/auth/login',
    'auth.logout': '/api/auth/logout',
    'auth': '/api/auth',
    'product': '/api/product',
    'customer': '/api/customers',
    'payment_terms': '/api/payment-terms',
    'payment_methods': '/api/payment-methods',
    'sales': '/api/sales',
    'my_sales': '/api/my-sales',
    'my_stats': '/api/my-stats',
    'sales_payments': '/api/sales-payments',
  };
}
