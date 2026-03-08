import 'package:razorpay_flutter/razorpay_flutter.dart';

typedef PaymentSuccessCallback = void Function(String paymentId, String orderId, String signature);
typedef PaymentErrorCallback = void Function(String message);

class PaymentService {
  final Razorpay _razorpay = Razorpay();

  // Replace with your actual Razorpay key
  static const String _razorpayKey = 'rzp_test_SOJEl9fAYY7PeY';

  void initialize({
    required PaymentSuccessCallback onSuccess,
    required PaymentErrorCallback onError,
  }) {
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      (PaymentSuccessResponse response) {
        onSuccess(
          response.paymentId ?? '',
          response.orderId ?? '',
          response.signature ?? '',
        );
      },
    );
    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      (PaymentFailureResponse response) {
        onError(response.message ?? 'Payment failed');
      },
    );
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      (ExternalWalletResponse response) {},
    );
  }

  void openCheckout({
    required double amount,
    required String phone,
    required String name,
    String? email,
    String? description,
    String? prefillName,
  }) {
    final options = <String, dynamic>{
      'key': _razorpayKey,
      'amount': (amount * 100).toInt(), // Convert to paise
      'name': 'FashionApp',
      'description': description ?? 'Fashion Order',
      'prefill': {
        'contact': phone,
        if (email != null) 'email': email,
        if (prefillName != null) 'name': prefillName,
      },
      'theme': {'color': '#008080'},
      'retry': {'enabled': true, 'max_count': 3},
    };
    _razorpay.open(options);
  }

  void dispose() => _razorpay.clear();
}
