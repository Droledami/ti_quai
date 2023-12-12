import '';

import 'package:flutter/cupertino.dart';
import 'package:ti_quai/enums/EntryType.dart';

String getHourAndMinuteString(DateTime date) {
  final String time = "${date.hour}:${date.minute < 10 ? "0${date.minute}": "${date.minute}"}";
  return time;
}

bool checkIfEntryIsValid(OrderEntry orderEntry, String entry){
  switch(orderEntry){
    case OrderEntry.tableNumber:
      return RegExp(r"^[0-9]{1,2}$").hasMatch(entry);
    case OrderEntry.alpha:
      return RegExp(r"^[A-Z]$").hasMatch(entry);
    case OrderEntry.number:
      return RegExp(r"^[0-9]{1,3}$").hasMatch(entry);
    case OrderEntry.subAlpha:
      return RegExp(r"^[a-z]$").hasMatch(entry);
    case OrderEntry.quantity:
      return RegExp(r"^[0-9]{1,2}$").hasMatch(entry);
    case OrderEntry.price:
      return RegExp(r"^[0-9]+$").hasMatch(entry);
    case OrderEntry.text:
      return true;
    default:
      return false;
  }
}

TextInputType orderEntryToInputType(OrderEntry orderEntry){
  switch(orderEntry){
    case OrderEntry.tableNumber || OrderEntry.quantity || OrderEntry.number || OrderEntry.price:
      return TextInputType.number;
    case OrderEntry.alpha || OrderEntry.subAlpha || OrderEntry.text:
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