import 'beverage_type.dart';

class WaterRecord {
  final String id;
  final DateTime timestamp;
  final int amountInMl;
  final BeverageType beverageType;

  WaterRecord({
    String? id,
    required this.timestamp,
    required this.amountInMl,
    this.beverageType = BeverageType.water,
  }) : id = id ?? '${timestamp.millisecondsSinceEpoch}_$amountInMl';

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'amountInMl': amountInMl,
        'beverageType': beverageType.name,
      };

  factory WaterRecord.fromJson(Map<String, dynamic> json) {
    final ts = DateTime.parse(json['timestamp']);
    final amt = json['amountInMl'] as int;
    return WaterRecord(
      id: json['id'] as String? ?? '${ts.millisecondsSinceEpoch}_$amt',
      timestamp: ts,
      amountInMl: amt,
      beverageType: BeverageType.values.firstWhere(
        (e) => e.name == json['beverageType'],
        orElse: () => BeverageType.water,
      ),
    );
  }
}
