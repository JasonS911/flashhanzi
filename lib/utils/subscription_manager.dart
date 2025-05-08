import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flashhanzi/secrets.dart';

class SubscriptionManager {
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  factory SubscriptionManager() => _instance;
  SubscriptionManager._internal();

  bool isProUser = false;

  Future<void> initialize() async {
    // Initialize RevenueCat with your public SDK key
    await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(revenueCatPublicKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(revenueCatPublicKeyIOS);
    } else {
      throw Exception("Unsupported platform");
    }

    await Purchases.configure(configuration);

    // Listen to subscription status changes
    Purchases.addCustomerInfoUpdateListener(_customerInfoUpdated);

    // Check current status
    await _refreshSubscriptionStatus();
  }

  Future<void> _refreshSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      isProUser = customerInfo.entitlements.all["pro"]?.isActive ?? false;
    } catch (e) {
      isProUser = false;
    }
  }

  void _customerInfoUpdated(CustomerInfo customerInfo) {
    isProUser = customerInfo.entitlements.all["pro"]?.isActive ?? false;
  }

  Future<List<Package>> getAvailablePackages() async {
    Offerings offerings = await Purchases.getOfferings();

    if (offerings.current != null) {
      return offerings.current!.availablePackages;
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      isProUser = customerInfo.entitlements.all["pro"]?.isActive ?? false;
      return isProUser;
    } catch (e) {
      return false;
    }
  }
}
