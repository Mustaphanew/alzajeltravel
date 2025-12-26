/// ===================================================================
/// Seat
/// ===================================================================
/// هذا الموديل يمثل مقعد واحد في الطائرة.
///
/// - name:
///   اسم أو رقم المقعد كما يظهر في مخطط المقاعد،
///   مثل: "A12", "B16", "C3"
///
/// - fare:
///   تكلفة هذا المقعد (يتم إضافتها إلى سعر التذكرة الأساسي للراكب)
class Seat {
  /// اسم / كود المقعد (مثال: A12)
  final String name;

  /// تكلفة هذا المقعد (مثال: 20.0)
  final double fare;

  const Seat({
    required this.name,
    required this.fare,
  });

  /// تحويل إلى JSON (مفيد عند الإرسال أو التخزين)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fare': fare,
    };
  }

  /// إنشاء Seat من JSON
  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      name: json['name']?.toString() ?? '',
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() => 'Seat(name: $name, fare: $fare)';
}
