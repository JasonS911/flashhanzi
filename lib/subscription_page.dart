import 'package:flashhanzi/utils/subscription_manager.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  bool isLoading = false;
  List<Package> packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      isLoading = true;
    });

    final result = await SubscriptionManager().getAvailablePackages();

    setState(() {
      packages = result;
      isLoading = false;
    });
  }

  Future<void> _subscribe(Package package) async {
    setState(() {
      isLoading = true;
    });

    final success = await SubscriptionManager().purchasePackage(package);

    setState(() {
      isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close paywall
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Purchase failed or cancelled.")));
    }
  }

  Future<void> _restore() async {
    setState(() {
      isLoading = true;
    });

    await SubscriptionManager()
        .initialize(); // This will re-fetch customer info

    setState(() {
      isLoading = false;
    });

    if (SubscriptionManager().isProUser) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close paywall
    } else {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("No purchases found to restore.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon.png', height: 80),
                const SizedBox(height: 16),
                const Text(
                  'FlashHanzi',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Subscribe to Continue',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Access all Chinese characters'),
                    Text('• Spaced repetition reviews'),
                    Text('• Camera and handwriting input'),
                    Text("• Stroke order animations"),
                    Text("• Personal notes and sentences for each character"),
                  ],
                ),
                const SizedBox(height: 24),

                // SUBSCRIPTION BUTTON
                isLoading
                    ? const CircularProgressIndicator()
                    : packages.isNotEmpty
                    ? ElevatedButton(
                      onPressed: () => _subscribe(packages.first),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Subscribe (${packages.first.storeProduct.priceString})',
                      ),
                    )
                    : const Text("No subscription available"),

                const SizedBox(height: 16),

                // RESTORE BUTTON
                TextButton(
                  onPressed: _restore,
                  child: const Text('Restore Purchase ・ Terms ・ Privacy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
