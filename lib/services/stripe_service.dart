import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();

  static const _storage = FlutterSecureStorage();
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static Future<Dio> _dio() async {
    final token = await _storage.read(key: 'access_token');
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    ));
  }

  /// Calls the backend to create a PaymentIntent, then presents
  /// Stripe's built-in payment sheet.
  ///
  /// [invoiceId]  — the fee invoice ID from the backend
  /// [amountAed]  — display amount in AED (informational; backend sets the real amount)
  /// [description] — shown in the payment sheet header
  ///
  /// Returns `true` on success, throws on failure.
  static Future<bool> payFee({
    required String invoiceId,
    required int amountAed,
    required String description,
  }) async {
    final dio = await _dio();

    // 1. Ask the backend to create a PaymentIntent.
    //    Expected response: { clientSecret: "...", publishableKey: "..." }
    final res = await dio.post(
      '/api/sms/fees/$invoiceId/pay',
      data: {'amount': amountAed * 100, 'currency': 'aed'},
    );

    final data = res.data as Map<String, dynamic>;
    final clientSecret = data['clientSecret'] as String;

    // 2. If the backend returns a live publishable key, override the one
    //    set at startup (e.g. switching test → live mid-session).
    final publishableKey = data['publishableKey'] as String?;
    if (publishableKey != null && publishableKey.isNotEmpty) {
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();
    }

    // 3. Initialise the payment sheet.
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Al-Abraar Academy',
        style: ThemeMode.light,
        appearance: const PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            primary: Color(0xFF166534),
          ),
        ),
      ),
    );

    // 4. Present the sheet — throws StripeException on cancel or failure.
    await Stripe.instance.presentPaymentSheet();
    return true;
  }
}
