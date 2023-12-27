class EditOrAddScreenArguments {
  final String orderId;
  final bool isEditMode;
  final bool isOrderPaid;

  static const String keyDefinedLater = "-definedLater-";

  EditOrAddScreenArguments(
      {required this.orderId,
        required this.isEditMode,
        required this.isOrderPaid});
}