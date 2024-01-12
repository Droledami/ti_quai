import 'package:flutter/material.dart';
import 'package:ti_quai/enums/EntryType.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/Article.dart';
import '../models/OrderElement.dart';
import '../models/Promotion.dart';

String getHourAndMinuteString(DateTime date) {
  final String time = "${date.hour}:${date.minute < 10 ? "0${date.minute}": "${date.minute}"}";
  return time;
}

String getFullDate(DateTime date){
  final String time = "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}";
  return time;
}

bool checkIfEntryIsValid(QuaiEntry orderEntry, String entry){
  switch(orderEntry){
    case QuaiEntry.tableNumber:
      return RegExp(r"^[0-9]{1,2}$").hasMatch(entry);
    case QuaiEntry.alpha:
      return RegExp(r"^[A-Z]$").hasMatch(entry);
    case QuaiEntry.number:
      return RegExp(r"^[0-9]{1,3}$").hasMatch(entry);
    case QuaiEntry.subAlpha:
      return RegExp(r"^[a-z]$").hasMatch(entry);
    case QuaiEntry.quantity:
      return RegExp(r"^[0-9]{1,2}$").hasMatch(entry);
    case QuaiEntry.price:
      return RegExp(r"^[0-9]+$").hasMatch(entry);
    case QuaiEntry.text:
      return true;
    default:
      return false;
  }
}

TextInputType orderEntryToInputType(QuaiEntry orderEntry){
  switch(orderEntry){
    case QuaiEntry.tableNumber || QuaiEntry.quantity || QuaiEntry.number || QuaiEntry.price:
      return TextInputType.number;
    case QuaiEntry.alpha || QuaiEntry.subAlpha || QuaiEntry.text:
      return TextInputType.text;
    default:
      print("Warning, OrderEntry to TextInputType conversion was not exhaustive");
      return TextInputType.text;
  }
}

//Le truc de gros bg jpp
///Formats the content of the textEditingController to a format such as 10,99€ 1.5€ -55,55€
///and returns the parsed double if the entry can respect that format, otherwise sets the entry
///of the textEditingController to the previous value/prevents an entry that would not follow the format
double? forcePriceFormat(TextEditingController textEditingController,
    {required bool firstDigitCanBeZero, required bool mustBeNegative}){
  RegExp regex = RegExp("^${mustBeNegative? "-?": ""}${firstDigitCanBeZero? "[0-9]+" : "[1-9][0-9]*"}[,.]?[0-9]{0,2}€?\$");

  String content = textEditingController.text;
  double result;
  if (regex.hasMatch(content)) {
    if (!content.contains("€")) content += "€";
    if (!content.contains("-") && mustBeNegative) content = "-$content";

    textEditingController.value = textEditingController.value
        .copyWith(
        text: content,
        selection: TextSelection(
            baseOffset: content.length - 1,
            extentOffset: content.length - 1));
    content = content.replaceFirst(",",
        ".");//To be able to parse into double because decimals are made with commas in french
    if(mustBeNegative){//remove the minus here
      result = double.parse(content.substring(1, content.length -1));
    }else{
      result =
          double.parse(content.substring(0, content.length - 1));
    }
    return result;
  } else if (content.length > 1) {
    String previousValue;
    content.contains("€")
        ? previousValue = content.substring(0, content.length - 2)
        : previousValue = content.substring(0, content.length - 1);
    if (!previousValue.contains("€")) previousValue += "€";
    textEditingController.value = textEditingController.value
        .copyWith(
        text: previousValue,
        selection: TextSelection(
            baseOffset: content.length - 1,
            extentOffset: content.length - 1));
  } else {
    textEditingController.text = "";
  }
}

Map<String, dynamic> convertOrderElementToMaps(OrderElement oe) {
  Map<String, dynamic> oeMap = <String, dynamic>{};
  Map<String, dynamic> artMap = <String, dynamic>{};
  Map<String, dynamic> promMap = <String, dynamic>{};

  oeMap[OrderElement.keyQuantity] = oe.quantity;
  oeMap[OrderElement.keyComment] = oe.comment;
  oeMap[OrderElement.keyCommentIsExtra] = oe.commentIsExtra;
  oeMap[OrderElement.keyExtraPrice] = oe.extraPrice;
  oeMap[OrderElement.keyHasPromotion] = oe.hasPromotion;

  artMap[Article.keyAlpha] = oe.articleAlpha;
  artMap[Article.keyNumber] = oe.articleNumber;
  artMap[Article.keySubAlpha] = oe.articleSubAlpha;
  artMap[Article.keyName] = oe.articleName;
  artMap[Article.keyType] = oe.articleType.name;
  artMap[Article.keyPrice] = oe.articlePrice;

  oeMap[OrderElement.keyArticle] = artMap;

  if (oe.hasPromotion) {
    promMap[Promotion.keyDiscountValue] = oe.promotionDiscountValue;
    promMap[Promotion.keyName] = oe.promotionName;
    oeMap[OrderElement.keyPromotion] = promMap;
  }
  return oeMap;
}

Map<String, dynamic> convertPromotionToMap(Promotion prom) {
  Map<String, dynamic> promMap = <String, dynamic>{};
  promMap[Promotion.keyName] = prom.name;
  promMap[Promotion.keyDiscountValue] = prom.discountValue;
  return promMap;
}


Uri getUri({required String path}){
  String addressLAN = "192.168.1.128:65139";
  String addressWiFi = "192.168.1.129:65139";
  String localhost = "localhost:65139";
  if(kIsWeb){
    return Uri.http(localhost, path);
  }else{
    return Uri.http(addressLAN, path);
  }
}