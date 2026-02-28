import 'package:flutter/material.dart';

/// Manages the user's subscription state and access to Premium features.
class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  /// Unlocks all Aegis Premium capabilities (AI Digest, Unlimited Shares)
  void upgradeToPremium() {
    _isPremium = true;
    notifyListeners();
  }

  /// Reverts to the free tier
  void downgradeToFree() {
    _isPremium = false;
    notifyListeners();
  }
}
