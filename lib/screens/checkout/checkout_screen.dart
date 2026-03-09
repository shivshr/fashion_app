import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/constants/app_routes.dart';
import 'package:fashion_app/core/utils/extensions.dart';
import 'package:fashion_app/core/utils/validators.dart';
import 'package:fashion_app/models/user_model.dart';
import 'package:fashion_app/providers/auth_provider.dart';
import 'package:fashion_app/providers/cart_provider.dart';
import 'package:fashion_app/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillAddress();
  }

  
  /// Autofill add from gps
 
  Future<void> _prefillAddress() async {

    final locationAsync = ref.read(locationProvider);

    locationAsync.whenData((addressString) {

      final parts = addressString.split(',').map((e) => e.trim()).toList();

      /// street
      if (parts.isNotEmpty) {
        _streetCtrl.text = parts[0];
      }

      /// city
      if (parts.length > 1) {
        _cityCtrl.text = parts[1];
      }

      /// state and pincode 
      if (parts.length > 2) {

        final statePin = parts[2];

        final pinRegex = RegExp(r'\d{5,6}');
        final match = pinRegex.firstMatch(statePin);

        if (match != null) {

          _pincodeCtrl.text = match.group(0)!;

          final state = statePin.replaceAll(match.group(0)!, '').trim();
          _stateCtrl.text = state;

        } else {

          _stateCtrl.text = statePin;

        }
      }

      /// PINCODE in different part 
      if (parts.length > 3 && _pincodeCtrl.text.isEmpty) {

        final pinRegex = RegExp(r'\d{5,6}');
        final match = pinRegex.firstMatch(parts[3]);

        if (match != null) {
          _pincodeCtrl.text = match.group(0)!;
        }
      }
    });

    /// USER PROFILE FALLBACK

    final user = ref.read(currentUserProfileProvider).value;

    if (user?.address != null) {

      _nameCtrl.text = user?.name ?? '';

      if (_streetCtrl.text.isEmpty) {
        _streetCtrl.text = user!.address!.street;
      }

      if (_cityCtrl.text.isEmpty) {
        _cityCtrl.text = user!.address!.city;
      }

      if (_stateCtrl.text.isEmpty) {
        _stateCtrl.text = user!.address!.state;
      }

      if (_pincodeCtrl.text.isEmpty) {
        _pincodeCtrl.text = user!.address!.pincode;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  
  
  void _proceed() {           /// PROCEED TO PAYMENT

    if (!_formKey.currentState!.validate()) return;

    final address = AddressModel(
      street: _streetCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
    );

    context.push(
      AppRoutes.payment,
      extra: {
        'address': address,
        'name': _nameCtrl.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final shipping = ref.watch(cartShippingFeeProvider);

    return Scaffold(

      appBar: AppBar(title: const Text('Checkout')),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              /// NAME
              TextFormField(
                controller: _nameCtrl,
                validator: Validators.required,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),

              const SizedBox(height: 12),

              /// STREET
              TextFormField(
                controller: _streetCtrl,
                validator: Validators.required,
                decoration: const InputDecoration(labelText: 'Street Address'),
                maxLines: 2,
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  /// CITY
                  Expanded(
                    child: TextFormField(
                      controller: _cityCtrl,
                      validator: Validators.required,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// STATE
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      validator: Validators.required,
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// PINCODE
              TextFormField(
  controller: _pincodeCtrl,
  validator: Validators.pincode,
  keyboardType: TextInputType.number,
  maxLength: 6,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
  ],
  decoration: const InputDecoration(
    labelText: 'Pincode',
    counterText: '',
  ),
),

              const SizedBox(height: 24),

              /// ORDER SUMMARY
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),

                  child: Row(
                    children: [

                      Expanded(
                        child: Text(
                          '${item.name} (x${item.quantity})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Text(
                        item.subtotal.inr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),

              _Row('Subtotal', subtotal.inr),

              _Row(
                'Shipping',
                shipping == 0 ? 'FREE' : shipping.inr,
              ),

              const Divider(height: 16),

              _Row('Total', total.inr, bold: true),

              const SizedBox(height: 24),

              /// PAY BUTTON
              ElevatedButton(
                onPressed: _proceed,
                child: Text('Pay ${total.inr}'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {

  final String label;
  final String value;
  final bool bold;

  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(
            label,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.w700
                  : FontWeight.normal,
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.w800
                  : FontWeight.w600,
              color: bold
                  ? AppColors.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}