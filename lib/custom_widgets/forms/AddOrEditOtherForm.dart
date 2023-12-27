import 'package:flutter/material.dart';

import '../../custom_materials/theme.dart';
import '../../enums/EntryType.dart';
import '../../models/Article.dart';
import '../../models/OrderElement.dart';
import '../../processes/functions.dart';
import '../EntryBox.dart';
import '../buttons/FlexIconButton.dart';

class AddOrEditOtherForm extends StatefulWidget {
  const AddOrEditOtherForm(
      {super.key,
        required this.onCancel,
        required this.onConfirmAdd,
        this.otherToEdit});

  final Function onCancel;
  final Function(OrderElement) onConfirmAdd;

  final OrderElement? otherToEdit;

  @override
  State<AddOrEditOtherForm> createState() => _AddOrEditOtherFormState();
}

class _AddOrEditOtherFormState extends State<AddOrEditOtherForm> {
  OrderElement otherOrderElement =
  OrderElement(article: Article.other(name: "", price: -1), quantity: 1);

  final TextEditingController _otherProductNameController =
  TextEditingController();
  final TextEditingController _quantityOtherProductController =
  TextEditingController();
  final TextEditingController _priceOtherProductController =
  TextEditingController();

  final _addOtherFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.otherToEdit != null) {
      otherOrderElement = widget.otherToEdit!.copy();

      _otherProductNameController.text = otherOrderElement.articleName;
      _priceOtherProductController.text = "${otherOrderElement.articlePrice}€";
      _quantityOtherProductController.text =
          otherOrderElement.quantity.toString();
    }

    _otherProductNameController.addListener(() {
      otherOrderElement.article.name = _otherProductNameController.text;
    });

    _quantityOtherProductController.addListener(() {
      if (int.tryParse(_quantityOtherProductController.text) != null) {
        otherOrderElement.quantity =
            int.parse(_quantityOtherProductController.text);
      }
    });

    _priceOtherProductController.addListener(() {
      double? price = forcePriceFormat(_priceOtherProductController,
          firstDigitCanBeZero: false, mustBeNegative: false);
      if (price != null) otherOrderElement.article.price = price;
    });

    super.initState();
  }

  @override
  void dispose() {
    _quantityOtherProductController.dispose();
    _otherProductNameController.dispose();
    _priceOtherProductController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool editingOther = widget.otherToEdit != null;
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Form(
      key: _addOtherFormKey,
      child: Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: customColors.primaryDark!, width: 3)),
            child: Column(
              children: [
                Text(
                    "${editingOther ? "Modification" : "Ajout"} d'un produit ${editingOther ? "(nom du produit à modifier)" : ""}"),
                Row(
                  children: [
                    EntryBox(
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return null;
                          } else {
                            return "Veuillez donner le nom du produit";
                          }
                        },
                        orderEntryType: QuaiEntry.text,
                        maxLength: 150,
                        placeholder: "Nom du produit...",
                        textEditingController: _otherProductNameController,
                        marginLeft: 10),
                  ],
                ),
                Row(
                  children: [
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            RegExp(r"^[1-9][0-9]*$").hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur Quantité";
                        }
                      },
                      orderEntryType: QuaiEntry.quantity,
                      maxLength: 2,
                      placeholder: "Quantité...",
                      textEditingController: _quantityOtherProductController,
                      marginLeft: 10,
                    ),
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            RegExp(r"^[1-9][0-9]*[,.]?[0-9]{0,2}€?$")
                                .hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur Prix";
                        }
                      },
                      orderEntryType: QuaiEntry.price,
                      maxLength: 10,
                      placeholder: "Prix du produit...",
                      textEditingController: _priceOtherProductController,
                      marginLeft: 5,
                    ),
                  ],
                ),
                Row(
                  children: [
                    FlexIconButton(
                      onTap: () => widget.onCancel(),
                      color: customColors.primary!,
                      spreadColor: customColors.primaryDark!,
                      iconData: Icons.backspace,
                      marginLeft: 10,
                    ),
                    Expanded(flex: 2, child: SizedBox.shrink()),
                    FlexIconButton(
                      onTap: () {
                        if (_addOtherFormKey.currentState!.validate()) {
                          //Apeller la validation puis si correct appeler widget.onConfirmAdd
                          widget.onConfirmAdd(otherOrderElement);
                        }
                      },
                      color: customColors.primary!,
                      spreadColor: customColors.primaryDark!,
                      iconData: editingOther ? Icons.check_outlined : Icons.add,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}