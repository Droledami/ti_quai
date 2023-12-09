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