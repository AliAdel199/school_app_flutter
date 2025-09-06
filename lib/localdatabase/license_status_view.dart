import 'package:isar/isar.dart';

part 'license_status_view.g.dart';

@collection
class LicenseStatusView {
  Id id = Isar.autoIncrement;
  
  @Index()
  String? status; // 'activated', 'trial', 'expired'
  
  bool? isActivated;
  bool? isTrialActive;
  int? remainingDays;
  DateTime? lastUpdated;
  String? licenseKey;
  DateTime? activationDate;
  DateTime? expiryDate;
  
  // Constructor
  LicenseStatusView({
    this.status,
    this.isActivated,
    this.isTrialActive,
    this.remainingDays,
    this.lastUpdated,
    this.licenseKey,
    this.activationDate,
    this.expiryDate,
  });
}
