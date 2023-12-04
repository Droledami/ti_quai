class Promotion {
  static const String keyDiscountValue = "discountValue";
  static const String keyNameLong = "nameLong";
  static const String keyNameShort = "nameShort";

  Promotion(
      {
      required this.discountValue,
      required this.nameLong,
      required this.nameShort});

  double discountValue;
  String nameLong;
  String nameShort;
}
