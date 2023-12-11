class Promotion {
  static const String keyDiscountValue = "discountValue";
  static const String keyName = "name";

  Promotion(
      {
      required this.discountValue,
      required this.name});

  double discountValue;
  String name;

  Promotion copy(Promotion promotion){
    return Promotion(
      discountValue: promotion.discountValue,
      name: promotion.name,
    );
  }
}
