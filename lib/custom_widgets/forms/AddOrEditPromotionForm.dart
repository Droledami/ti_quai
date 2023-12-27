import 'package:flutter/material.dart';

import '../../custom_materials/theme.dart';
import '../../enums/EntryType.dart';
import '../../models/Promotion.dart';
import '../../processes/functions.dart';
import '../EntryBox.dart';
import '../buttons/FlexIconButton.dart';

class AddOrEditPromotionForm extends StatefulWidget {
  const AddOrEditPromotionForm(
      {super.key,
        required this.onCancel,
        required this.onConfirmAdd,
        this.promotionToEdit,
        this.articleRefOfPromotionToEdit})
      : assert(
  (promotionToEdit != null && articleRefOfPromotionToEdit != null) ||
      (promotionToEdit == null &&
          articleRefOfPromotionToEdit == null),
  "When editing, both the promotion and the articleReference must be not null");

  final Function onCancel;
  final Function(Promotion, String) onConfirmAdd;

  final Promotion? promotionToEdit;
  final String? articleRefOfPromotionToEdit;

  @override
  State<AddOrEditPromotionForm> createState() => _AddOrEditPromotionFormState();
}

class _AddOrEditPromotionFormState extends State<AddOrEditPromotionForm> {
  final _discountValueController = TextEditingController();
  final _promotionNameController = TextEditingController();
  final _linkedArticleController = TextEditingController();

  final _addPromotionFormKey = GlobalKey<FormState>();

  Promotion promotion = Promotion(discountValue: 0, name: "");

  @override
  void initState() {
    super.initState();

    if (widget.promotionToEdit != null) {
      promotion.name = widget.promotionToEdit!.name;
      promotion.discountValue = widget.promotionToEdit!.discountValue;

      _promotionNameController.text = widget.promotionToEdit!.name;
      _discountValueController.text =
      "-${widget.promotionToEdit!.discountValue}€";
      _linkedArticleController.text = widget.articleRefOfPromotionToEdit!;
    }

    _promotionNameController.addListener(() {
      promotion.name = _promotionNameController.text;
    });

    _discountValueController.addListener(() {
      double? discountValue = forcePriceFormat(_discountValueController,
          firstDigitCanBeZero: true, mustBeNegative: true);
      if (discountValue != null) promotion.discountValue = discountValue;
    });

    //Forces case specific format like A followed by any number with the optionnal subalpha (ex: A326b or Z78)
    _linkedArticleController.addListener(() {
      if (RegExp(r"^[a-zA-Z][0-9]+[a-zA-Z]?$")
          .hasMatch(_linkedArticleController.text) &&
          _linkedArticleController.text.length > 1) {
        String content = _linkedArticleController.text;
        if (content.length > 2) {
          String contentUpper =
          content.substring(0, content.length - 1).toUpperCase();
          String contentLower = content
              .substring(content.length - 1, content.length)
              .toLowerCase();
          content = contentUpper + contentLower;
        }
        _linkedArticleController.value = _linkedArticleController.value
            .copyWith(
            text: content,
            selection: TextSelection(
                baseOffset: content.length, extentOffset: content.length));
      }
    });
  }

  @override
  void dispose() {
    _discountValueController.dispose();
    _promotionNameController.dispose();
    _linkedArticleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool editingPromotion = widget.promotionToEdit != null;
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Form(
      key: _addPromotionFormKey,
      child: Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
          child: Container(
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: customColors.primaryDark!, width: 3)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${editingPromotion ? "Modification" : "Ajout"} d'une promotion",
                ),
                EntryBox(
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    } else {
                      return "Veuillez entrer le nom de la promotion";
                    }
                  },
                  orderEntryType: QuaiEntry.text,
                  maxLength: 80,
                  placeholder: "Nom de la promotion...",
                  textEditingController: _promotionNameController,
                  marginLeft: 10,
                ),
                Row(
                  children: [
                    EntryBox(
                      // validator: (value) {
                      //   if (value != null &&
                      //       RegExp(r"^[a-zA-Z][0-9]+[a-zA-Z]?$")
                      //           .hasMatch(value)) {
                      //     return null;
                      //   } else {
                      //     return "Erreur référence";
                      //   }
                      // },
                      flex: 4,
                      orderEntryType: QuaiEntry.text,
                      maxLength: 5,
                      placeholder: "Article associé (ex:A2b)",
                      textEditingController: _linkedArticleController,
                      marginLeft: 10,
                    ),
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            RegExp(r"^-[0-9]+[,.]?[0-9]{0,2}?€$")
                                .hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur réduction";
                        }
                      },
                      flex: 2,
                      orderEntryType: QuaiEntry.price,
                      maxLength: 7,
                      placeholder: "-?€",
                      textEditingController: _discountValueController,
                      marginLeft: 10,
                    )
                  ],
                ),
                Row(
                  children: [
                    FlexIconButton(
                      onTap: () => widget.onCancel(),
                      color: customColors.secondary!,
                      spreadColor: customColors.secondaryLight!,
                      iconData: Icons.backspace,
                      marginLeft: 10,
                    ),
                    Expanded(flex: 2, child: SizedBox.shrink()),
                    FlexIconButton(
                      onTap: () {
                        if (_addPromotionFormKey.currentState!.validate()) {
                          widget.onConfirmAdd(
                              promotion, _linkedArticleController.text);
                        }
                      },
                      color: customColors.secondary!,
                      spreadColor: customColors.secondaryLight!,
                      iconData:
                      editingPromotion ? Icons.check_outlined : Icons.add,
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