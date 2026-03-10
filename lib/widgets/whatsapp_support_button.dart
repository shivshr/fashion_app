import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppSupportButton extends StatelessWidget {
  WhatsAppSupportButton({super.key});

  final String phone = "918305771664";

  Future<void> _openWhatsApp() async {
    const message = "Hello Balaji Textile, I need help regarding a product.";

    final url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      right: 16,
      child: GestureDetector(
        onTap: _openWhatsApp,
        child: Positioned(
  bottom: 90,
  right: 16,
  child: GestureDetector(
    onTap: _openWhatsApp,
    child: SizedBox(
      height: 55,
      width: 55,
      child: Image.asset(
        "assets/images/whatsapp.png",
        fit: BoxFit.contain,
      ),
    ),
  ),
)
      ),
    );
  }
}