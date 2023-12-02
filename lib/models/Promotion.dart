class Promotion {
  static const String keyId = "id";
  static const String keyDiscountValue = "discountValue";
  static const String keyNameLong = "nameLong";
  static const String keyNameShort = "nameShort";

  Promotion(
      {required this.id,
      required this.discountValue,
      required this.nameLong,
      required this.nameShort});

  String id;
  double discountValue;
  String nameLong;
  String nameShort;
}
