import 'package:isar/isar.dart';

part 'license_stats_view.g.dart';

@collection
class LicenseStatsView {
  Id id = Isar.autoIncrement;
  
  int? totalStudents;
  int? totalClasses;
  int? totalUsers;
  int? totalPayments;
  DateTime? lastCalculated;
  
  
  String? licenseType; // 'trial', 'premium', 'standard'
  
  // Constructor
  LicenseStatsView({
    this.totalStudents,
    this.totalClasses,
    this.totalUsers,
    this.totalPayments,
    this.lastCalculated,
    this.licenseType,
  });
}
